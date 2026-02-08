User Management - I
===================
create user u1 identified by u1 
default tablespace tbs1
temporary tablespace temp
quota unlimited on tbs1
quota 5m on tbs2
password expire
account lock;

Assigning the quota to the user on another tablespace
=====================================================
alter user u1 quota 10m on tbs2;

To unlock the account
=====================
alter user u1 account unlock;

To unlock the account and change the pwd at the same time
=========================================================
alter user scott identified by tiger account unlock;

To force user to change the password
====================================
alter user u1 password expire;

To create the user and grant roles at the same time
===================================================
grant connect, resource to u1 identified by u1;

Granting privileges to users separately
=======================================
grant create session, create table, create sequence to u1;
conn u1/u1;
select * from session_privs;
select * from role_sys_privs;
select * from role_sys_privs order by  1;

Creating and assigning the custom roles
=======================================
create role role1;
grant create session, create table, create sequence to role1;
grant role1 to u1;
select role, privilege from role_sys_privs where role='ROLE1';
select * from dba_role_privs where granted_role='ROLE1';

Assigning object privileges on a table to other users
=====================================================
connect scott/tiger
grant select, insert, update on emp to u1;
conn u1/u1;
show user;
select * from scott.emp;


connect / as sysdba
show user;

set linesize 300
set pagesize 100
column grantee format a10
column owner format a10
column grantor format a10
column table_name format a15
column privilege format a15
select grantee, owner, grantor, table_name, privilege 
from dba_tab_privs
where owner = 'SCOTT';


Checking the privileges for the user
====================================
connect / as sysdba
select role, privilege from role_sys_privs where role='ROLE1';
select grantee, privilege from dba_sys_privs where grantee='U1';

Revoking the privileges from user
=================================
conn / as sysdba
revoke select, insert, update on scott.emp from u1;
to confirm the revoke:
select grantee, owner, grantor, table_name, privilege 
from dba_tab_privs
where owner = 'SCOTT';

Some of the key needed roles (predefined)
=========================================
connect, resource, dba, exp_full_database, imp_full_database
to use data pump we need below roles:
DATAPUMP_EXP_FULL_DATABASE
DATAPUMP_IMP_FULL_DATABASE

Dropping the user Account
=========================
If the user schema contains no db objects:
drop user u1;
If the user schema contains db objects:
drop user u1 cascade;


Important view related to users and roles
dba_users

set linesize 300 
set pagesize 100
select username,account_status,default_tablespace,temporary_tablespace,created 
from dba_users;

user_users
select username, account_status, lock_date, expiry_date, created, default_tablespace, temporary_tablespace 
from user_users;

all_users
select * from all_users order by 3;
dba_ts_quotas
select username, tablespace_name, bytes, max_bytes, blocks, max_blocks
from dba_ts_quotas;

user_ts_quotas
select tablespace_name, bytes, blocks from user_ts_quotas;
select * from user_ts_quotas;

role_sys_privs
select role, privilege, admin_option from role_sys_privs;

dba_role_privs
select grantee, granted_role, admin_option, default_role from dba_role_privs;

dba_sys_privs
select grantee, privilege, admin_option from dba_sys_privs;

dba_tab_privs
select grantee, owner, table_name, grantor, privilege from dba_tab_privs;
select grantee, owner, table_name, grantor, privilege from dba_tab_privs
where owner='SCOTT';

role_tab_privs
select role, owner, table_name, column_name, privilege from role_tab_privs;

dba_roles
select role, password_required, authentication_type from dba_roles;

role_sys_privs
select role, privilege, admin_option from role_sys_privs;


Session Management
Monitoring
desc v$session;
select count(*) from v$session where username is not null;
select username, sid, serial#
from v$session where username is not null;

To get session details

column username format a15
alter session set nls_date_format='DD-MM-YYYY HH24:MI:SS';

select username, sid, serial#, status, logon_time
from v$session
where username is not null;

Userwise Sessions
select username, count(*) from v$session group by username;
select username,pid,pname from v$process;

Joining v$process and v$session
select a.sid, a.serial#, a.username, b.pid, b.spid
from v$session a, v$process b
where a.paddr = b.addr
and a.username = 'SYS';

select username, to_char(logon_time, 'hh24:mi:ss dd-mm-yyyy'),
sid, serial#
from v$session
where sid = 138;

Killing Session at database level
alter system kill session 'SID, SERIAL#';
alter system kill session '23,78';

Killing session from OS level
ps -ef | grep pmon
kill -9 3657

Important v$ views
v$process
V$PROCESS displays information about the currently active processes. While the LATCHWAIT column indicates what latch a process is waiting for, the LATCHSPIN column indicates what latch a process is spinning on. On multi-processor machines, Oracle processes will spin on a latch before waiting on it.

v$session	: V$SESSION displays session information for each current session.

Table 9-2 COMMAND Column of V$SESSION and Corresponding Commands
Number	Command			Number	Command
1		CREATE TABLE	2		INSERT
3		SELECT			4		CREATE CLUSTER
5		ALTER CLUSTER	6		UPDATE
7		DELETE			8		DROP CLUSTER
9		CREATE INDEX	10		DROP INDEX
11		ALTER INDEX		12		DROP TABLE
13		CREATE SEQUENCE	14		ALTER SEQUENCE
15	ALTER TABLE			16		DROP SEQUENCE
17	GRANT OBJECT		18		REVOKE OBJECT
19	CREATE SYNONYM		20		DROP SYNONYM
21	CREATE VIEW			22		DROP VIEW
23	VALIDATE INDEX		24		CREATE PROCEDURE
25	ALTER PROCEDURE		26		LOCK
27	NO-OP				28		RENAME
29	COMMENT				30		AUDIT OBJECT
31	NOAUDIT OBJECT		32		CREATE DATABASE LINK
33	DROP DATABASE LINK	34		CREATE DATABASE
35	ALTER DATABASE		36		CREATE ROLLBACK SEG
37	ALTER ROLLBACK SEG	38		DROP ROLLBACK SEG
39	CREATE TABLESPACE	40		ALTER TABLESPACE
41	DROP TABLESPACE		42		ALTER SESSION
43	ALTER USER			44		COMMIT
45	ROLLBACK			46		SAVEPOINT
47	PL/SQL EXECUTE		48		SET TRANSACTION
49	ALTER SYSTEM		50		EXPLAIN
51	CREATE USER			52		CREATE ROLE
53	DROP USER			54		DROP ROLE
55	SET ROLE			56		CREATE SCHEMA
57	CREATE CONTROL FILE	59		CREATE TRIGGER
60	ALTER TRIGGER		61		DROP TRIGGER
62	ANALYZE TABLE		63		ANALYZE INDEX
64	ANALYZE CLUSTER		65		CREATE PROFILE
66	DROP PROFILE		67		ALTER PROFILE
68	DROP PROCEDURE		70		ALTER RESOURCE COST
71	CREATE MATERIALIZED VIEW LOG	72	ALTER MATERIALIZED VIEW LOG
73	DROP MATERIALIZED VIEW LOG		74	CREATE MATERIALIZED VIEW
75	ALTER MATERIALIZED VIEW			76	DROP MATERIALIZED VIEW
77	CREATE TYPE			78		DROP TYPE
79	ALTER ROLE			80		ALTER TYPE
81	CREATE TYPE BODY	82		ALTER TYPE BODY
83	DROP TYPE BODY		84		DROP LIBRARY
85	TRUNCATE TABLE		86		TRUNCATE CLUSTER
91	CREATE FUNCTION		92		ALTER FUNCTION
93	DROP FUNCTION		94		CREATE PACKAGE
95	ALTER PACKAGE		96		DROP PACKAGE
97	CREATE PACKAGE BODY	98		ALTER PACKAGE BODY
99	DROP PACKAGE BODY	100		LOGON
101	LOGOFF				102		LOGOFF BY CLEANUP
103	SESSION REC			104		SYSTEM AUDIT
105	SYSTEM NOAUDIT		106		AUDIT DEFAULT
107	NOAUDIT DEFAULT		108		SYSTEM GRANT
109	SYSTEM REVOKE		110	 	CREATE PUBLIC SYNONYM
111	DROP PUBLIC SYNONYM	112		CREATE PUBLIC DATABASE LINK
113	DROP PUBLIC DATABASE LINK	114	GRANT ROLE
115	REVOKE ROLE			116		EXECUTE PROCEDURE
117	USER COMMENT		118		ENABLE TRIGGER
119	DISABLE TRIGGER		120		ENABLE ALL TRIGGERS
121	DISABLE ALL TRIGGERS	122	NETWORK ERROR
123	EXECUTE TYPE		157		CREATE DIRECTORY
158	DROP DIRECTORY		159		CREATE LIBRARY
160	CREATE JAVA			161		ALTER JAVA
162	DROP JAVA			163		CREATE OPERATOR
164	CREATE INDEXTYPE	165		DROP INDEXTYPE
167	DROP OPERATOR		168		ASSOCIATE STATISTICS
169	DISASSOCIATE STATISTICS	170	CALL METHOD
171	CREATE SUMMARY		172		ALTER SUMMARY
173	DROP SUMMARY		174		CREATE DIMENSION
175	ALTER DIMENSION		176		DROP DIMENSION
177	CREATE CONTEXT		178		DROP CONTEXT
179	ALTER OUTLINE		180		CREATE OUTLINE
181	DROP OUTLINE		182		UPDATE INDEXES
183	ALTER OPERATOR	 	 



v$sqlarea		: V$SQLAREA displays statistics on shared SQL areas and contains 
				one row per SQL string. It provides statistics on SQL statements 
				that are in memory, parsed, and ready for execution.

v$sqltext		: This view contains the text of SQL statements belonging to shared SQL cursors in the SGA.

v$lock			: This view lists the locks currently held by the Oracle Database 
				  and outstanding requests for a lock or latch.
				  The locks on the system types are held for extremely short periods 
				  of time.

v$session_wait	: V$SESSION_WAIT displays the current or last wait for each session.

v$sess_io		: This view lists I/O statistics for each user session.




USER MANAGEMENT - II
====================
Creating Password file for instance
$orapwd file=orapw(sid) password=(pwd) force=y ignorecase=y entries=(total users pwd to be stored)
$orapwd file=orapwdb1 password=manager force=y ignorecase=y entries=5

Assigning sysdba and sysoper privileges to user
grant sysdba to u1;
grant sysoper to u1;
sqlplus u1/u1 as sysdba;
show user;
SYS

sqlplus u1/u1 as sysoper
show user;
PUBLIC

select * from v$pwfile_users;

Creating Profile
================
create profile prof1 limit
	failed_login_attempts 3		(no of attempts)
	password_lock_time 1		(no of days) (1/24 for 1 hour)
	password_life_time 7		(no of days)
	sessions_per_user 5			(no of total sessions)
	idle_time 1				(in minutes)
	connect_time 600;			(10 hours, in minutes)

create profile prof1 limit
	failed_login_attempts 3
	password_lock_time 1
	password_life_time 7
	sessions_per_user 5
	idle_time 15
	connect_time 600;

Assigning Profile
=================
create user u2 identified by u2 profile prof1;
alter user u1 profile prof1;

desc dba_profiles;

set linesize 300
select * from dba_profiles where profile='PROF1';
select resource_name, limit from dba_profiles where profile='PROF1';
select username, profile from dba_users where profile='PROF1';
alter profile prof1 limit password_lock_time 2;
select * from dba_profiles where profile='PROF1';

To enforce kernel/resource parameters the following parameter must be set
alter system set resource_limit=true scope=both;

Applying password restriction in profile
@$ORACLE_HOME/rdbms/admin/utlpwdmg.sql;
alter profile default limit password_verify_function null;
alter profile prof1 limit password_verify_function verify_function;

alter profile prof1 limit password_verify_function null;

By default password is case sensitive, to disable it set the following parameter to false
sec_case_sensitive_logon = false
alter system set sec_case_sensitive_logon=true scope=both;
