What is SPL?
Search Processing Language (SPL) used to search, filter, analyze, and visualize machine data in Splunk.

Purpose : Find useful information from logs, events, alerts and security data.

How it works : Start with a search, then use pipe commands to filter and transform results.

Used for : SOC investigation, dashboards, reports, alert logic, and threat hunting.

Basic flow : Search data --> filter events --> calculate stats --> display results.

index=web sourcetype=access_combined status=404
| stats count by src_ip
| sort -count


Types of Fields in Splunk
=========================
Fields are name-value pairs that help you search, filter, group and analyze log data.

Default Fields : Created by Splunk automatically, such as _time, host, source, and sourcetype.

Indexed Fields : Stored at index time and searched faster, such as host, source and sourcetype.

Extracted Fields : Pulled from raw events during search, such as src_ip, user, status, or action.

Calculated Fields : Created using eval to add meaning, such as risk_level or login_status.

Lookup Fields : Added from external tables, such as departments, asset_owner, or location.

Simple Field Example:

index=web status=404
| table_time host src_ip status url_path


Default Fields in Splunk
=========================
Splunk automatically adds these fields to every event.  They help you identify when the event happened, where it came from, and how Splunk classified it.

field, meaning, security use
_time, Event timestamp, When the activity happened

host, device or system name, which server or endpoint generated the log

source, original log file or data path, where the log was collected from:linux:auth:, apache:access, WinEventLog:Security

sourcetype, log format or category, How Splunk parses the event:linux:auth, apache:access, WinEventLog:Security

index, Storage location in Splunk, Where the data is stored and searched

Simple SPL Example:
index=web sourcetype=access_combined host=web01
| table _time host source sourcetype status


Basic Search and Filtering
==========================
index=/ sourcetype=

Purpose: select the data location and log type before analysis.

When to use: at the start of almost every SPL query.

Example with random logs 
Web access logs 

index=web sourcetype=access_combined

output idea: only web access events are shown.



field=value

purpose: filter events where a field has a specific value.

when to use: when you already know the field and value to find.

example:
firewall traffic logs 

index=firewall sourcetype=firewall_traffic action=blocked

index=firewall action=blocked

AND / OR / NOT 

purpose : combine or exclude search conditions.
boolean operators.

when to use: when one filter is not enough.

example:
DNS query logs

index=dns (query="*.ru" OR query="*.cn") NOT src_ip="10.0.0.5"

output idea: suspicious domains excluding a trusted scanner.


wildcard * and quotes
=====================
purpose: search flexible text patterns or exact phrases.

when to use: when messages are semi-structured.

example with random logs:
application error logs

index=app "database timeout" service=*api*

output idea : API services with database timeout messages.



Search
======
purpose: apply another filter after the base search.

when to use: useful for teaching step-by-step investigation.

example with random logs:
proxy logs

index=proxy
| search category="malware" action=blocked

output idea: blocked proxy malaware events



source=final_auth_log.json 

source=final_auth_log.json result=failure

(in left side interesting fields we can see result count 1 failure)

(leftside there is a ifield called process with 2 values)

source=final_auth_log.json process=sshd

source=final_auth_log.json process=sshd AND result=success

source=final_auth_log.json process=sshd result=success OR result=closed

source=final_auth_log.json process=sshd result=success NOT username=root

source=final_auth_log.json process=sshd
| search result=success
| search source_ip=<ip addr>



Display and Organize Results
============================

table 

purpose: show only the fields you want in columns 

when to use: when preparing clean output for review.

example with random logs:
VPN logs

index=vpn
| table _time user src_ip action

output idea: a clean analyst-friendly table.



fields
======
purpose: keep or remove fields from search results.

when to use: when results have too many fields.

example with random logs:
endpoint process logs

index=edr
| fields _time host user process_name
command_line

output idea: only investigation fields remain.


rename
======
change field names for readability.

when sharing output with beginners or managers.

example:
cloud login logs 

index=cloud_login
| rename src_ip AS "Source IP", user AS "User"

output idea: readable column names.


dedup
=====
remove duplicate events based on one or more fields.

when you only need unique users, IPs, or hosts.

example:
asset inventory logs

index=asset
| dedup hostname
| table hostname os owner

output idea: one row per hostname.


sort
=====
order results by field value.

when finding highest, lowest, newest, or oldest.

example:
email gateway logs

index=email
| stats count by sender
| sort -count

output idea: top senders by email volume.



source=final_auth_log.json process=sshd | table _time username source_ip result

source=final_auth_log.json process=sshd
| fields _time username source_ip
(gives all events with these 2 fields and the time of the event)

source=final_auth_log.json process=sshd
| dedup source_ip
| table source_ip

source=final_auth_log.json process=sshd
| stats count by source_ip
| sort -count


Statistics and Aggregation
==========================
stats count 

count events and group them by fields.

for top talkers, failures, alerts, or categories.

example: web status logs

index=web
| stats count by status

output idea: count per HTTP status code.


dc()
count unique values.

when distinct users, hosts, IPs, or domains matter.

ex: DNS logs

index=dns
| stats