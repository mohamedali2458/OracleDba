How to Disable CONTROL_MANAGEMENT_PACK_ACCESS

1. Overview

We can disable Oracle 11g ADDM, AWR using control_management_pack_access Parameter

we can disable the ADDM in Oracle 11g using control_management_pack_access initialization parameter. 

The values permitted for this parameter are

NONE – Both below packs are not available

TUNING – Only tuning packs (SQL Tuning advisor, SQLAccess Advisor) are avilable

DIAGNOSTIC+TUNING – This enables Diagnostic (AWR, ADDM) and tuning packs to the database. 

By default the database will be enabled with DIAGNOSTIC+TUNING as the value for the parameter.

When we disable the parameter by putting value as NONE the V$ACTIVE_SESSION_HISTORY table will be empty and ASH, AWR report will not show any content.


2. Display current value

SQL> show parameter control_management_pack_access

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
control_management_pack_access       string      DIAGNOSTIC+TUNING
SQL>


SQL> SELECT count(*) FROM V$ACTIVE_SESSION_HISTORY;

  COUNT(*)
----------
        64 <----


3. Disable control_management_pack_access

SQL> ALTER SYSTEM SET control_management_pack_access=NONE;

System altered.

SQL>

SQL> show parameter control_management_pack_access

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
control_management_pack_access       string      NONE
SQL>

SQL> SELECT count(*) FROM V$ACTIVE_SESSION_HISTORY;

  COUNT(*)
----------
         0 <-----

SQL>

Enable control_management_pack_access

ALTER SYSTEM SET control_management_pack_access='DIAGNOSTIC+TUNING';


