#!/usr/bin/env python

import requests
import os
import sys

from pysnc import ServiceNowClient
from time import gmtime, strftime
from datetime import datetime

try:
    from sn_config import load_config
except ImportError:
    print("Error: Could not import sn_config module.")
    print("Make sure sn_config.py is in the same directory or in your PYTHONPATH.")
    sys.exit(1)

username, password, base_url = load_config()
print(username)
client = ServiceNowClient(base_url, (username, password))

gr = client.GlideRecord('sn_customerservice_case')
gr.add_query("active", "true")
gr.order_by("task_effective_number")
gr.query()

for r in gr:
    # Get a specific case/incident
    incident = client.get('incident', sys_id=r.get_display_value('sys_id'))

    # Get attachments for the incident
    attachments = client.get('attachment', query={'table_sys_id': incident['sys_id']})

    # Download a specific attachment
    task_effective_number = r.get_display_value('task_effective_number')
    # Create a folder with this name
    folder_path = os.path.join(os.getcwd(), task_effective_number)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
        print(f"Created folder: {folder_path}")

    for attachment in attachments['result']:
        attachment_sys_id = attachment['sys_id']
        file_name = attachment['file_name']

        # Download the attachment
        attachment_content = client.get_attachment(attachment_sys_id)

        file_path = os.path.join(folder_path, file_name)

        # Save the attachment to a file
        with open(file_path, 'wb') as f:
            f.write(attachment_content)
