#!/usr/bin/env python

from pysnc import ServiceNowClient
from time import gmtime, strftime
from datetime import datetime

client = ServiceNowClient('https://support.hcltechsw.com/', ('{{ (bitwarden "item" "HCL Support (Bosch)").login.username }}', '{{ (bitwarden "item" "HCL Support (Bosch)").login.password}}'))

gr = client.GlideRecord('sn_customerservice_case')
gr.add_query("active", "true")
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
    case_no = r.get_display_value('task_effective_number')
    case_title = r.get_display_value('short_description')
    case_created = r.get_display_value('sys_created_on').split(' ')[0]
    case_da_no = r.get_display_value('u_defect_number')
    case_sys_id = r.get_display_value('sys_id')
    if case_da_no == '':
        case_da = ''
    else:
        case_da = "[" + case_da_no + "](https://support.hcltechsw.com/csm?id=kb_article&sysparm_article=" + case_da_no + ")"

    print('''\t - ### [[%s: %s]]
case-no:: [%s](https://support.hcltechsw.com/csm?id=csm_ticket&table=sn_customerservice_case&sys_id=%s)
alias:: [[%s]], [[%s]]
defect-article:: %s
created:: [[%s]]
case-for:: [[rb]]
status:: [[open]]
    '''
    % (case_no, case_title, case_no, case_sys_id, case_no, case_title, case_da, case_created))
    # sn-link:: https://support.hcltechsw.com/csm?id=csm_ticket&table=sn_customerservice_case&sys_id=%s&view=csp" % (r.get_display_value('sys_id')))
    #print("\t\t - #### Status: %s" % (r.get_display_value('u_internal_status_1')))
    #print("\t\t - #### Created: %s, Last Update: %s, Age: %s days" % (r.get_display_value('sys_created_on'), r.get_display_value('sys_updated_on'), age))
    i=i+1





