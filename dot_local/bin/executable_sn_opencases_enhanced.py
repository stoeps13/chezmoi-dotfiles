#!/usr/bin/env python

import requests
from requests.auth import HTTPBasicAuth
import pandas as pd
import pip
import re
import sys
import datetime
import argparse
import os
import json
import urllib.parse
from pathlib import Path

def import_or_install(package):
    try:
        __import__(package)
    except ImportError:
        pip.main(['install', package])

# Define a function to split the text based on the pattern
def split_text(text):
    return re.split(r'\n(?=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} - .+ \(Additional comments\))', text)

def xldate_to_datetime(xldate):
    tempDate = datetime.datetime(1900, 1, 1)
    deltaDays = datetime.timedelta(days=float(xldate)-2)
    TheTime = (tempDate + deltaDays )
    return TheTime.strftime("%Y-%m-%d")

def sanitize_filename(filename):
    """Sanitize filename to be safe for filesystem"""
    # Remove or replace invalid characters
    invalid_chars = '<>:"/\\|?*'
    for char in invalid_chars:
        filename = filename.replace(char, '_')
    # Limit length and strip whitespace
    return filename.strip()[:255]

def download_attachments(case_sys_id, case_id, username, password, base_url):
    """Download all attachments for a given case"""
    attachments_dir = Path("assets") / sanitize_filename(case_id)
    attachments_dir.mkdir(parents=True, exist_ok=True)
    
    # ServiceNow REST API endpoint for attachments
    attachments_url = f"{base_url}/api/now/attachment"
    
    # Query parameters to get attachments for this case
    params = {
        'sysparm_query': f'table_name=sn_customerservice_case^table_sys_id={case_sys_id}',
        'sysparm_fields': 'sys_id,file_name,content_type,size_bytes,sys_created_on'
    }
    
    try:
        # Get list of attachments
        response = requests.get(
            attachments_url, 
            auth=HTTPBasicAuth(username, password),
            params=params,
            headers={'Accept': 'application/json'}
        )
        
        if response.status_code != 200:
            print(f"Failed to get attachments list for case {case_id}: {response.status_code}")
            return []
        
        attachments_data = response.json()
        attachment_links = []
        
        if not attachments_data.get('result'):
            return []
        
        print(f"\t\t - Found {len(attachments_data['result'])} attachment(s)")
        
        for attachment in attachments_data['result']:
            attachment_sys_id = attachment['sys_id']
            filename = attachment['file_name']
            content_type = attachment['content_type']
            size_bytes = attachment.get('size_bytes', 0)
            created_on = attachment.get('sys_created_on', '')
            
            # Sanitize filename
            safe_filename = sanitize_filename(filename)
            file_path = attachments_dir / safe_filename
            
            # Download the actual file
            download_url = f"{base_url}/api/now/attachment/{attachment_sys_id}/file"
            
            file_response = requests.get(
                download_url,
                auth=HTTPBasicAuth(username, password)
            )
            
            if file_response.status_code == 200:
                with open(file_path, 'wb') as f:
                    f.write(file_response.content)
                
                # Create relative path for markdown link
                relative_path = f"assets/{sanitize_filename(case_id)}/{safe_filename}"
                
                # Format file size
                if size_bytes:
                    if size_bytes < 1024:
                        size_str = f"{size_bytes} B"
                    elif size_bytes < 1024*1024:
                        size_str = f"{size_bytes/1024:.1f} KB"
                    else:
                        size_str = f"{size_bytes/(1024*1024):.1f} MB"
                else:
                    size_str = "Unknown size"
                
                attachment_links.append({
                    'filename': filename,
                    'safe_filename': safe_filename,
                    'path': relative_path,
                    'content_type': content_type,
                    'size': size_str,
                    'created_on': created_on
                })
                
                print(f"\t\t\t - Downloaded: {filename} ({size_str})")
            else:
                print(f"\t\t\t - Failed to download: {filename} (HTTP {file_response.status_code})")
        
        return attachment_links
        
    except Exception as e:
        print(f"\t\t - Error downloading attachments for case {case_id}: {str(e)}")
        return []

def get_case_sys_id(case_number, username, password, base_url):
    """Get the sys_id for a case by case number"""
    # ServiceNow REST API endpoint for cases
    cases_url = f"{base_url}/api/now/table/sn_customerservice_case"
    
    params = {
        'sysparm_query': f'number={case_number}',
        'sysparm_fields': 'sys_id',
        'sysparm_limit': '1'
    }
    
    try:
        response = requests.get(
            cases_url,
            auth=HTTPBasicAuth(username, password),
            params=params,
            headers={'Accept': 'application/json'}
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('result') and len(data['result']) > 0:
                return data['result'][0]['sys_id']
        
        return None
        
    except Exception as e:
        print(f"Error getting sys_id for case {case_number}: {str(e)}")
        return None

try:
    from sn_config import load_config, get_auth_basic, get_base_url
except ImportError:
    print("Error: Could not import sn_config module.")
    print("Make sure sn_config.py is in the same directory or in your PYTHONPATH.")
    sys.exit(1)

username, password, base_url = load_config()

# URL of the ServiceNow page with the ?EXCEL parameter
url = base_url + '/sn_customerservice_case_list.do?sysparm_nostack=true&sysparm_query=GOTOu_external_action_status_2%3E%3Dhcl%20working&sysparm_first_row=1&sysparm_view=csp&EXCEL'

# Send a GET request with authentication
response = requests.get(url, auth=HTTPBasicAuth(username, password))

try:
    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        # Save the Excel file
        with open('sncases.xls', 'wb') as f:
            f.write(response.content)
    else:
        print("Failed to download Excel file. Status code:", response.status_code)
        sys.exit()

    import_or_install('xlrd')

    from xlrd import open_workbook

    wb = open_workbook('sncases.xls')

    # Create argument parser
    parser = argparse.ArgumentParser(description='With or without comments and attachments')

    # Add argument for the option
    parser.add_argument('--comments', action='store_true', help='Print latest comments')
    parser.add_argument('--attachments', action='store_true', help='Download attachments')

    # Parse the command-line arguments
    args = parser.parse_args()

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
            sorted_rows.append(col_values)  # Append the row to the list of rows

    # Sort the list of rows based on the values in the first column
    sorted_rows.sort(key=lambda x: x[0])

    for row in sorted_rows:
        #print(row)
        case_id=row[0]
        case_title=row[1]
        case_created=xldate_to_datetime(int(row[7]))
        case_updated=xldate_to_datetime(int(row[8]))
        if row[9] != '':
            case_followup=xldate_to_datetime(int(row[9]))
        else:
            case_followup=''

        status=row[3]
        internal_status=row[4]
        defect_no=row[13]

        date_object = datetime.datetime.strptime(case_created, '%Y-%m-%d').date()

        # Get today's date
        today = datetime.datetime.today().date()

        # Calculate the difference between the two dates
        age = today - date_object

        # Create markdown for Logseq
        print("\t - ### [[%s: %s]]\ninternal_status:: %s" % (case_id, case_title, internal_status))

        # Download attachments if requested
        attachment_links = []
        if args.attachments:
            case_sys_id = get_case_sys_id(case_id, username, password, base_url)
            if case_sys_id:
                attachment_links = download_attachments(case_sys_id, case_id, username, password, base_url)
            else:
                print(f"\t\t - Could not find sys_id for case {case_id}")

        # Check if the --comments option was provided
        if args.comments:
            # Add the last 3 comments
            comments = split_text(row[11])
            i=1
            print("\t\t - #### Latest Comments:")
            for comment in comments[:1]:
                print("```\n%s\n```" % (comment))
        
        # Add attachment links to output
        if attachment_links:
            print("\t\t - #### Attachments:")
            for attachment in attachment_links:
                # Create markdown link with file info
                link_text = f"[{attachment['filename']}]({attachment['path']})"
                info_text = f" ({attachment['content_type']}, {attachment['size']})"
                if attachment['created_on']:
                    info_text += f" - {attachment['created_on'][:10]}"
                print(f"\t\t\t - {link_text}{info_text}")

finally:
    if os.path.exists('sncases.xls'):
        os.remove('sncases.xls')
