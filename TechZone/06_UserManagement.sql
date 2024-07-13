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
alter user u1 quota 10m on tbs2;

To unlock the account
alter user u1 account unlock;

To unlock the account and change the pwd at the same time
alter user scott identified by tiger account unlock;

To force user to change the password
alter user u1 password expire;

To create the user and grant roles at the same time
grant connect, resource to u1 identified by u1;

Granting privileges to users separately
grant create session, create table, create sequence to u1;
conn u1/u1;
select * from session_privs;
select * from role_sys_privs;
select * from role_sys_privs order by  1;

Creating and assigning the custom roles
create role role1;
grant create session, create table, create sequence to role1;
grant role1 to u1;
select role, privilege from role_sys_privs where role='ROLE1';
select * from dba_role_privs where granted_role='ROLE1';

Assigning object privileges on a table to other users
connect scott/tiger
grant select, insert, update on emp to u1;
conn u1/u1;
show user;
select * from scott.emp;


connect / as sysdba
show user;
column grantee format a10
column owner format a10
column grantor format a10
column table_name format a15
column privilege format a15
select grantee, owner, grantor, table_name, privilege 
from dba_tab_privs
where owner = 'SCOTT';


Checking the privileges for the user
connect / as sysdba
select role, privilege from role_sys_privs where role='ROLE1';
select grantee, privilege from dba_sys_privs where grantee='U1';

Revoking the privileges from user
conn / as sysdba
revoke select, insert, update on scott.emp from u1;
to confirm the revoke:
select grantee, owner, grantor, table_name, privilege 
from dba_tab_privs
where owner = 'SCOTT';

Some of the key needed roles (predefined)
connect, resource, dba, exp_full_database, imp_full_database
to use data pump we need below roles:
DATAPUMP_EXP_FULL_DATABASE
DATAPUMP_IMP_FULL_DATABASE

Dropping the user Account
If the user schema contains no db objects:
drop user u1;
If the user schema contains db objects:
drop user u1 cascade;


Important view related to users and roles
dba_users
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
Column	Datatype	Description
ADDR	RAW(4 | 8)	Address of the process state object
PID	NUMBER	Oracle process identifier
SPID	VARCHAR2(24)	Operating system process identifier
USERNAME	VARCHAR2(15)	Operating system process username
Note: Any two-task user coming across the network has "-T" appended to the username.
SERIAL#	NUMBER	Process serial number
TERMINAL	VARCHAR2(30)	Operating system terminal identifier
PROGRAM	VARCHAR2(48)	Program in progress
TRACEID	VARCHAR2(255)	Trace file identifier
TRACEFILE	VARCHAR2(513)	Trace file name of the process
BACKGROUND	VARCHAR2(1)	1 for a background process; NULL for a normal process
LATCHWAIT	VARCHAR2(8)	Address of the latch the process is waiting for; NULL if none
LATCHSPIN	VARCHAR2(8)	Address of the latch the process is spinning on; NULL if none
PGA_USED_MEM	NUMBER	PGA memory currently used by the process
PGA_ALLOC_MEM	NUMBER	PGA memory currently allocated by the process (including free PGA memory not yet released to the operating system by the server process)
PGA_FREEABLE_MEM	NUMBER	Allocated PGA memory which can be freed
PGA_MAX_MEM	NUMBER	Maximum PGA memory ever allocated by the process


v$session
V$SESSION displays session information for each current session.
Column	Datatype	Description
SADDR	RAW(4 | 8)	Session address
SID	NUMBER	Session identifier
SERIAL#	NUMBER	Session serial number. Used to uniquely identify a session's objects. Guarantees that session-level commands are applied to the correct session objects if the session ends and another session begins with the same session ID.
AUDSID	NUMBER	Auditing session ID
PADDR	RAW(4 | 8)	Address of the process that owns the session
USER#	NUMBER	Oracle user identifier
USERNAME	VARCHAR2(30)	Oracle username
COMMAND	NUMBER	Command in progress (last statement parsed); for a list of values, see Table 9-2. These values also appear in the AUDIT_ACTIONS table.
OWNERID	NUMBER	Identifier of the user who owns the migratable session; the column contents are invalid if the value is 2147483644
For operations using Parallel Slaves, interpret this value as a 4-byte value. The low-order 2 bytes represent the session number and the high-order bytes represent the instance ID of the query coordinator.
TADDR	VARCHAR2(8)	Address of the transaction state object
LOCKWAIT	VARCHAR2(8)	Address of the lock the session is waiting for; NULL if none
STATUS	VARCHAR2(8)	Status of the session:
•	ACTIVE - Session currently executing SQL
•	INACTIVE
•	KILLED - Session marked to be killed
•	CACHED - Session temporarily cached for use by Oracle*XA
•	SNIPED - Session inactive, waiting on the client
SERVER	VARCHAR2(9)	Server type:
•	DEDICATED
•	SHARED
•	PSEUDO
•	NONE
SCHEMA#	NUMBER	Schema user identifier
SCHEMANAME	VARCHAR2(30)	Schema user name
OSUSER	VARCHAR2(30)	Operating system client user name
PROCESS	VARCHAR2(24)	Operating system client process ID
MACHINE	VARCHAR2(64)	Operating system machine name
TERMINAL	VARCHAR2(30)	Operating system terminal name
PROGRAM	VARCHAR2(48)	Operating system program name
TYPE	VARCHAR2(10)	Session type
SQL_ADDRESS	RAW(4 | 8)	Used with SQL_HASH_VALUEto identify the SQL statement that is currently being executed
SQL_HASH_VALUE	NUMBER	Used with SQL_ADDRESS to identify the SQL statement that is currently being executed
SQL_ID	VARCHAR2(13)	SQL identifier of the SQL statement that is currently being executed
SQL_CHILD_NUMBER	NUMBER	Child number of the SQL statement that is currently being executed
SQL_EXEC_START	DATE	Time when the execution of the SQL currently executed by this session started; NULL if SQL_ID is NULL
SQL_EXEC_ID	NUMBER	SQL execution identifier; NULL if SQL_ID is NULL or if the execution of that SQL has not yet started (see V$SQL_MONITOR)
PREV_SQL_ADDR	RAW(4 | 8)	Used with PREV_HASH_VALUEto identify the last SQL statement executed
PREV_HASH_VALUE	NUMBER	Used with SQL_HASH_VALUEto identify the last SQL statement executed
PREV_SQL_ID	VARCHAR2(13)	SQL identifier of the last SQL statement executed
PREV_CHILD_NUMBER	NUMBER	Child number of the last SQL statement executed
PREV_EXEC_START	DATE	SQL execution start of the last executed SQL statement
PREV_EXEC_ID	NUMBER	SQL execution identifier of the last executed SQL statement
PLSQL_ENTRY_OBJECT_ID	NUMBER	Object ID of the top-most PL/SQL subprogram on the stack; NULL if there is no PL/SQL subprogram on the stack
PLSQL_ENTRY_SUBPROGRAM_ID	NUMBER	Subprogram ID of the top-most PL/SQL subprogram on the stack; NULL if there is no PL/SQL subprogram on the stack
PLSQL_OBJECT_ID	NUMBER	Object ID of the currently executing PL/SQL subprogram; NULL if executing SQL
PLSQL_SUBPROGRAM_ID	NUMBER	Subprogram ID of the currently executing PL/SQL object; NULL if executing SQL
MODULE	VARCHAR2(48)	Name of the currently executing module as set by calling the DBMS_APPLICATION_INFO.SET_MODULE procedure
MODULE_HASH	NUMBER	Hash value of the MODULEcolumn
ACTION	VARCHAR2(32)	Name of the currently executing action as set by calling the DBMS_APPLICATION_INFO.SET_ACTION procedure
ACTION_HASH	NUMBER	Hash value of the ACTIONcolumn
CLIENT_INFO	VARCHAR2(64)	Information set by the DBMS_APPLICATION_INFO.SET_CLIENT_INFO procedure
FIXED_TABLE_SEQUENCE	NUMBER	This contains a number that increases every time the session completes a call to the database and there has been an intervening select from a dynamic performance table. This column can be used by performance monitors to monitor statistics in the database. Each time the performance monitor looks at the database, it only needs to look at sessions that are currently active or have a higher value in this column than the highest value that the performance monitor saw the last time. All the other sessions have been idle since the last time the performance monitor looked at the database.
ROW_WAIT_OBJ#	NUMBER	Object ID for the table containing the row specified in ROW_WAIT_ROW#
ROW_WAIT_FILE#	NUMBER	Identifier for the datafile containing the row specified in ROW_WAIT_ROW#. This column is valid only if the session is currently waiting for another transaction to commit and the value of ROW_WAIT_OBJ# is not -1.
ROW_WAIT_BLOCK#	NUMBER	Identifier for the block containing the row specified in ROW_WAIT_ROW#. This column is valid only if the session is currently waiting for another transaction to commit and the value of ROW_WAIT_OBJ# is not -1.
ROW_WAIT_ROW#	NUMBER	Current row being locked. This column is valid only if the session is currently waiting for another transaction to commit and the value of ROW_WAIT_OBJ# is not -1.
LOGON_TIME	DATE	Time of logon
LAST_CALL_ET	NUMBER	If the session STATUS is currently ACTIVE, then the value represents the elapsed time (in seconds) since the session has become active.
If the session STATUS is currently INACTIVE, then the value represents the elapsed time (in seconds) since the session has become inactive.
PDML_ENABLED	VARCHAR2(3)	This column has been replaced by the PDML_STATUS column
FAILOVER_TYPE	VARCHAR2(13)	Indicates whether and to what extent transparent application failover (TAF) is enabled for the session:
•	NONE - Failover is disabled for this session
•	SESSION - Client is able to fail over its session following a disconnect
•	SELECT - Client is able to fail over queries in progress as well
FAILOVER_METHOD	VARCHAR2(10)	Indicates the transparent application failover method for the session:
•	NONE - Failover is disabled for this session
•	BASIC - Client itself reconnects following a disconnect
•	PRECONNECT - Backup instance can support all connections from every instance for which it is backed up
FAILED_OVER	VARCHAR2(3)	Indicates whether the session is running in failover mode and failover has occurred (YES) or not (NO)
RESOURCE_CONSUMER_GROUP	VARCHAR2(32)	Name of the session's current resource consumer group
PDML_STATUS	VARCHAR2(8)	If ENABLED, the session is in a PARALLEL DML enabled mode. If DISABLED, PARALLEL DML enabled mode is not supported for the session. If FORCED, the session has been altered to force PARALLEL DML.
PDDL_STATUS	VARCHAR2(8)	If ENABLED, the session is in a PARALLEL DDL enabled mode. If DISABLED, PARALLEL DDL enabled mode is not supported for the session. If FORCED, the session has been altered to force PARALLEL DDL.
PQ_STATUS	VARCHAR2(8)	If ENABLED, the session is in a PARALLEL QUERY enabled mode. If DISABLED, PARALLEL QUERY enabled mode is not supported for the session. If FORCED, the session has been altered to force PARALLEL QUERY.
CURRENT_QUEUE_DURATION	NUMBER	If queued (1), the current amount of time the session has been queued. If not currently queued, the value is 0.
CLIENT_IDENTIFIER	VARCHAR2(64)	Client identifier of the session
BLOCKING_SESSION_STATUS	VARCHAR2(11)	Blocking session status:
•	VALID
•	NO HOLDER
•	GLOBAL
•	NOT IN WAIT
•	UNKNOWN
BLOCKING_INSTANCE	NUMBER	Instance identifier of the blocking session
BLOCKING_SESSION	NUMBER	Session identifier of the blocking session
SEQ#	NUMBER	A number that uniquely identifies the current or last wait (incremented for each wait)
EVENT#	NUMBER	Event number
EVENT	VARCHAR2(64)	Resource or event for which the session is waiting
P1TEXT	VARCHAR2(64)	Description of the first wait event parameter
P1	NUMBER	First wait event parameter (in decimal)
P1RAW	RAW(8)	First wait event parameter (in hexadecimal) 
P2TEXT	VARCHAR2(64)	Description of the second wait event parameter
P2	NUMBER	Second wait event parameter (in decimal)
P2RAW	RAW(8)	Second wait event parameter (in hexadecimal) 
P3TEXT	VARCHAR2(64)	Description of the third wait event parameter
P3	NUMBER	Third wait event parameter (in decimal)
P3RAW	RAW(8)	Third wait event parameter (in hexadecimal) 
WAIT_CLASS_ID	NUMBER	Identifier of the class of the wait event
WAIT_CLASS#	NUMBER	Number of the class of the wait event
WAIT_CLASS	VARCHAR2(64)	Name of the class of the wait event
WAIT_TIME	NUMBER	If the session is currently waiting, then the value is 0. If the session is not in a wait, then the value is as follows:
•	> 0 - Value is the duration of the last wait in hundredths of a second
•	-1 - Duration of the last wait was less than a hundredth of a second
•	-2 - Parameter TIMED_STATISTICS was set to false
This column has been deprecated in favor of the columns WAIT_TIME_MICROand STATE.
SECONDS_IN_WAIT	NUMBER	If the session is currently waiting, then the value is the amount of time waited for the current wait. If the session is not in a wait, then the value is the amount of time since the start of the last wait.
This column has been deprecated in favor of the columns WAIT_TIME_MICROand TIME_SINCE_LAST_WAIT_MICRO.
STATE	VARCHAR2(19)	Wait state:
•	WAITING - Session is currently waiting
•	WAITED UNKNOWN TIME - Duration of the last wait is unknown; this is the value when the parameter TIMED_STATISTICS is set to false
•	WAITED SHORT TIME - Last wait was less than a hundredth of a second
•	WAITED KNOWN TIME - Duration of the last wait is specified in the WAIT_TIMEcolumn
WAIT_TIME_MICRO	NUMBER	Amount of time waited (in microseconds). If the session is currently waiting, then the value is the time spent in the current wait. If the session is currently not in a wait, then the value is the amount of time waited in the last wait.
TIME_REMAINING_MICRO	NUMBER	Value is interpreted as follows:
•	> 0 - Amount of time remaining for the current wait (in microseconds)
•	0 - Current wait has timed out
•	-1 - Session can indefinitely wait in the current wait
•	NULL - Session is not currently waiting
TIME_SINCE_LAST_WAIT_MICRO	NUMBER	Time elapsed since the end of the last wait (in microseconds). If the session is currently in a wait, then the value is 0.
SERVICE_NAME	VARCHAR2(64)	Service name of the session
SQL_TRACE	VARCHAR2(8)	Indicates whether SQL tracing is enabled (ENABLED) or disabled (DISABLED)
SQL_TRACE_WAITS	VARCHAR2(5)	Indicates whether wait tracing is enabled (TRUE) or not (FALSE)
SQL_TRACE_BINDS	VARCHAR2(5)	Indicates whether bind tracing is enabled (TRUE) or not (FALSE)
SQL_TRACE_PLAN_STATS	VARCHAR2(10)	Frequency at which row source statistics are dumped in the trace files for each cursor:
•	never
•	first_execution
•	all_executions
SESSION_EDITIONID	NUMBER	Reserved for future use
CREATOR_ADDR	RAW(4 | 8)	Address of the creating process or circuit
CREATOR_SERIAL#	NUMBER	Serial number of the creating process or circuit

Table 9-2 COMMAND Column of V$SESSION and Corresponding Commands
Number	Command	Number	Command
1	CREATE TABLE	2	INSERT
3	SELECT	4	CREATE CLUSTER
5	ALTER CLUSTER	6	UPDATE
7	DELETE	8	DROP CLUSTER
9	CREATE INDEX	10	DROP INDEX
11	ALTER INDEX	12	DROP TABLE
13	CREATE SEQUENCE	14	ALTER SEQUENCE
15	ALTER TABLE	16	DROP SEQUENCE
17	GRANT OBJECT	18	REVOKE OBJECT
19	CREATE SYNONYM	20	DROP SYNONYM
21	CREATE VIEW	22	DROP VIEW
23	VALIDATE INDEX	24	CREATE PROCEDURE
25	ALTER PROCEDURE	26	LOCK
27	NO-OP	28	RENAME
29	COMMENT	30	AUDIT OBJECT
31	NOAUDIT OBJECT	32	CREATE DATABASE LINK
33	DROP DATABASE LINK	34	CREATE DATABASE
35	ALTER DATABASE	36	CREATE ROLLBACK SEG
37	ALTER ROLLBACK SEG	38	DROP ROLLBACK SEG
39	CREATE TABLESPACE	40	ALTER TABLESPACE
41	DROP TABLESPACE	42	ALTER SESSION
43	ALTER USER	44	COMMIT
45	ROLLBACK	46	SAVEPOINT
47	PL/SQL EXECUTE	48	SET TRANSACTION
49	ALTER SYSTEM	50	EXPLAIN
51	CREATE USER	52	CREATE ROLE
53	DROP USER	54	DROP ROLE
55	SET ROLE	56	CREATE SCHEMA
57	CREATE CONTROL FILE	59	CREATE TRIGGER
60	ALTER TRIGGER	61	DROP TRIGGER
62	ANALYZE TABLE	63	ANALYZE INDEX
64	ANALYZE CLUSTER	65	CREATE PROFILE
66	DROP PROFILE	67	ALTER PROFILE
68	DROP PROCEDURE	70	ALTER RESOURCE COST
71	CREATE MATERIALIZED VIEW LOG	72	ALTER MATERIALIZED VIEW LOG
73	DROP MATERIALIZED VIEW LOG	74	CREATE MATERIALIZED VIEW
75	ALTER MATERIALIZED VIEW	76	DROP MATERIALIZED VIEW
77	CREATE TYPE	78	DROP TYPE
79	ALTER ROLE	80	ALTER TYPE
81	CREATE TYPE BODY	82	ALTER TYPE BODY
83	DROP TYPE BODY	84	DROP LIBRARY
85	TRUNCATE TABLE	86	TRUNCATE CLUSTER
91	CREATE FUNCTION	92	ALTER FUNCTION
93	DROP FUNCTION	94	CREATE PACKAGE
95	ALTER PACKAGE	96	DROP PACKAGE
97	CREATE PACKAGE BODY	98	ALTER PACKAGE BODY
99	DROP PACKAGE BODY	100	LOGON
101	LOGOFF	102	LOGOFF BY CLEANUP
103	SESSION REC	104	SYSTEM AUDIT
105	SYSTEM NOAUDIT	106	AUDIT DEFAULT
107	NOAUDIT DEFAULT	108	SYSTEM GRANT
109	SYSTEM REVOKE	110	CREATE PUBLIC SYNONYM
111	DROP PUBLIC SYNONYM	112	CREATE PUBLIC DATABASE LINK
113	DROP PUBLIC DATABASE LINK	114	GRANT ROLE
115	REVOKE ROLE	116	EXECUTE PROCEDURE
117	USER COMMENT	118	ENABLE TRIGGER
119	DISABLE TRIGGER	120	ENABLE ALL TRIGGERS
121	DISABLE ALL TRIGGERS	122	NETWORK ERROR
123	EXECUTE TYPE	157	CREATE DIRECTORY
158	DROP DIRECTORY	159	CREATE LIBRARY
160	CREATE JAVA	161	ALTER JAVA
162	DROP JAVA	163	CREATE OPERATOR
164	CREATE INDEXTYPE	165	DROP INDEXTYPE
167	DROP OPERATOR	168	ASSOCIATE STATISTICS
169	DISASSOCIATE STATISTICS	170	CALL METHOD
171	CREATE SUMMARY	172	ALTER SUMMARY
173	DROP SUMMARY	174	CREATE DIMENSION
175	ALTER DIMENSION	176	DROP DIMENSION
177	CREATE CONTEXT	178	DROP CONTEXT
179	ALTER OUTLINE	180	CREATE OUTLINE
181	DROP OUTLINE	182	UPDATE INDEXES
183	ALTER OPERATOR	 	 



v$sqlarea
V$SQLAREA displays statistics on shared SQL areas and contains one row per SQL string. It provides statistics on SQL statements that are in memory, parsed, and ready for execution.
Column	Datatype	Description
SQL_TEXT	VARCHAR2(1000)	First thousand characters of the SQL text for the current cursor
SQL_FULLTEXT	CLOB	All characters of the SQL text for the current cursor
SQL_ID	VARCHAR2(13)	SQL identifier of the parent cursor in the library cache
SHARABLE_MEM	NUMBER	Amount of shared memory used by a cursor. If multiple child cursors exist, then the sum of all shared memory used by all child cursors.
PERSISTENT_MEM	NUMBER	Fixed amount of memory used for the lifetime of an open cursor. If multiple child cursors exist, then the fixed sum of memory used for the lifetime of all the child cursors.
RUNTIME_MEM	NUMBER	Fixed amount of memory required during execution of a cursor. If multiple child cursors exist, then the fixed sum of all memory required during execution of all the child cursors.
SORTS	NUMBER	Sum of the number of sorts that were done for all the child cursors
VERSION_COUNT	NUMBER	Number of child cursors that are present in the cache under this parent
LOADED_VERSIONS	NUMBER	Number of child cursors that are present in the cache and have their context heap loaded
OPEN_VERSIONS	NUMBER	Number of child cursors that are currently open under this current parent
USERS_OPENING	NUMBER	Number of users that have any of the child cursors open
FETCHES	NUMBER	Number of fetches associated with the SQL statement
EXECUTIONS	NUMBER	Total number of executions, totalled over all the child cursors
PX_SERVERS_EXECUTIONS	NUMBER	Total number of executions performed by parallel execution servers (0 when the statement has never been executed in parallel)
END_OF_FETCH_COUNT	NUMBER	Number of times this cursor was fully executed since the cursor was brought into the library cache. The value of this statistic is not incremented when the cursor is partially executed, either because it failed during the execution or because only the first few rows produced by this cursor are fetched before the cursor is closed or re-executed. By definition, the value of the END_OF_FETCH_COUNTcolumn should be less or equal to the value of the EXECUTIONS column.
USERS_EXECUTING	NUMBER	Total number of users executing the statement over all child cursors
LOADS	NUMBER	Number of times the object was loaded or reloaded
FIRST_LOAD_TIME	VARCHAR2(19)	Timestamp of the parent creation time
INVALIDATIONS	NUMBER	Total number of invalidations over all the child cursors
PARSE_CALLS	NUMBER	Sum of all parse calls to all the child cursors under this parent
DISK_READS	NUMBER	Sum of the number of disk reads over all child cursors
DIRECT_WRITES	NUMBER	Sum of the number of direct writes over all child cursors
BUFFER_GETS	NUMBER	Sum of buffer gets over all child cursors
APPLICATION_WAIT_TIME	NUMBER	Application wait time (in microseconds)
CONCURRENCY_WAIT_TIME	NUMBER	Concurrency wait time (in microseconds)
CLUSTER_WAIT_TIME	NUMBER	Cluster wait time (in microseconds)
USER_IO_WAIT_TIME	NUMBER	User I/O Wait Time (in microseconds)
PLSQL_EXEC_TIME	NUMBER	PL/SQL execution time (in microseconds)
JAVA_EXEC_TIME	NUMBER	Java execution time (in microseconds)
ROWS_PROCESSED	NUMBER	Total number of rows processed on behalf of this SQL statement
COMMAND_TYPE	NUMBER	Oracle command type definition
OPTIMIZER_MODE	VARCHAR2(10)	Mode under which the SQL statement was executed
OPTIMIZER_COST	NUMBER	Cost of this query given by the optimizer
OPTIMIZER_ENV	RAW(2000)	Optimizer environment
OPTIMIZER_ENV_HASH_VALUE	NUMBER	Hash value for the optimizer environment
PARSING_USER_ID	NUMBER	User ID of the user that has parsed the very first cursor under this parent
PARSING_SCHEMA_ID	NUMBER	Schema ID that was used to parse this child cursor
PARSING_SCHEMA_NAME	VARCHAR2(30)	Schema name that was used to parse this child cursor
KEPT_VERSIONS	NUMBER	Number of child cursors that have been marked to be kept using the DBMS_SHARED_POOLpackage
ADDRESS	RAW(4 | 8)	Address of the handle to the parent for this cursor
HASH_VALUE	NUMBER	Hash value of the parent statement in the library cache
OLD_HASH_VALUE	NUMBER	Old SQL hash value
PLAN_HASH_VALUE	NUMBER	Numeric representation of the SQL plan for this cursor. Comparing one PLAN_HASH_VALUE to another easily identifies whether or not two plans are the same (rather than comparing the two plans line by line).
MODULE	VARCHAR2(64)	Contains the name of the module that was executing at the time that the SQL statement was first parsed as set by calling DBMS_APPLICATION_INFO.SET_MODULE
MODULE_HASH	NUMBER	Hash value of the module that is named in the MODULE column
ACTION	VARCHAR2(64)	Contains the name of the action that was executing at the time that the SQL statement was first parsed as set by calling DBMS_APPLICATION_INFO.SET_ACTION
ACTION_HASH	NUMBER	Hash value of the action that is named in the ACTION column
SERIALIZABLE_ABORTS	NUMBER	Number of times the transaction failed to serialize, producing ORA-08177 errors, totalled over all the child cursors
OUTLINE_CATEGORY	VARCHAR2(64)	If an outline was applied during construction of the cursor, then this column displays the category of that outline. Otherwise the column is left blank.
CPU_TIME	NUMBER	CPU time (in microseconds) used by this cursor for parsing, executing, and fetching
ELAPSED_TIME	NUMBER	Elapsed time (in microseconds) used by this cursor for parsing, executing, and fetching. If the cursor uses parallel execution, then ELAPSED_TIME is the cumulative time for the query coordinator, plus all parallel query slave processes.
OUTLINE_SID	VARCHAR2(40)	Outline session identifier
LAST_ACTIVE_CHILD_ADDRESS	RAW(4 | 8)	Address (identifier) of the child cursor that was the last to be active in the group (that is, the child cursor on behalf of which statistics in V$SQL were updated)
REMOTE	VARCHAR2(1)	Indicates whether the cursor is remote mapped (Y) or not (N)
OBJECT_STATUS	VARCHAR2(19)	Status of the cursor:
•	VALID - Valid, authorized without errors
•	VALID_AUTH_ERROR - Valid, authorized with authorization errors
•	VALID_COMPILE_ERROR - Valid, authorized with compilation errors
•	VALID_UNAUTH - Valid, unauthorized
•	INVALID_UNAUTH - Invalid, unauthorized
•	INVALID - Invalid, unauthorized but keep the timestamp
LITERAL_HASH_VALUE	NUMBER	Hash value of the literals which are replaced with system-generated bind variables and are to be matched, when CURSOR_SHARING is used. This is not the hash value for the SQL statement. If CURSOR_SHARING is not used, then the value is 0.
LAST_LOAD_TIME	DATE	Time at which the query plan was loaded into the library cache
IS_OBSOLETE	VARCHAR2(1)	Indicates whether the cursor has become obsolete (Y) or not (N). This can happen if the number of child cursors is too large.
IS_BIND_SENSITIVE	VARCHAR2(1)	Indicates whether the cursor is bind sensitive (Y) or not (N). A query is considered bind-sensitive if the optimizer peeked at one of its bind variable values when computing predicate selectivities and where a change in a bind variable value may cause the optimizer to generate a different plan.
IS_BIND_AWARE	VARCHAR2(1)	Indicates whether the cursor is bind aware (Y) or not (N). A query is considered bind-aware if it has been marked to use extended cursor sharing. The query would already have been marked as bind-sensitive.
CHILD_LATCH	NUMBER	Child latch number that is protecting the cursor. This column is obsolete and maintained for backward compatibility.
SQL_PROFILE	VARCHAR2(64)	SQL profile used for this statement, if any
SQL_PATCH	VARCHAR2(30)	SQL patch used for this statement, if any
SQL_PLAN_BASELINE	VARCHAR2(30)	SQL plan baseline used for this statement, if any
PROGRAM_ID	NUMBER	Program identifier
PROGRAM_LINE#	NUMBER	Program line number
EXACT_MATCHING_SIGNATURE	NUMBER	Signature used when the CURSOR_SHARING parameter is set to EXACT
FORCE_MATCHING_SIGNATURE	NUMBER	Signature used when the CURSOR_SHARING parameter is set to FORCE
LAST_ACTIVE_TIME	DATE	Time at which the query plan was last active
BIND_DATA	RAW(2000)	Bind data
TYPECHECK_MEM	NUMBER	Typecheck memory
IO_CELL_OFFLOAD_ELIGIBLE_BYTES	NUMBER	Number of I/O bytes which can be filtered by the Exadata storage system
See Also: Oracle Exadata Storage Server Software documentation for more information
IO_INTERCONNECT_BYTES	NUMBER	Number of I/O bytes exchanged between Oracle Database and the storage system
PHYSICAL_READ_REQUESTS	NUMBER	Number of physical read I/O requests issued by the monitored SQL
PHYSICAL_READ_BYTES	NUMBER	Number of bytes read from disks by the monitored SQL
PHYSICAL_WRITE_REQUESTS	NUMBER	Number of physical write I/O requests issued by the monitored SQL
PHYSICAL_WRITE_BYTES	NUMBER	Number of bytes written to disks by the monitored SQL
OPTIMIZED_PHY_READ_REQUESTS	NUMBER	Number of physical read I/O requests from Database Smart Flash Cache issued by the monitored SQL
LOCKED_TOTAL	NUMBER	Total number of times the child cursor has been locked
PINNED_TOTAL	NUMBER	Total number of times the child cursor has been pinned
IO_CELL_UNCOMPRESSED_BYTES	NUMBER	Number of uncompressed bytes (that is, size after decompression) that are offloaded to the Exadata cells
See Also: Oracle Exadata Storage Server Software documentation for more information
IO_CELL_OFFLOAD_RETURNED_BYTES	NUMBER	Number of bytes that are returned by Exadata cell through the regular I/O path
See Also: Oracle Exadata Storage Server Software documentation for more information






v$sqltext
This view contains the text of SQL statements belonging to shared SQL cursors in the SGA.
Column	Datatype	Description
ADDRESS	RAW(4 | 8)	Used with HASH_VALUE to uniquely identify a cached cursor
HASH_VALUE	NUMBER	Used with ADDRESS to uniquely identify a cached cursor
SQL_ID	VARCHAR2(13)	SQL identifier of a cached cursor
COMMAND_TYPE	NUMBER	Code for the type of SQL statement (SELECT, INSERT, and so on)
PIECE	NUMBER	Number used to order the pieces of SQL text
SQL_TEXT	VARCHAR2(64)	A column containing one piece of the SQL text




















v$lock
This view lists the locks currently held by the Oracle Database and outstanding requests for a lock or latch.
Column	Datatype	Description
ADDR	RAW(4 | 8)	Address of lock state object
KADDR	RAW(4 | 8)	Address of lock
SID	NUMBER	Identifier for session holding or acquiring the lock
TYPE	VARCHAR2(2)	Type of user or system lock
The locks on the user types are obtained by user applications. Any process that is blocking others is likely to be holding one of these locks. The user type locks are:
TM - DML enqueue
TX - Transaction enqueue
UL - User supplied
The locks on the system types are held for extremely short periods of time. The system type locks are listed in Table 4-1.

ID1	NUMBER	Lock identifier #1 (depends on type)
ID2	NUMBER	Lock identifier #2 (depends on type)
LMODE	NUMBER	Lock mode in which the session holds the lock:
•	0 - none
•	1 - null (NULL)
•	2 - row-S (SS)
•	3 - row-X (SX)
•	4 - share (S)
•	5 - S/Row-X (SSX)
•	6 - exclusive (X)
REQUEST	NUMBER	Lock mode in which the process requests the lock:
•	0 - none
•	1 - null (NULL)
•	2 - row-S (SS)
•	3 - row-X (SX)
•	4 - share (S)
•	5 - S/Row-X (SSX)
•	6 - exclusive (X)
CTIME	NUMBER	Time since current mode was granted
BLOCK	NUMBER	The lock is blocking another lock

Table 4-1 Values for the TYPE Column: System Types
System Type	Description	System Type	Description
BL	Buffer hash table instance	NA..NZ	Library cache pin instance (A..Z = namespace)
CF	Control file schema global enqueue	PF	Password File
CI	Cross-instance function invocation instance	PI, PS	Parallel operation
CU	Cursor bind	PR	Process startup
DF	Data file instance	QA..QZ	Row cache instance (A..Z = cache)
DL	Direct loader parallel index create	RT	Redo thread global enqueue
DM	Mount/startup db primary/secondary instance	SC	System change number instance
DR	Distributed recovery process	SM	SMON
DX	Distributed transaction entry	SN	Sequence number instance
FS	File set	SQ	Sequence number enqueue
HW	Space management operations on a specific segment	SS	Sort segment
IN	Instance number	ST	Space transaction enqueue
IR	Instance recovery serialization global enqueue	SV	Sequence number value
IS	Instance state	TA	Generic enqueue
IV	Library cache invalidation instance	TS	Temporary segment enqueue (ID2=0)
JQ	Job queue	TS	New block allocation enqueue (ID2=1)
KK	Thread kick	TT	Temporary table enqueue
LA .. LP	Library cache lock instance lock (A..P = namespace)	UN	User name
MM	Mount definition global enqueue	US	Undo segment DDL
MR	Media recovery	WL	Being-written redo log instance
























v$session_wait
V$SESSION_WAIT displays the current or last wait for each session.
Column	Datatype	Description
SID	NUMBER	Session identifier; maps to V$SESSION.SID
SEQ#	NUMBER	A number that uniquely identifies the current or last wait (incremented for each wait)
WAIT_ID	NUMBER	Wait identifier
EVENT	VARCHAR2(64)	Resource or event for which the session is waiting
P1TEXT	VARCHAR2(64)	Description of the first wait event parameter
P1	NUMBER	First wait event parameter (in decimal)
P1RAW	RAW(8)	First wait event parameter (in hexadecimal)Foot 1 

P2TEXT	VARCHAR2(64)	Description of the second wait event parameter
P2	NUMBER	Second wait event parameter (in decimal)
P2RAW	RAW(8)	Second wait event parameter (in hexadecimal)Footref 1

P3TEXT	VARCHAR2(64)	Description of the third wait event parameter
P3	NUMBER	Third wait event parameter (in decimal)
P3RAW	RAW(8)	Third wait event parameter (in hexadecimal)Footref 1

WAIT_CLASS_ID	NUMBER	Identifier of the class of the wait event
WAIT_CLASS#	NUMBER	Number of the class of the wait event
WAIT_CLASS	VARCHAR2(64)	Name of the class of the wait event
WAIT_TIME	NUMBER	If the session is currently waiting, then the value is 0. If the session is not in a wait, then the value is as follows:
•	> 0 - Value is the duration of the last wait in hundredths of a second
•	-1 - Duration of the last wait was less than a hundredth of a second
•	-2 - Parameter TIMED_STATISTICS was set to false
This column has been deprecated in favor of the columns WAIT_TIME_MICROand STATE.
SECONDS_IN_WAIT	NUMBER	If the session is currently waiting, then the value is the amount of time waited for the current wait. If the session is not in a wait, then the value is the amount of time since the start of the last wait.
This column has been deprecated in favor of the columns WAIT_TIME_MICROand TIME_SINCE_LAST_WAIT_MICRO.
STATE	VARCHAR2(19)	Wait state:
•	WAITING - Session is currently waiting
•	WAITED UNKNOWN TIME - Duration of the last wait is unknown; this is the value when the parameter TIMED_STATISTICS is set to false
•	WAITED SHORT TIME - Last wait was less than a hundredth of a second
•	WAITED KNOWN TIME - Duration of the last wait is specified in the WAIT_TIMEcolumn
WAIT_TIME_MICRO	NUMBER	Amount of time waited (in microseconds). If the session is currently waiting, then the value is the time spent in the current wait. If the session is currently not in a wait, then the value is the amount of time waited in the last wait.
TIME_REMAINING_MICRO	NUMBER	Value is interpreted as follows:
•	> 0 - Amount of time remaining for the current wait (in microseconds)
•	0 - Current wait has timed out
•	-1 - Session can indefinitely wait in the current wait
•	NULL - Session is not currently waiting
TIME_SINCE_LAST_WAIT_MICRO	NUMBER	Time elapsed since the end of the last wait (in microseconds). If the session is currently in a wait, then the value is 0.

Footnote 1 The P1RAW, P2RAW, and P3RAW columns display the same values as the P1, P2, and P3 columns, except that the numbers are displayed in hexadecimal.








v$sess_io
This view lists I/O statistics for each user session.
Column	Datatype	Description
SID	NUMBER	Session identifier
BLOCK_GETS	NUMBER	Block gets for this session
CONSISTENT_GETS	NUMBER	Consistent gets for this session
PHYSICAL_READS	NUMBER	Physical reads for this session
BLOCK_CHANGES	NUMBER	Block changes for this session
CONSISTENT_CHANGES	NUMBER	Consistent changes for this session




















USER MANAGEMENT - II
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
create user u2 identified by u2 profile prof1;
alter user u1 profile prof1;
desc dba_profiles;
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
