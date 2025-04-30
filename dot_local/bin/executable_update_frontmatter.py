#!/usr/bin/env python3

import os
import sys
import subprocess
import re
from pathlib import Path

def get_frontmatter(case_number):
    """Get frontmatter by calling the get_case_frontmatter.py script"""
    try:
        print(f"  Calling get_case_frontmatter.py for {case_number}...")
        result = subprocess.run(
            ["get_case_frontmatter.py", case_number],
            capture_output=True,
            text=True,
            check=False  # Don't raise exception on non-zero exit codes
        )

        if result.returncode != 0:
            print(f"  Error: get_case_frontmatter.py returned code {result.returncode}")
            print(f"  STDERR: {result.stderr.strip()}")
            print(f"  STDOUT: {result.stdout.strip()}")

            # Option to preserve existing frontmatter if available
            print(f"  Using existing frontmatter instead...")
            return None

        if not result.stdout.strip():
            print(f"  Warning: get_case_frontmatter.py returned empty output")
            return None

        return result.stdout
    except Exception as e:
        print(f"  Error executing get_case_frontmatter.py: {str(e)}")
        return None

def extract_existing_frontmatter(content):
    """Extract existing frontmatter from content if available"""
    # Try to find frontmatter
    fm_pattern = re.compile(r'^---\s*\n(.*?)\n---\s*\n', re.DOTALL)
    title_fm_pattern = re.compile(r'^# .+?\n+?---\s*\n(.*?)\n---\s*\n', re.DOTALL)

    fm_match = fm_pattern.match(content)
    title_fm_match = title_fm_pattern.match(content)

    if fm_match:
        return f"---\n{fm_match.group(1)}\n---"
    elif title_fm_match:
        return f"---\n{title_fm_match.group(1)}\n---"

    return None

def extract_title_and_case_from_frontmatter(frontmatter, case_number):
    """Extract title and case number from frontmatter content"""
    title_pattern = re.compile(r'title:\s*(.+?)(\n|$)', re.DOTALL)
    case_no_pattern = re.compile(r'case-no:\s*\[(.+?)\]', re.DOTALL)

    # Extract title
    title = "Untitled Case"
    title_match = title_pattern.search(frontmatter)
    if title_match:
        title = title_match.group(1).strip()

    # Extract case number (or use filename if not found)
    case_no = case_number  # Default to filename
    case_match = case_no_pattern.search(frontmatter)
    if case_match:
        # Extract just the case number from the markdown link format [CS0123456](url)
        case_text = case_match.group(1).strip()
        # If it's a markdown link, extract just the case number part
        case_link_match = re.match(r'(.+?)(?:\(|$)', case_text)
        if case_link_match:
            case_no = case_link_match.group(1).strip()

    return case_no, title

def update_frontmatter(file_path, preserve_existing=True):
    """Update the frontmatter in a markdown file, placing '# Case-Number: Title' at top"""
    file_path = Path(file_path)

    # Extract case number from filename
    case_number = file_path.stem

    print(f"Processing {file_path}...")

    # Read the file content
    with open(file_path, 'r') as file:
        content = file.read()

    # Get new frontmatter
    new_frontmatter = get_frontmatter(case_number)

    # If we couldn't get new frontmatter and we want to preserve existing frontmatter
    if new_frontmatter is None and preserve_existing:
        existing_frontmatter = extract_existing_frontmatter(content)
        if existing_frontmatter:
            print(f"  Using existing frontmatter for {file_path}")
            new_frontmatter = existing_frontmatter
        else:
            print(f"  No existing frontmatter found to preserve. Skipping {file_path}")
            return False
    elif new_frontmatter is None:
        print(f"  Skipping {file_path} - no frontmatter available")
        return False

    # Extract case number and title from frontmatter
    case_no, title = extract_title_and_case_from_frontmatter(new_frontmatter, case_number)

    # Create the title line in the desired format "# Case-Number: Title"
    title_line = f"# {case_no}: {title}"

    # Define patterns for different file structures to identify the content after frontmatter

    # 1. Title followed by frontmatter
    title_fm_pattern = re.compile(r'^# .+?\n+?---\s*\n.*?\n---\s*\n(.*)', re.DOTALL)

    # 2. Standard frontmatter at top
    std_fm_pattern = re.compile(r'^---\s*\n.*?\n---\s*\n(.*)', re.DOTALL)

    # 3. Just title, no frontmatter (extract content after title)
    title_only_pattern = re.compile(r'^# .+?\n(.*)', re.DOTALL)

    # Try to extract the content after frontmatter/title
    content_after = ""

    title_fm_match = title_fm_pattern.match(content)
    std_fm_match = std_fm_pattern.match(content)
    title_only_match = title_only_pattern.match(content)

    if title_fm_match:
        content_after = title_fm_match.group(1)
    elif std_fm_match:
        content_after = std_fm_match.group(1)
    elif title_only_match:
        content_after = title_only_match.group(1)
    else:
        # No recognized structure, use all content
        content_after = content

    # Create the new file content with "# Case-Number: Title" at top, then frontmatter
    updated_content = f"{title_line}\n\n{new_frontmatter}\n\n{content_after.lstrip()}"

    # Write updated content back to file
    with open(file_path, 'w') as file:
        file.write(updated_content)

    print(f"  Updated with title '{title_line}' at top")
    print(f"Updated frontmatter for {file_path}")
    return True

def main():
    # Check for command line arguments
    preserve_existing = True  # Default behavior
    files = []

    for arg in sys.argv[1:]:
        if arg == "--no-preserve":
            preserve_existing = False
        else:
            files.append(arg)

    # If no files specified, use all .md files in current directory
    if not files:
        files = [f for f in os.listdir('.') if f.endswith('.md')]

    for file in files:
        update_frontmatter(file, preserve_existing)

if __name__ == "__main__":
    main()
