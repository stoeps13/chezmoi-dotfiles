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

print("- ## HCL Case status from %s" % date)

today = datetime.today()
i=1
for r in gr:
    temp = r.serialize()
    created = datetime.strptime(r.get_display_value('sys_created_on'), '%Y-%m-%d %H:%M:%S')
    age = (today - created).days
    print("\t - ### [[%s: %s]]" % (r.get_display_value('task_effective_number'), r.get_display_value('short_description')))
    print("\t\t - #### Link: https://support.hcltechsw.com/csm?id=csm_ticket&table=sn_customerservice_case&sys_id=%s&view=csp" % (r.get_display_value('sys_id')))
    print("\t\t - #### Status: %s" % (r.get_display_value('u_internal_status_1')))
    print("\t\t - #### Created: %s, Last Update: %s, Age: %s days" % (r.get_display_value('sys_created_on'), r.get_display_value('sys_updated_on'), age))
    i=i+1
print("\n//Last update: %s//\n" % lastupdate)