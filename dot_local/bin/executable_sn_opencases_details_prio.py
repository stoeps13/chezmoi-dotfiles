#!/usr/bin/env python

from pysnc import ServiceNowClient
from time import gmtime, strftime
from datetime import datetime
from dateutil.relativedelta import relativedelta

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
gr.add_query("priority", "2")
gr.order_by("task_effective_number")
# gr.fields = ['sys_id', 'short_description','sys_updated_on','u_external_action_status_2','task_effective_number','priority','u_external_action_status_2','u_internal_status_1']
gr.query()

lastupdate=strftime("%Y-%m-%d %H:%M:%S", gmtime())
date=strftime("%Y-%m-%d", gmtime())

today = datetime.today()
i=1
for r in gr:
    temp = r.serialize()

    created = datetime.strptime(r.get_display_value('sys_created_on'), '%Y-%m-%d %H:%M:%S')
    age = (today - created).days
    age_in_months = relativedelta(today, created).months + (relativedelta(today, created).years * 12)
    case_no = r.get_display_value('task_effective_number')
    case_title = r.get_display_value('short_description')
    case_created = r.get_display_value('sys_created_on').split(' ')[0]
    case_da_no = r.get_display_value('u_defect_number')
    case_sys_id = r.get_display_value('sys_id')
    case_prio = r.get_display_value('priority')
    if case_da_no == '':
        case_da = ''
    else:
        case_da = "[" + case_da_no + "](https://support.hcl-software.com/csm?id=kb_article&sysparm_article=" + case_da_no + ")"

    print(f'- [{case_no}: {case_title}](../hcl-cases/{case_no}) - age: {age} days or {age_in_months} months')
    i=i+1





