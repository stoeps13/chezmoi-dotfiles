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
    parser = argparse.ArgumentParser(description='With or without comments')

    # Add argument for the option
    parser.add_argument('--comments', action='store_true', help='Print latest comments')

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
        # print("\t - ### [[%s: %s]]\ncase-no:: [[%s]]\ncreated:: [[%s]]\nupdated:: [[%s]]\nfollow-up:: [[%s]]\nage:: %s days\nstatus:: %s\ninternal_status:: %s\ndefect-no:: %s" % (case_id, case_title, case_id, case_created, case_updated, case_followup, age.days, status, internal_status, defect_no))
        print("\t - ### [[%s: %s]]\ninternal_status:: %s" % (case_id, case_title, internal_status))

        # Check if the --sort option was provided
        if vars(args)['comments']:
            # Sorting logic goes here
            # Add the last 3 comments
            comments = split_text(row[11])
            i=1
            print("\t\t - #### Latest Comments:")
            for comment in comments[:1]:
                print("```\n%s\n```" % (comment))
        else:
            pass
finally:
    os.remove('sncases.xls')
