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
