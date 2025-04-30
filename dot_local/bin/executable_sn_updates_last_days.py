#!/usr/bin/env python

from requests.auth import HTTPBasicAuth
import argparse
import datetime
import html2text
import os
import pandas as pd
import pip
import re
import requests
import sys
import textwrap

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

def convert_code_html_to_markdown(input_string):
    # Check if the string starts with '[code]' and ends with '[/code]'
    if input_string.startswith("[code]") and input_string.endswith("[/code]"):
        # Remove the '[code]' at the start and '[/code]' at the end
        html_content = input_string[len("[code]"):-len("[/code]")].strip()

        # Convert the remaining HTML content to Markdown
        markdown_content = html2text.html2text(html_content)

        return markdown_content
    else:
        # Return the original string if it doesn't have the proper tags
        return input_string


try:
    from sn_config import load_config, get_auth_basic, get_base_url
except ImportError:
    print("Error: Could not import sn_config module.")
    print("Make sure sn_config.py is in the same directory or in your PYTHONPATH.")
    sys.exit(1)

username, password, base_url = load_config()
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
    parser = argparse.ArgumentParser(description='Get the latest comments from ServiceNow @HCL')

    # Add argument for the option
    parser.add_argument('-d', '--days', help='Days to display')

    # Parse the command-line arguments
    args = parser.parse_args()

    days_display = 7

    if vars(args)['days']:
        days_display = int(args.days)

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

    # Get today's date
    today = datetime.datetime.today().date()
    last_days = today - datetime.timedelta(days=days_display)

    # Sort the list of rows based on the values in the first column
    sorted_rows.sort(key=lambda x: x[0])

    #print(sorted_rows)
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

        # Calculate the difference between the two dates
        age = today - date_object

        if last_days <= datetime.datetime.strptime(case_updated, "%Y-%m-%d").date() <= today:

            # Check only comments for documents with update timestamp from last week

            # Check if the --sort option was provided
            comments = split_text(row[10])
            i=1
            comment_output = []

            for comment in comments[:10]:

                comment = comment.split('(Additional comments)')

                # Check the timestamp of the comment
                comment_date_str = comment[0].split(' - ')
                comment_date = datetime.datetime.strptime(comment_date_str[0], "%Y-%m-%d %H:%M:%S").date()

                if last_days <= comment_date <= today:

                    # Split the original text into lines and wrap each line
                    wrapped_lines = [textwrap.fill(line, width=80) for line in comment[1].lstrip().rstrip().splitlines()]

                    # Join the wrapped lines with line feeds
                    final_output = "\n".join(wrapped_lines)

                    comment_output.append('##### ' + comment[0] + '\n')
                    comment_output.append(convert_code_html_to_markdown(final_output) + '\n')

            if len(comment_output) > 0:
                print("#### [%s: %s](/hcl-cases/%s)\n\n* Case-no: [%s](/hcl-cases/%s)\n* internal_status: %s\n* last_update: %s\n" % (case_id, case_title, case_id,case_id, case_id, internal_status, case_updated))
                for output in comment_output:
                    print(output)

        else:
            pass
finally:
    os.remove('sncases.xls')
    # print("done")
