Check status, enable and disable the Audit in Oracle
====================================================
SQL> show parameter audit_trail

Brief of following parameter values:
NONE- Auditing is disabled.
DB- Auditing is enabled,(all audit records stored in table(SYS.AUD$).
DB,EXTENDED- As DB,but the SQL_BIND and SQL_TEXT columns are also populated for SYS.AUD$ table
XML- Auditing is enabled, records stored as XML format files.
XML,EXTENDED- As XML,but the SQL_BIND and SQL_TEXT columns are also populated in XML file.
OS- Auditing is enabled, audit records to the operating system's text file.

For Enable or Disable the Audit at Database Level
=================================================
--For Enable
ALTER SYSTEM SET audit_trail=db SCOPE=SPFILE;

--For Disable
ALTER SYSTEM SET audit_trail=NONE SCOPE=SPFILE;

Note:
1. Every Change in parameter effected after restart the database.
2. AUDIT_SYS_OPERATIONS parameter is used for auditing the operations 
performed by SYSDBA or SYSOPER privileged users. All audit records 
are written to the audit trail. You need to enable this parameter 
(alter system set audit_sys_operations=true scope=spfile;)


Three levels of audit:
======================
1. Statement level
Auditing will be done at statement level. Statements level can be checked with STMT_AUDIT_OPTION_MAP.

SQL> audit table by scott;

--Audit records can be found in DBA_STMT_AUDIT_OPTS.
SQL> select * from DBA_STMT_AUDIT_OPTS;

2. Object level
Database objects can be audited: tables, views, sequences, packages, stored procedures and stored functions.

SQL> audit insert, update, delete on scott.emp by hr;

Audit records can be found in DBA_OBJ_AUDIT_OPTS.
SQL> select * from DBA_OBJ_AUDIT_OPTS;

3. Privillege level
All system privileges that are found in SYSTEM_PRIVILEGE_MAP can be audited.

SQL> audit create tablespace, alter tablespace by all;
Note: Specify ALL PRIVILEGES to audit all system privileges.

--Audit records can be found in DBA_PRIV_AUDIT_OPTS.
SQL> select * from DBA_PRIV_AUDIT_OPTS;


AUDIT have two options:
=======================
1. BY SESSION
If you want Oracle to write a single record for all SQL statements of the same 
type issued and operations of the same type executed on the same schema objects 
in the same session.

SQL> audit create, alter, drop on currency by xe by session;

SQL> audit alter materialized view by session;

2. BY ACCESS
Specify BY ACCESS if you want Oracle database to write one record for each 
audited statement and operation.

SQL> audit update on health by access;

SQL> audit alter sequence by tester by access;


Enable the Audit at different levels:
=====================================
--Auditing for particular user for DML statement:
SQL> audit select table, insert table, update table, delete table by SCOTT by access;

--Auditing for all user activity:
SQL> audit all by SCOTT by access;

--Audit all Oracle user viewing activity:
SQL> audit select table by SCOTT by access;

--Audit all Oracle user data change activity:
SQL> audit update table, delete table,insert table by SCOTT by access;

--Audit all Oracle user viewing activity:
SQL> audit execute procedure by SCOTT by access;


Disable Audit at different levels:
==================================
NOAUDIT statement turns off the various audit options of Oracle.  Use it to reset statement, 
privilege and object audit options.

SQL> NOAUDIT;
SQL> NOAUDIT session;
SQL> NOAUDIT session BY scott, hr;
SQL> NOAUDIT DELETE ON emp;
SQL> NOAUDIT SELECT TABLE, INSERT TABLE, DELETE TABLE, EXECUTE PROCEDURE;
SQL> NOAUDIT ALL;
SQL> NOAUDIT ALL PRIVILEGES;
SQL> NOAUDIT ALL ON DEFAULT;
SQL> noaudit session by appowner;
SQL> noaudit create session by appowner;
SQL> noaudit SELECT TABLE by appowner;
SQL> noaudit INSERT TABLE by appowner;
SQL> noaudit EXECUTE PROCEDURE by appowner;
SQL> noaudit DELETE TABLE by appowner;
SQL> noaudit DELETE ANY TABLE by appowner;


Script for check all the enabled auditing on Database
=====================================================
--Check the parameter is enabled or disable for Audit

select name || '=' || value PARAMETER from sys.v_$parameter where name like '%audit%';

--Statement Audits Enabled on this Database

column user_name format a10
column audit_option format a40
select * from sys.dba_stmt_audit_opts;

--Privilege Audits Enabled on this Database

select * from dba_priv_audit_opts;

-- Object Audits Enabled on this Database

select (owner ||'.'|| object_name) object_name,
alt, aud, com, del, gra, ind, ins, loc, ren, sel, upd, ref, exe
from dba_obj_audit_opts
where alt != '-/-' or aud != '-/-'
or com != '-/-' or del != '-/-'
or gra != '-/-' or ind != '-/-'
or ins != '-/-' or loc != '-/-'
or ren != '-/-' or sel != '-/-'
or upd != '-/-' or ref != '-/-'
or exe != '-/-';

--Default Audits Enabled on this Database
select * from all_def_audit_opts;



Enable auditing for sysdba priviliges users in Oracle
=====================================================
In Oracle, we need to set the audit parameter for auditing purpose. But audit 
parameter has some limitation, when we set the audit parameter at DB value then 
it save the infromation in SYS schema view aud$ but it does not trace the sys 
schema commands during audit process.

For enable auditing of SYS or sysdba users commands, we need to set the audit 
parameter to OS or XML level. These parameter generate the audit output in file 
format that save in Operating system location.

Audit generates log file at location we specify. After setting the following 
database need to restart the DB.

Note:
OS value audit generates file in text format which can be read manually with notepad.
XML value generate log in XML format which can be read with help of V$XML_AUDIT_TRAIL view.

-- Set the location of audit in Operating system
ALTER SYSTEM SET AUDIT_FILE_DEST = 'c:\auditlog' SCOPE=SPFILE;

-- Enable the audit for SYS operations
ALTER SYSTEM SET AUDIT_SYS_OPERATIONS = TRUE SCOPE=SPFILE;

-- We can set the audit trail parameter for XML or OS level to start SYS or SYSDBA priviliges users.
ALTER SYSTEM SET AUDIT_TRAIL= XML SCOPE=SPFILE;
OR
ALTER SYSTEM SET AUDIT_TRAIL= OS SCOPE=SPFILE;
OR
ALTER SYSTEM SET AUDIT_TRAIL= XML,EXTENDED SCOPE=SPFILE;

Note: After changes, Oracle Database need to restart.

Read the Audit with XML view if Audit_trail parameter is XML

SELECT sql_text FROM v$XML_AUDIT_TRAIL WHERE EXTENDED_TIMESTAMP >= sysdate-1;

-- Also used to read audit XML format also.
SELECT * FROM DBA_COMMON_AUDIT_TRAIL;

Disable the Auditing

ALTER SYSTEM SET AUDIT_SYS_OPERATIONS = FALSE SCOPE=SPFILE;
ALTER SYSTEM SET AUDIT_TRAIL= NONE SCOPE=SPFILE;

Note: After changes, Oracle Database need to restart.



Purge the Audit records with truncate or DBMS_AUDIT_MGMT package
================================================================
Check AUDIT is enabled or disabled

Show parameter audit_trail
NAME          TYPE    VALUE
------------- ------- --------
audit_trail   string  DB

Check total no of rows in Audit table
select count(*) TOTAL from sys.aud$;


Check the size of AUD$ table

select owner,segment_name,segment_type,tablespace_name,
bytes/1024/1024 "MB Size" 
from dba_segments 
where segment_name='AUD$';
 
OWNER SEGMENT_NAME SEGMENT_TYPE TABLESPACE_NAME MB Size
----- ------------ ------------ --------------- -------
SYS   AUD$         TABLE        SYSTEM          550


Purge the AUDIT records Manually

--For complete purging the AUDIT table.
TRUNCATE table sys.AUD$;

--Delete all data from AUD$ except keeping last 30 days
--disable the aud$ logging otherwise it generate lot of archive logs
alter table AUD$ nologging;
delete from aud$ where TIMESTAMP# <= sysdate-30;


Purge the Audit records with Package DBMS_AUDIT_MGMT

1. Check the configuration

COLUMN parameter_name FORMAT A30
COLUMN parameter_value FORMAT A20
COLUMN audit_trail FORMAT A20
SELECT * FROM dba_audit_mgmt_config_params;

2. Clear the Audit Record initially

--- Clean initially
BEGIN
DBMS_AUDIT_MGMT.INIT_CLEANUP( audit_trail_type => dbms_audit_mgmt.AUDIT_TRAIL_AUD_STD, 
default_cleanup_interval => 12);
end;
/

Note: If you haven’t moved the AUD$ table out of SYSTEM tablespace, then it the below 
script will move the AUD$ to SYSAUX tablespace by default.

--Check first step is completed YES
SET SERVEROUTPUT ON
BEGIN
IF DBMS_AUDIT_MGMT.is_cleanup_initialized(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD) THEN
DBMS_OUTPUT.put_line('YES');
ELSE
DBMS_OUTPUT.put_line('NO');
END IF;
END;
/

--Set the last archive timestamp to remove the audit records lower than value of it. 
i keep 30 days data for aud$ table.
BEGIN
DBMS_AUDIT_MGMT.set_last_archive_timestamp(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
last_archive_time => SYSTIMESTAMP-30);
END;
/

--Verify
SELECT * FROM dba_audit_mgmt_last_arch_ts;

For complete empty the AUD$ table from DBMS package

BEGIN
DBMS_AUDIT_MGMT.clean_audit_trail(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
use_last_arch_timestamp => TRUE);
END;
/

For Enable or Disable the Audit at Database Level

--For Enable
ALTER SYSTEM SET audit_trail=db SCOPE=SPFILE;

--For Disable
ALTER SYSTEM SET audit_trail=NONE SCOPE=SPFILE;


Scheduled the Job of Audit purging in DBMS SCHEDULER JOBS

-- Create the scheduler job which purge the AUD$ table daily
BEGIN
DBMS_SCHEDULER.create_job (
job_name => 'JOB_PURGE_AUDIT_RECORDS',
job_type => 'PLSQL_BLOCK',
job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, TRUNC(SYSTIMESTAMP)-30); END;',
start_date => SYSTIMESTAMP,
repeat_interval => 'freq=daily; byhour=0; byminute=0; bysecond=0;',
end_date => NULL,
enabled => TRUE,
comments => 'Update last_archive_timestamp');
END;
/

-- Select the scheduler job
select LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE 
from dba_scheduler_jobs 
where job_name= ’JOB_PURGE_AUDIT_RECORDS’;



SYSAUX tablespace full with AUDSYS objects in Oracle database
=============================================================
SYSAUX tablespace in Oracle database is going to be full, on checking we found 
that AUDSYS schema is consuming lot of space in it.

On checking we found unified auditing is used the AUDSYS schema. So, we tried 
to fix it by disabling the default audit policy. Default unified audit policy 
make data despite the value of audit_trail parameter.

Note: We are thinking that AWR or stats are consuming more space on SYSAUX 
tablespace. So we can check it with AWRINFO.sql script.

You can check it with awrinfo.sql utility present in $ORACLE_HOME\rdbms\admin\awrinfo.sql.


Check the sysaux tablespace top most consuming table

col owner for a6
col segment_name for a50
select * from
(select owner,segment_name||'~'||partition_name segment_name,bytes/(1024*1024) size_m
from dba_segments
where tablespace_name = 'SYSAUX' ORDER BY BLOCKS desc) where rownum < 6;

OWNER  SEGMENT_NAME                       SIZE_M                                                                                                                            
------ ---------------------------------- ----------                                                                                                                            
AUDSYS SYS_LOB0000091751C00014$~         17808.125                                                                                                                            
AUDSYS CLI_SWP$8e0bfd86$1$1~              14296                                                                                                                            
AUDSYS CLI_TIME$8e0bfd86$1$1~               232                                                                                                                            
AUDSYS CLI_SCN$8e0bfd86$1$1~                224                                                                                                                            
AUDSYS CLI_LOB$8e0bfd86$1$1~                209                                                                                                                            
5 rows selected.     


We have two options to clean the unified audit trail
1. Complete empty the unified audit trail
2. Partial delete data up-to specified data

Following are the example of both methods:
1. Complete clean the unified audit trail

BEGIN
DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
USE_LAST_ARCH_TIMESTAMP => FALSE,
CONTAINER => dbms_audit_mgmt.container_current);
END;
/

2. Partial Clean record up-to specific time as described in two example

--Example 1. You can specify the data keep of last 15 days data as follows:
BEGIN
DBMS_AUDIT_MGMT.set_last_archive_timestamp(
audit_trail_type => DBMS_AUDIT_MGMT.audit_trail_unified,
last_archive_time => SYSTIMESTAMP-15,
--rac_instance_number => 1,
container => DBMS_AUDIT_MGMT.container_current
);
END;
/



–Check the date upto which it clean the data with following view:
COLUMN audit_trail FORMAT A20
COLUMN last_archive_ts FORMAT A40
SELECT audit_trail, last_archive_ts FROM dba_audit_mgmt_last_arch_ts;
AUDIT_TRAIL LAST_ARCHIVE_TS
——————- ———————————–
UNIFIED AUDIT TRAIL 18-JUL-18 02.26.17.000000 AM +00:00

–Example 2. You can specify the data and time upto which you keep data as follows:
BEGIN
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,last_archive_time => TO_TIMESTAMP(’10-SEP-0714:10:10.0′,’DD-MON-RRHH24:MI:SS.FF’));
END;
/

— Start the clean job by using last time stamp defined as TRUE value in upper both example.
BEGIN
DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
use_last_arch_timestamp => TRUE);
END;
/



Flush from memory

exec DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

Disable the Unified Audit policies that are enabled by default

NOAUDIT POLICY ORA_SECURECONFIG;
noaudit policy ORA_LOGON_FAILURES;

Re-enable these audit policies if needed

AUDIT POLICY ORA_SECURECONFIG;
audit policy ORA_LOGON_FAILURES;

Example of cleaning unified audit data

sqlplus / as sysdba

SQL> select count(*) from unified_audit_trail;
COUNT(*)
———-
454543252

BEGIN
DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
use_last_arch_timestamp => FALSE);
END;
/

PL/SQL procedure successfully completed.

SQL> select count(*) from unified_audit_trail;
COUNT(*)
———-
1










Move Audit table AUD$ & FGA_LOG$ from SYSAUX to New tablespace
==============================================================
Following are the steps to move the Audits table from SYSAUX default tablespace to new created tablespace.

1. Check the current tablespace for both tablespace

SELECT table_name, tablespace_name FROM dba_tables WHERE table_name IN ('AUD$', 'FGA_LOG$');

TABLE_NAME TABLESPACE_NAME
———- —————–
AUD$ SYSTEM
FGA_LOG$ SYSTEM


2. Check the size of tablespace

column segment_name for a10
select segment_name,bytes/1024/1024 size_in_megabytes from dba_segments where segment_name in ('AUD$','FGA_LOG$');

SEGMENT_NA SIZE_IN_MEGABYTES
———- —————–
AUD$ .0625
FGA_LOG$ .0625



3. Check the exisiting file location for database

select file_name from dba_data_files;

FILE_NAME
————————————————
D:\ORACLEXE\APP\ORACLE\ORADATA\XE\USERS.DBF
D:\ORACLEXE\APP\ORACLE\ORADATA\XE\UNDOTBS1.DBF
D:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSAUX.DBF
D:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSTEM.DBF

4. Create a new tablespace for audit records and keep autoextend on for it.

create tablespace audit_tbs datafile 'D:\ORACLEXE\APP\ORACLE\ORADATA\XE\audit_db.dbf' size 100M autoextend on;

5. Move the audit trail tables using executing the procedure as follows:

--this moves table AUD$
BEGIN
DBMS_AUDIT_MGMT.set_audit_trail_location(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
audit_trail_location_value => 'AUDIT_TBS');
END;
/


–this moves table FGA_LOG$
BEGIN
DBMS_AUDIT_MGMT.set_audit_trail_location(
audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,–this moves table FGA_LOG$
audit_trail_location_value => ‘AUDIT_TBS’);
END;
/

Note: It will take time depend upto data and speed of your system.

6. Verify that audit tables are moved.

SQL> SELECT table_name, tablespace_name FROM dba_tables WHERE table_name IN ('AUD$', 'FGA_LOG$');

TABLE_NAME TABLESPACE_NAME
———– —————
FGA_LOG$ AUDIT_TBS
AUD$ AUDIT_TBS





ORA-02002: error while writing to audit trail
=============================================
Cause
Error occurred due to insufficient space while writing the audit record in audit trail table.

Solution
1. On check the Alert log, we get the complete error as follows:
ORA-02002: error while writing to audit trail
ORA-55917: Table flush I/O failed for log ID: 1 bucket ID: 0
ORA-01653: unable to extend table AUDSYS.CLI_SWP$16026a73$1$1 by 8192 in tablespace SYSAUX

We have three option:
1. Extend the existing tablespace.
2. Empty the AUDIT table
3. Disable the audit(its need restart of database)


1. Extend the existing tablespace SYSAUX
a) You found the tablespace name in alert log which is filled by Audit records.

set line 999 pages 999
col FILE_NAME format a50
col tablespace_name format a15
Select tablespace_name, file_name, autoextensible, bytes/1024/1024/1024 "USEDSPACE GB", maxbytes/1024/1024/1024 "MAXSIZE GB" from dba_data_files where tablespace_name='SYSAUX';

TABLESPACE_NAME FILE_NAME                           AUT USEDSPACE GB MAXSIZE GB
--------------- ----------------------------------- --- ------------ ----------
SYSAUX          E:\ORACLE\ORADATA\ORCL\SYSAUX01.DBF   YES   31.9219    31.9999847
b) As see tablespace has one data file which is full. So, you need to add one more file.

alter tablespace SYSAUX add datafile 'E:\ORACLE\ORADATA\ORCL\SYSAUX02.DBF' size 1G autoextend on next 500M;


2. Empty the AUDIT trail table

-- take EXP backup of aud$ table.
TRUNCATE TABLE SYS.AUD$;

3. Disable the AUDIT
Note: before disable we need to implement any method from 1 or 2 points. So that it has enough space in tablespace for other records.

--check the audit parameter
SQL> show parameter audit_trail
NAME TYPE VALUE
------------ -------- ----------
audit_trail string DB
-- Disable the audit by setting
ALTER SYSTEM SET AUDIT_TRAIL=NONE SCOPE=SPFILE;
--Restart the database
Shutdown immediate
startup
