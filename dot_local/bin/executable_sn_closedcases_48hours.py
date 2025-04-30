#!/usr/bin/env python

from pysnc import ServiceNowClient
from time import gmtime, strftime
from datetime import datetime, timedelta

try:
    from sn_config import load_config, get_auth_basic, get_base_url
except ImportError:
    print("Error: Could not import sn_config module.")
    print("Make sure sn_config.py is in the same directory or in your PYTHONPATH.")
    sys.exit(1)

username, password, base_url = load_config()

lastupdate=strftime("%Y-%m-%d %H:%M:%S", gmtime())
date=strftime("%Y-%m-%d", gmtime())
client = ServiceNowClient(base_url, (username, password))

ago = datetime.now() + timedelta(hours=-480)

gr = client.GlideRecord('sn_customerservice_case')
gr.add_query("active", "false")
gr.add_query("closed_at", ">", ago)

gr.order_by("closed_at")
# gr.fields = ['sys_id', 'short_description','sys_updated_on','u_external_action_status_2','task_effective_number','priority','u_external_action_status_2','u_internal_status_1']
gr.query()



today = datetime.today()
i=1
for r in gr:
    temp = r.serialize()
    created = datetime.strptime(r.get_display_value('sys_created_on'), '%Y-%m-%d %H:%M:%S')
    age = (today - created).days
    case_no = r.get_display_value('task_effective_number')
    case_title = r.get_display_value('short_description')
    case_created = r.get_display_value('sys_created_on').split(' ')[0]
    case_da_no = r.get_display_value('u_defect_number')
    case_sys_id = r.get_display_value('sys_id')
    case_closed = r.get_display_value('closed_at').split(' ')[0]
    if case_da_no == '':
        case_da = ''
    else:
        case_da = "[" + case_da_no + "](https://support.hcl-software.com/csm?id=kb_article&sysparm_article=" + case_da_no + ")"

    print('''\t - ### [[%s: %s]]
        case-no:: [%s](https://support.hcl-software.com/csm?id=csm_ticket&table=sn_customerservice_case&sys_id=%s)
        alias:: [[%s]], [[%s]]
        defect-article:: %s
        created:: [[%s]]
        case-for:: [[rb]]
        status:: [[closed]]
        closed-date:: [[%s]] \r\n
    '''
    % (case_no, case_title, case_no, case_sys_id, case_no, case_title, case_da, case_created, case_closed))
    # sn-link:: https://support.hcl-software.com/csm?id=csm_ticket&table=sn_customerservice_case&sys_id=%s&view=csp" % (r.get_display_value('sys_id')))
    #print("\t\t - #### Status: %s" % (r.get_display_value('u_internal_status_1')))
    #print("\t\t - #### Created: %s, Last Update: %s, Age: %s days" % (r.get_display_value('sys_created_on'), r.get_display_value('sys_updated_on'), age))
    i=i+1





