#!/usr/bin/env python
# coding: utf-8
from bs4 import BeautifulSoup
from datetime import datetime
from playwright.async_api import async_playwright
from pysnc import ServiceNowClient
from time import gmtime, strftime
from urllib.parse import urljoin
import aiofiles
import aiohttp
import asyncio
import hashlib
import html2text
import os
import re
import sys

try:
    from sn_config import load_config, get_auth_basic, get_base_url
except ImportError:
    print("Error: Could not import sn_config module.")
    print("Make sure sn_config.py is in the same directory or in your PYTHONPATH.")
    sys.exit(1)

username, password, base_url = load_config()

h = html2text.HTML2Text()
h.ignore_links = False  # Set to True if you want to ignore links
h.ignore_images = False  # Set to True if you want to ignore images
h.body_width = 0  # Don't wrap lines


async def download_image(session, img_url, images_folder, base_url):
    """Download an image and return the local filename"""
    try:
        # Make URL absolute if it's relative
        if not img_url.startswith(("http://", "https://")):
            img_url = urljoin(base_url, img_url)

        # Extract sys_id from ServiceNow attachment URL for filename
        sys_id_match = re.search(r"sys_id=([a-f0-9]+)", img_url)
        if sys_id_match:
            sys_id = sys_id_match.group(1)
            safe_filename = (
                f"attachment_{sys_id}.png"  # Default to PNG for ServiceNow attachments
            )
        else:
            # Fallback filename generation
            url_hash = hashlib.md5(img_url.encode()).hexdigest()[:8]
            safe_filename = f"image_{url_hash}.png"

        local_path = os.path.join(images_folder, safe_filename)

        # Check if file already exists
        if os.path.exists(local_path):
            print(f"Image already exists: {safe_filename}")
            return safe_filename

        print(f"Downloading image: {img_url}")

        # Set headers to mimic a browser request
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept": "image/webp,image/apng,image/*,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
        }

        async with session.get(img_url, headers=headers) as response:
            if response.status == 200:
                # Get the image content
                image_content = await response.read()

                # Try to determine actual file extension from content-type header
                content_type = response.headers.get("content-type", "").lower()
                if "jpeg" in content_type or "jpg" in content_type:
                    extension = ".jpg"
                elif "png" in content_type:
                    extension = ".png"
                elif "gif" in content_type:
                    extension = ".gif"
                elif "webp" in content_type:
                    extension = ".webp"
                elif "svg" in content_type:
                    extension = ".svg"
                else:
                    # Try to detect from image content (magic bytes)
                    if image_content[:4] == b"\x89PNG":
                        extension = ".png"
                    elif image_content[:2] == b"\xff\xd8":
                        extension = ".jpg"
                    elif (
                        image_content[:6] == b"GIF89a" or image_content[:6] == b"GIF87a"
                    ):
                        extension = ".gif"
                    else:
                        extension = ".png"  # Default fallback

                # Update filename with correct extension
                base_name = os.path.splitext(safe_filename)[0]
                safe_filename = f"{base_name}{extension}"
                local_path = os.path.join(images_folder, safe_filename)

                # Save the image
                async with aiofiles.open(local_path, "wb") as f:
                    await f.write(image_content)

                print(f"Downloaded: {safe_filename} ({content_type})")
                return safe_filename
            else:
                print(
                    f"Failed to download image: {img_url} (Status: {response.status})"
                )
                return None

    except Exception as e:
        print(f"Error downloading image {img_url}: {e}")
        return None


async def process_images_in_soup(soup, session, images_folder, base_url):
    """Process all images in BeautifulSoup object and update src attributes"""
    # Create images folder if it doesn't exist
    os.makedirs(images_folder, exist_ok=True)

    # Find all img tags
    img_tags = soup.find_all("img")
    print(f"Found {len(img_tags)} images to process")

    for img_tag in img_tags:
        src = img_tag.get("src")
        if not src:
            continue

        # Download the image
        local_filename = await download_image(session, src, images_folder, base_url)

        if local_filename:
            # Update the src attribute to point to local file
            img_tag["src"] = f"images/{local_filename}"
            print(f"Updated image src to: images/{local_filename}")
        else:
            print(f"Failed to download image, keeping original src: {src}")


async def scrape_kb_article_markdown(
    url, download_images=True, images_subfolder="images", frontmatter="", kb_internal=""
):
    try:
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=True)
            page = await browser.new_page()

            # Set user agent to avoid blocking
            await page.set_extra_http_headers(
                {
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                }
            )

            # Create aiohttp session for image downloads
            async with aiohttp.ClientSession() as session:
                try:
                    print(f"Loading: {url}")
                    await page.goto(url, timeout=30000)
                    await page.wait_for_load_state("networkidle")

                    # Wait for specific content to appear
                    try:
                        await page.wait_for_selector("body", timeout=10000)
                    except:
                        print("Warning: Body selector timeout, continuing...")

                    await asyncio.sleep(3)

                    html_content = await page.content()
                    soup = BeautifulSoup(html_content, "html.parser")

                    # Configure html2text for better markdown output
                    h = html2text.HTML2Text()
                    h.ignore_links = False  # Keep links
                    h.ignore_images = False  # Keep images
                    h.ignore_emphasis = False  # Keep bold/italic
                    h.body_width = 0  # Don't wrap lines
                    h.unicode_snob = True  # Use unicode characters
                    h.escape_snob = True  # Escape special characters properly

                    # Extract all the data
                    result = {
                        "url": url,
                        "title": None,
                        "markdown_content": None,
                        "html_content": None,
                        "plain_text": None,
                        "kb_number": None,
                        "success": False,
                        "images_downloaded": 0,
                    }

                    # Title extraction using your specific selector
                    title_elem = soup.select_one("h2.kb-title-header")
                    if title_elem:
                        result["title"] = title_elem.get_text().strip()
                        print(f"Found title: {result['title']}")
                    else:
                        print("Title not found with selector 'h2.kb-title-header'")

                    # Content extraction using your specific selector
                    content_elem = soup.select_one("article.kb-article-content")

                    if content_elem:
                        print(
                            "Found article content with selector 'article.kb-article-content'"
                        )

                        # Clean up the content before converting
                        # Remove unwanted elements
                        for element in content_elem(
                            ["script", "style", "nav", "header", "footer", "aside"]
                        ):
                            element.decompose()

                        # Process images if requested
                        if download_images:
                            images_before = len(content_elem.find_all("img"))
                            await process_images_in_soup(
                                content_elem, session, images_subfolder, url
                            )
                            result["images_downloaded"] = images_before

                        # Store different formats
                        result["html_content"] = str(content_elem)
                        result["plain_text"] = content_elem.get_text(
                            separator="\n", strip=True
                        )

                        # Convert to markdown with proper formatting
                        markdown_content = h.handle(str(content_elem)).strip()

                        # Adjust heading levels: promote all headings by one level
                        # ### becomes ##, #### becomes ###, etc.
                        def adjust_heading_levels(markdown_text):
                            lines = markdown_text.split("\n")
                            adjusted_lines = []

                            for line in lines:
                                # Check if line starts with heading markers
                                if line.startswith("###"):
                                    # Convert ### to ## (h3 to h2)
                                    adjusted_lines.append(line.replace("###", "##", 1))
                                elif line.startswith("####"):
                                    # Convert #### to ### (h4 to h3)
                                    adjusted_lines.append(
                                        line.replace("####", "###", 1)
                                    )
                                elif line.startswith("#####"):
                                    # Convert ##### to #### (h5 to h4)
                                    adjusted_lines.append(
                                        line.replace("#####", "####", 1)
                                    )
                                elif line.startswith("######"):
                                    # Convert ###### to ##### (h6 to h5)
                                    adjusted_lines.append(
                                        line.replace("######", "#####", 1)
                                    )
                                else:
                                    adjusted_lines.append(line)

                            return "\n".join(adjusted_lines)

                        result["markdown_content"] = adjust_heading_levels(
                            markdown_content
                        )
                        result["success"] = True

                    else:
                        print(
                            "Article content not found with selector 'article.kb-article-content'"
                        )

                        # Fallback to other selectors
                        fallback_selectors = [
                            ".article-content",
                            "#article-body",
                            ".kb-article-text",
                            ".content",
                            ".main-content",
                            '[role="main"]',
                            ".article-body-content",
                            ".kb-content",
                        ]

                        for selector in fallback_selectors:
                            content_elem = soup.select_one(selector)
                            if (
                                content_elem
                                and len(content_elem.get_text().strip()) > 50
                            ):
                                print(
                                    f"Found content with fallback selector: {selector}"
                                )

                                # Process images for fallback content too
                                if download_images:
                                    images_before = len(content_elem.find_all("img"))
                                    await process_images_in_soup(
                                        content_elem, session, images_subfolder, url
                                    )
                                    result["images_downloaded"] = images_before

                                result["html_content"] = str(content_elem)
                                result["plain_text"] = content_elem.get_text(
                                    separator="\n", strip=True
                                )
                                markdown_content = h.handle(str(content_elem)).strip()
                                result["markdown_content"] = adjust_heading_levels(
                                    markdown_content
                                )
                                result["success"] = True
                                break

                    # KB number extraction
                    kb_match = re.search(r"KB\d+", html_content)
                    if kb_match:
                        result["kb_number"] = kb_match.group()

                    # Add title to markdown if found (but don't duplicate if title already exists in content)
                    if result["title"] and result["markdown_content"]:
                        # Check if title is already in the markdown content
                        if result["title"] not in result["markdown_content"][:100]:
                            result["markdown_content"] = (
                                f"# {result['kb_number']}: {result['title']}\n---{frontmatter}\n---\n\n{result['markdown_content']}"
                            )

                    # Add internal comments
                    if kb_internal and kb_internal.strip():
                        result["markdown_content"] = (
                            f"{result['markdown_content']}\n\n## Internal Comments\n\n{h.handle(kb_internal)}"
                        )

                    return result

                finally:
                    await browser.close()

    except Exception as e:
        print(f"Error scraping {url}: {e}")
        return {"url": url, "error": str(e), "success": False}


async def process_kb_articles():
    """Main async function to process KB articles"""
    client = ServiceNowClient(base_url, (username, password))

    # Query knowledge base entries
    gr = client.GlideRecord("kb_knowledge")
    gr.add_query("u_document_type", "Defect Article")
    gr.add_query("u_product_family", "Connections")
    # gr.add_query("kb_category", "4edd9e781b49001483cb86e9cd4bcbfd")
    # gr.add_query("number","KB0120376")
    gr.add_query("active", "true")
    gr.add_query("language", "en")
    gr.add_query("latest", "true")
    # gr.add_query("","")

    gr.order_by_desc("sys_updated_on")
    # Limit result during testing
    gr.limit = 5

    # Basic query to get all published knowledge articles
    gr.query()

    lastupdate = strftime("%Y-%m-%d %H:%M:%S", gmtime())
    date = strftime("%Y-%m-%d", gmtime())

    today = datetime.today()

    for r in gr:
        temp = r.serialize()

        created = datetime.strptime(
            r.get_display_value("sys_created_on"), "%Y-%m-%d %H:%M:%S"
        )
        updated = datetime.strptime(
            r.get_display_value("sys_updated_on"), "%Y-%m-%d %H:%M:%S"
        )
        kb_no = r.get_display_value("number")
        kb_revision = r.get_display_value("u_revision")
        kb_updated_by = r.get_display_value("sys_updated_by")
        kb_created_by = r.get_display_value("sys_created_by")
        kb_description = r.get_display_value("meta_description")
        kb_title = r.get_display_value("short_description")
        kb_link = r.get_display_value("u_permalink")
        kb_id = r.get_display_value("article_id")
        kb_internal = r.get_display_value("u_internal_use_only")

        frontmatter = f"""
Created: {str(created)}
Created by: {kb_created_by}
Updated: {str(updated)}
Last update by: {kb_updated_by}
Link: [{kb_no}]({kb_link})
        """
        print("\n" + kb_no + ": " + kb_title)
        print(kb_description)

        # Now this await call is inside an async function
        result = await scrape_kb_article_markdown(
            kb_link, 
            download_images=True, 
            images_subfolder="images",
            frontmatter=frontmatter,
            kb_internal=kb_internal
        )

        if result["success"]:
            print(f"Successfully scraped article: {result['title']}")
            print(f"Images downloaded: {result['images_downloaded']}")

            # Save markdown to file
            if result["markdown_content"]:
                filename = (
                    f"{result['kb_number']}.md" if result["kb_number"] else "article.md"
                )
                async with aiofiles.open(filename, "w", encoding="utf-8") as f:
                    await f.write(result["markdown_content"])
                print(f"Markdown saved to: {filename}")
        else:
            print(f"Failed to scrape article: {result.get('error', 'Unknown error')}")


# Main entry point
if __name__ == "__main__":
    asyncio.run(process_kb_articles())