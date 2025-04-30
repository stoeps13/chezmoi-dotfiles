#!/usr/bin/env python

from pysnc import ServiceNowClient
from time import gmtime, strftime
from datetime import datetime
from dateutil.relativedelta import relativedelta
from collections import defaultdict

try:
    from sn_config import load_config, get_auth_basic, get_base_url
except ImportError:
    print("Error: Could not import sn_config module.")
    print("Make sure sn_config.py is in the same directory or in your PYTHONPATH.")
    sys.exit(1)

username, password, base_url = load_config()
client = ServiceNowClient(base_url, (username, password))

gr = client.GlideRecord('sn_customerservice_case')
gr.add_query("active", "true")
gr.order_by("task_effective_number")
gr.query()

# Store cases grouped by priority
cases_by_priority = defaultdict(list)

today = datetime.today()

for r in gr:
    case_no = r.get_display_value('task_effective_number')
    case_title = r.get_display_value('short_description')
    case_prio = r.get_display_value('priority')
    created = datetime.strptime(r.get_display_value('sys_created_on'), '%Y-%m-%d %H:%M:%S')
    age = (today - created).days
    age_in_months = relativedelta(today, created).months + (relativedelta(today, created).years * 12)

    # Store cases in dictionary grouped by priority
    cases_by_priority[case_prio].append(f'- [{case_no}: {case_title}](../hcl-cases/{case_no}) - age: {age} days or {age_in_months} months')

# Print markdown output grouped by priority
for prio in sorted(cases_by_priority.keys()):  # Ensure sorted order
    print(f"## Cases Prio {prio}\n")
    print("\n".join(cases_by_priority[prio]))
    print()  # Extra newline for spacing
