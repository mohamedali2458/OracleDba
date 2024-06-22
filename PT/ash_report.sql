ASH Report – ASH (Active Session History) Reports

1. Overview

Oracle ASH report introduced on Oracle 10GR2.

ASH is helpful to identify performance issues in old sessions.

ASH collects samples of active sessions every second (waiting for non-idle events, or on the CPU working) from v$sessions (inactive sessions are not captured).

Sampled data collected to circular buffer in SGA and the same can be accessed through V$ views. V$ACTIVE_SESSION_HISTORY view provides the sampled session activity for the instance. 

Using the Active Session History you can examine and perform the detailed analysis on the current data in the V$ACTIVE_SESSION_HISTORY and the past data in the DBA_HIST_ACTIVE_SESS_HISTORY view.

ASH report is a small report compared to the AWR report which will provide the db/instance details for a short period of time.

ASH report covers a much shorter period of time (e.g. 5 min) compared to an AWR report (e.g. 30 min or 1 hour). 

ASH report captures the following things.

SQL identifier of SQL statement
Object number, file number, and block number
Wait event identifier and parameters
Session identifier and session serial number
Module and action name
Client identifier of the session
Service hash identifier

Major ASH report sections are:

Top User Events
Top Background Events
Top Cluster Events
Top Service/Module
Top SQL Command Types
Top Phases of Execution
Top Remote Instances
Top SQL with Top Events
....


2. Ways of Gathering ASH

2.1 Using ORADEBUG

ASHDUMP needs to be collected DURING the time of the issue
In case collecting from RAC , Gather ASH Dumps from ALL database instances at approximately the same time
SQL> oradebug setmypid 
SQL> oradebug unlimit
SQL> oradebug dump ashdump 5   # this will gather 5 minutes of ASH data, you may increase this if you feel necessary but try to keep it under 1 hour 
SQL> oradebug tracefile_name   # displays the trace file


2.2 Using ashrpt.sql or Enterprise Manager

ashrpt.sql
	SQL> @?/rdbms/admin/ashrpt
	Enter value for report_type:  HTML or TEXT [ HTML is default ]
	Enter value for begin_time: 
		Defaults to -15 mins
		To specify absolute begin time: [MM/DD[/YY]] HH24:MI[:SS]
		To specify relative begin time: (start with '-' sign) -[HH24:]MI
	Enter value for duration: Defualt is till current time
	Enter value for report_name:

2.3 Using v$active_session_history

Please note covering only ashrpt.sql here.
Output: Only ashrpt.sql

Example: If you want to take ASH report between 

Start time: 31-Oct-16 14:30:00
End time  : 31-Oct-16 14:45:00

Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options

SQL> @?/rdbms/admin/ashrpt.sql

Current Instance
~~~~~~~~~~~~~~~~

   DB Id    DB Name      Inst Num Instance
----------- ------------ -------- ------------
 3175693255 W148P               1 w148p


Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
Enter 'html' for an HTML report, or 'text' for plain text
Defaults to 'html'
Enter value for report_type: html

Type Specified:  html


Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   DB Id     Inst Num DB Name      Instance     Host
------------ -------- ------------ ------------ ------------
* 3175693255        1 W148P        w148p        rac2.rajasek
                                                har.com


Defaults to current database

Using database id: 3175693255

Enter instance numbers. Enter 'ALL' for all instances in a
RAC cluster or explicitly specify list of instances (e.g., 1,2,3).
Defaults to current instance.

Using instance number(s): 1

ASH Samples in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Oldest ASH sample available:  31-Oct-16 16:07:48   [     64 mins in the past]
Latest ASH sample available:  31-Oct-16 17:11:43   [      0 mins in the past]


Specify the timeframe to generate the ASH report
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter begin time for report:

--    Valid input formats:
--      To specify absolute begin time:
--        [MM/DD[/YY]] HH24:MI[:SS]
--        Examples: 02/23/03 14:30:15
--                  02/23 14:30:15
--                  14:30:15
--                  14:30
--      To specify relative begin time: (start with '-' sign)
--        -[HH24:]MI
--        Examples: -1:15  (SYSDATE - 1 Hr 15 Mins)
--                  -25    (SYSDATE - 25 Mins)

Defaults to -15 mins
Enter value for begin_time: 10/31/16 14:30:00 <---- MM/DD/YY HH24:MI:SS
Report begin time specified: 10/31/16 14:30:00

Enter duration in minutes starting from begin time:
Defaults to SYSDATE - begin_time
Press Enter to analyze till current time
Enter value for duration: 15 <--- Enter duration in minutes starting from begin time
Report duration specified:   15

Using 31-Oct-16 14:30:00 as report begin time
Using 31-Oct-16 14:45:00 as report end time
..
..
..
Specify the Report Name
~~~~~~~~~~~~~~~~~~~~~~~
The default report file name is ashrpt_1_1031_1445.html.  To use this name,
press  to continue, otherwise enter an alternative.
Enter value for report_name: raj_ash.html <----

Using the report name raj_ash.html

Summary of All User Input
-------------------------
Format         : HTML
DB Id          : 3175693255
Inst num       : 1
Begin time     : 31-Oct-16 14:30:00
End time       : 31-Oct-16 14:45:00
Slot width     : Default
Report targets : 0
Report name    : raj_ash.html
..
..
Report written to raj_ash.html
SQL>


