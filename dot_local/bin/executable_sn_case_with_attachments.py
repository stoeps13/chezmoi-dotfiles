#!/usr/bin/env python

import argparse
import datetime
import os
import pathlib
import re
import sys
import textwrap
import json
import urllib.parse
from urllib.parse import urlparse

import html2text
import pip
import requests
from requests.auth import HTTPBasicAuth


def import_or_install(package):
    try:
        __import__(package)
    except ImportError:
        pip.main(["install", package])


# Define a function to split the text based on the pattern
def split_text(text):
    return re.split(
        r"\n(?=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} - .+ \(Additional comments\))", text
    )


def xldate_to_datetime(xldate):
    tempDate = datetime.datetime(1900, 1, 1)
    deltaDays = datetime.timedelta(days=float(xldate) - 2)
    TheTime = tempDate + deltaDays
    return TheTime.strftime("%Y-%m-%d")


def convert_code_html_to_markdown(input_string):
    # Check if the string starts with '[code]' and ends with '[/code]'
    if input_string.startswith("[code]") and input_string.endswith("[/code]"):
        # Remove the '[code]' at the start and '[/code]' at the end
        html_content = input_string[len("[code]") : -len("[/code]")].strip()

        # Convert the remaining HTML content to Markdown
        markdown_content = html2text.html2text(html_content)

        return markdown_content
    else:
        # Return the original string if it doesn't have the proper tags
        return input_string


def sanitize_filename(filename):
    """Sanitize filename for filesystem compatibility"""
    # Remove or replace invalid characters
    invalid_chars = '<>:"/\\|?*'
    for char in invalid_chars:
        filename = filename.replace(char, '_')
    
    # Limit length to avoid filesystem issues
    if len(filename) > 200:
        name, ext = os.path.splitext(filename)
        filename = name[:200-len(ext)] + ext
    
    return filename


def download_attachments(case_id, username, password, base_url, assets_dir):
    """Download all attachments for a specific case"""
    attachments_info = []
    downloaded_files = set()  # Track downloaded files to avoid duplicates
    filename_counter = {}  # Track filename occurrences for unique naming
    
    # ServiceNow REST API endpoint for attachments
    attachments_url = f"{base_url}/api/now/attachment"
    
    # Query for attachments related to the case
    params = {
        'sysparm_query': f'table_name=sn_customerservice_case^table_sys_id={case_id}',
        'sysparm_fields': 'sys_id,file_name,content_type,size_bytes,sys_created_on'
    }
    
    try:
        response = requests.get(
            attachments_url, 
            auth=HTTPBasicAuth(username, password),
            params=params,
            headers={'Accept': 'application/json'}
        )
        
        if response.status_code == 200:
            data = response.json()
            
            for attachment in data.get('result', []):
                sys_id = attachment['sys_id']
                filename = attachment['file_name']
                content_type = attachment['content_type']
                size_bytes = attachment.get('size_bytes', '0')
                created_on = attachment.get('sys_created_on', '')
                
                # Convert size to int, handling string values
                try:
                    size_int = int(float(str(size_bytes))) if size_bytes else 0
                except (ValueError, TypeError):
                    size_int = 0
                
                # Create case-specific subdirectory
                case_assets_dir = os.path.join(assets_dir, case_id)
                os.makedirs(case_assets_dir, exist_ok=True)
                
                # Sanitize filename and handle duplicates
                safe_filename = sanitize_filename(filename)
                
                # Handle duplicate filenames by adding a counter
                base_name, extension = os.path.splitext(safe_filename)
                if safe_filename in filename_counter:
                    filename_counter[safe_filename] += 1
                    safe_filename = f"{base_name}_{filename_counter[safe_filename]}{extension}"
                else:
                    filename_counter[safe_filename] = 0
                
                file_path = os.path.join(case_assets_dir, safe_filename)
                
                # Create unique identifier to avoid downloading duplicates
                file_key = f"{sys_id}_{filename}"
                
                if file_key in downloaded_files:
                    print(f"Skipping duplicate sys_id: {filename}")
                    continue
                
                downloaded_files.add(file_key)
                
                # Skip if file already exists (shouldn't happen now with unique names)
                if os.path.exists(file_path):
                    print(f"File already exists, skipping: {safe_filename}")
                    # Still add to attachments info
                    relative_path = os.path.join('assets', case_id, safe_filename)
                    attachments_info.append({
                        'filename': filename,
                        'safe_filename': safe_filename,
                        'path': relative_path,
                        'content_type': content_type,
                        'size': size_int,
                        'created_on': created_on
                    })
                    continue
                
                # Download the actual file
                download_url = f"{base_url}/api/now/attachment/{sys_id}/file"
                
                file_response = requests.get(
                    download_url,
                    auth=HTTPBasicAuth(username, password),
                    stream=True
                )
                
                if file_response.status_code == 200:
                    with open(file_path, 'wb') as f:
                        for chunk in file_response.iter_content(chunk_size=8192):
                            f.write(chunk)
                    
                    # Store attachment info for markdown links
                    relative_path = os.path.join('assets', case_id, safe_filename)
                    attachments_info.append({
                        'filename': filename,
                        'safe_filename': safe_filename,
                        'path': relative_path,
                        'content_type': content_type,
                        'size': size_int,
                        'created_on': created_on
                    })
                    
                    print(f"Downloaded: {filename} -> {safe_filename}")
                else:
                    print(f"Failed to download {filename}: HTTP {file_response.status_code}")
        
        else:
            print(f"Failed to fetch attachments for case {case_id}: HTTP {response.status_code}")
            if response.status_code == 401:
                print("Authentication failed. Please check your credentials.")
            elif response.status_code == 403:
                print("Access forbidden. You may not have permission to access attachments.")
            
    except Exception as e:
        print(f"Error downloading attachments for case {case_id}: {str(e)}")
    
    return attachments_info


def get_case_sys_id(case_number, username, password, base_url):
    """Get the sys_id for a case number using the Table API"""
    try:
        # ServiceNow Table API endpoint for cases
        cases_url = f"{base_url}/api/now/table/sn_customerservice_case"
        
        params = {
            'sysparm_query': f'number={case_number}',
            'sysparm_fields': 'sys_id,number',
            'sysparm_limit': '1'
        }
        
        response = requests.get(
            cases_url,
            auth=HTTPBasicAuth(username, password),
            params=params,
            headers={'Accept': 'application/json'}
        )
        
        if response.status_code == 200:
            data = response.json()
            results = data.get('result', [])
            
            if results:
                return results[0]['sys_id']
        
        print(f"Could not find sys_id for case {case_number}")
        return None
        
    except Exception as e:
        print(f"Error getting sys_id for case {case_number}: {str(e)}")
        return None


def format_attachments_markdown(attachments_info):
    """Format attachments as markdown links"""
    if not attachments_info:
        return ""
    
    markdown = "\n#### Attachments:\n"
    for attachment in attachments_info:
        filename = attachment['filename']
        path = attachment['path']
        size = attachment.get('size', 0)
        content_type = attachment.get('content_type', 'unknown')
        
        # Ensure size is an integer
        try:
            size = int(float(str(size))) if size else 0
        except (ValueError, TypeError):
            size = 0
        
        # Format file size
        if size > 1024*1024:
            size_str = f"{size/(1024*1024):.1f}MB"
        elif size > 1024:
            size_str = f"{size/1024:.1f}KB"
        else:
            size_str = f"{size}B"
        
        markdown += f"- [{filename}]({path}) ({size_str}, {content_type})\n"
    
    return markdown


def load_config():
    """Load ServiceNow configuration from .sn_envrc file in home directory"""
    home_dir = str(pathlib.Path.home())
    env_file = os.path.join(home_dir, ".sn_envrc")

    username = ""
    password = ""
    base_url = "https://support.hcl-software.com"  # Default value

    try:
        with open(env_file, "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith("SN_USERNAME="):
                    username = line[len("SN_USERNAME=") :].strip("\"'")
                elif line.startswith("SN_PASSWORD="):
                    password = line[len("SN_PASSWORD=") :].strip("\"'")
                elif line.startswith("SN_BASE_URL="):
                    base_url = line[len("SN_BASE_URL=") :].strip("\"'")
    except FileNotFoundError:
        print(f"Error: Config file not found at {env_file}")
        print(
            "Please create a .sn_envrc file in your home directory with the following format:"
        )
        print("SN_USERNAME=your_username")
        print("SN_PASSWORD=your_password")
        print("SN_BASE_URL=https://support.hcl-software.com  # Optional")
        sys.exit(1)

    if not username or not password:
        print("Error: Username or password not found in .sn_envrc file")
        sys.exit(1)

    return username, password, base_url


# Create argument parser
parser = argparse.ArgumentParser(
    description="Get the latest comments from ServiceNow @HCL"
)

# Add arguments for options
parser.add_argument("-d", "--days", help="Days to display")
parser.add_argument("-n", "--casenumber", help="Limit on one case")
parser.add_argument("-a", "--all", action="store_true", help="Show all comments")
parser.add_argument(
    "-f",
    "--from-date",
    help="Show comments from this date (format: YYYY-MM-DD) until today",
)
parser.add_argument(
    "--download-attachments",
    action="store_true",
    help="Download attachments for the cases",
)

# Folder to store downloaded images
assets_dir = "assets"
os.makedirs(assets_dir, exist_ok=True)

# Parse the command-line arguments
args = parser.parse_args()

if args.all and not args.casenumber:
    parser.error(
        "The '-a' flag can only be used if a case number is specified with '-n'."
    )

if args.days and args.from_date:
    parser.error("Cannot use both '-d/--days' and '-f/--from-date' at the same time.")

days_display = 7
case_number = ""
all_comments = False
from_date = None
should_download_attachments = args.download_attachments

if vars(args)["days"]:
    days_display = int(args.days)

if vars(args)["from_date"]:
    try:
        from_date = datetime.datetime.strptime(args.from_date, "%Y-%m-%d").date()
    except ValueError:
        parser.error(
            "Invalid date format. Please use YYYY-MM-DD format for the from-date."
        )

# Load configuration from .sn_envrc file
username, password, base_url = load_config()

if vars(args)["casenumber"]:
    case_number = str(args.casenumber)
    url = (
        base_url
        + "/sn_customerservice_case_list.do?sysparm_query=numberSTARTSWITH"
        + case_number
        + "%5EGROUPBYu_external_action_status_2&sysparm_first_row=1&sysparm_view=csp&sysparm_choice_query_raw=&sysparm_list_header_search=true&EXCEL"
    )
    # url = base_url + '/sn_customerservice_case_list.do?sysparm_query=u_external_action_status_2%3E%3Dhcl%20working%5EnumberSTARTSWITH' + case_number + '&sysparm_first_row=1&sysparm_view=csp&sysparm_choice_query_raw=&sysparm_list_header_search=true&EXCEL'
else:
    url = (
        base_url
        + "/sn_customerservice_case_list.do?sysparm_nostack=true&sysparm_query=GOTOu_external_action_status_2%3E%3Dhcl%20working&sysparm_first_row=1&sysparm_view=csp&EXCEL"
    )

if vars(args)["all"]:
    all_comments = True

# Load configuration from .sn_envrc file
username, password, base_url = load_config()

# Send a GET request with authentication
response = requests.get(url, auth=HTTPBasicAuth(username, password))

try:
    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        # Save the Excel file
        with open("sncases.xls", "wb") as f:
            f.write(response.content)
    else:
        print("Failed to download Excel file. Status code:", response.status_code)
        sys.exit()

    import_or_install("xlrd")

    from xlrd import open_workbook

    wb = open_workbook("sncases.xls")

    sorted_rows = []
    for s in wb.sheets():
        for row in range(1, s.nrows):  # Start from the second row
            col_values = []
            for col in range(s.ncols):
                value = s.cell(row, col).value
                try:
                    value = str(int(value))
                except ValueError:
                    pass
                col_values.append(value)
            # Append the row to the list of rows
            sorted_rows.append(col_values)

    # Get today's date
    today = datetime.datetime.today().date()

    # Calculate the date range for filtering
    if from_date:
        start_date = from_date
    else:
        start_date = today - datetime.timedelta(days=days_display)

    # Sort the list of rows based on the values in the first column
    sorted_rows.sort(key=lambda x: x[0])

    for row in sorted_rows:
        case_id = row[0]
        case_title = row[1]
        case_created = xldate_to_datetime(int(row[7]))
        case_updated = xldate_to_datetime(int(row[8]))
        if row[9] != "":
            case_followup = xldate_to_datetime(int(row[9]))
        else:
            case_followup = ""

        status = row[3]
        internal_status = row[4]
        defect_no = row[13]

        date_object = datetime.datetime.strptime(case_created, "%Y-%m-%d").date()

        # Calculate the difference between the two dates
        age = today - date_object

        # Download attachments if requested
        attachments_info = []
        if should_download_attachments:
            case_sys_id = get_case_sys_id(case_id, username, password, base_url)
            if case_sys_id:
                attachments_info = download_attachments(case_sys_id, username, password, base_url, assets_dir)

        if all_comments == False:
            if (
                start_date
                <= datetime.datetime.strptime(case_updated, "%Y-%m-%d").date()
                <= today
            ):
                # Check only comments for documents with update timestamp within the date range
                comments = split_text(row[10])
                i = 1
                comment_output = []

                for comment in comments:
                    comment = comment.split("(Additional comments)")

                    # Check the timestamp of the comment
                    comment_date_str = comment[0].split(" - ")
                    comment_date = datetime.datetime.strptime(
                        comment_date_str[0], "%Y-%m-%d %H:%M:%S"
                    ).date()

                    if start_date <= comment_date <= today:
                        # Split the original text into lines and wrap each line
                        wrapped_lines = [
                            textwrap.fill(line, width=80)
                            for line in comment[1].lstrip().rstrip().splitlines()
                        ]

                        # Join the wrapped lines with line feeds
                        final_output = "\n".join(wrapped_lines)

                        comment_output.append("### " + comment[0] + "\n")
                        comment_output.append(
                            convert_code_html_to_markdown(final_output) + "\n"
                        )

                if len(comment_output) > 0:
                    print(
                        "### [%s: %s](/hcl-cases/%s)\n\n* Case-no: [%s](/hcl-cases/%s)\n* internal_status: %s\n* last_update: %s\n"
                        % (
                            case_id,
                            case_title,
                            case_id,
                            case_id,
                            case_id,
                            internal_status,
                            case_updated,
                        )
                    )
                    
                    # Add attachments information
                    if attachments_info:
                        print(format_attachments_markdown(attachments_info))
                    
                    for output in comment_output:
                        print(output)
            else:
                pass
        else:
            comments = split_text(row[10])
            i = 1
            comment_output = []

            for comment in comments:
                comment = comment.split("(Additional comments)")

                # Check the timestamp of the comment
                comment_date_str = comment[0].split(" - ")
                comment_date = datetime.datetime.strptime(
                    comment_date_str[0], "%Y-%m-%d %H:%M:%S"
                ).date()

                # For --all option, still filter by from_date if provided
                if from_date and comment_date < from_date:
                    continue

                # Split the original text into lines and wrap each line
                wrapped_lines = [
                    textwrap.fill(line, width=80)
                    for line in comment[1].lstrip().rstrip().splitlines()
                ]

                # Join the wrapped lines with line feeds
                final_output = "\n".join(wrapped_lines)

                comment_output.append("#### " + comment[0] + "\n")
                comment_output.append(
                    convert_code_html_to_markdown(final_output) + "\n"
                )

            if len(comment_output) > 0:
                print(
                    "### [%s: %s](/hcl-cases/%s)\n\n* Case-no: [%s](/hcl-cases/%s)\n* internal_status: %s\n* last_update: %s\n"
                    % (
                        case_id,
                        case_title,
                        case_id,
                        case_id,
                        case_id,
                        internal_status,
                        case_updated,
                    )
                )
                
                # Add attachments information
                if attachments_info:
                    print(format_attachments_markdown(attachments_info))
                
                for output in comment_output:
                    print(output)
finally:
    # Clean up the downloaded file
    if os.path.exists("sncases.xls"):
        os.remove("sncases.xls")