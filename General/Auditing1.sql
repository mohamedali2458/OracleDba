Step-by-Step Oracle 19c DBA Auditing Configuration

Introduction
In this article we will see Step-by-step Oracle 19c DBA auditing setup using 
unified auditing to monitor SYSDBA activities, privilege usage, and critical database changes.

Why Audit DBA Privileges?
Auditing DBAs helps you :

1) It will help to track who did what, when, and from where.

2) It will detect privilege misuse.

3) It will help to prevent unauthorized schema or data changes.


1. Check Current Auditing Status
We can use below command to check if Unified Auditing is enabled.

SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Unified Auditing';

Next thing we need to check current audit settings
SHOW PARAMETER audit_trail;


2. Enable Unified Auditing (If Not Enabled)
a) Shutdown database.

Command : - shut immediate;

Output

SQL> shut immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.


b) Relink Oracle Binary with Unified Auditing Enabled

We need to go to the Oracle RDBMS library directory and relink the Oracle binary.

cd $ORACLE_HOME/rdbms/lib

Command : - make -f ins_rdbms.mk uniaud_on ioracle

Output

[oracle@primary ~]$ cd $ORACLE_HOME/rdbms/lib
[oracle@primary lib]$
[oracle@primary lib]$
[oracle@primary lib]$ make -f ins_rdbms.mk uniaud_on ioracle
/usr/bin/ar d /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/libknlopt.a kzanang.o
/usr/bin/ar cr /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/libknlopt.a /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/kzaiang.o
chmod 755 /u01/app/oracle/product/19.0.0/dbhome_1/bin

 - Linking Oracle
rm -f /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/oracle
/u01/app/oracle/product/19.0.0/dbhome_1/bin/orald  -o /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/oracle -m64 -z noexecstack -Wl,--disable-new-dtags -L/u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/ -L/u01/app/oracle/product/19.0.0/dbhome_1/lib/ -L/u01/app/oracle/product/19.0.0/dbhome_1/lib/stubs/   -Wl,-E /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/opimai.o /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/ssoraed.o /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/ttcsoi.o -Wl,--whole-archive -lperfsrv19 -Wl,--no-whole-archive /u01/app/oracle/product/19.0.0/dbhome_1/lib/nautab.o /u01/app/oracle/product/19.0.0/dbhome_1/lib/naeet.o /u01/app/oracle/product/19.0.0/dbhome_1/lib/naect.o /u01/app/oracle/product/19.0.0/dbhome_1/lib/naedhs.o /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/config.o  -ldmext -lserver19 -lodm19 -lofs -lcell19 -lnnet19 -lskgxp19 -lsnls19 -lnls19  -lcore19 -lsnls19 -lnls19 -lcore19 -lsnls19 -lnls19 -lxml19 -lcore19 -lunls19 -lsnls19 -lnls19 -lcore19 -lnls19 -lclient19  -lvsnst19 -lcommon19 -lgeneric19 -lknlopt -loraolap19 -lskjcx19 -lslax19 -lpls19  -lrt -lplp19 -ldmext -lserver19 -lclient19  -lvsnst19 -lcommon19 -lgeneric19 `if [ -f /u01/app/oracle/product/19.0.0/dbhome_1/lib/libavserver19.a ] ; then echo "-lavserver19" ; else echo "-lavstub19"; fi` `if [ -f /u01/app/oracle/product/19.0.0/dbhome_1/lib/libavclient19.a ] ; then echo "-lavclient19" ; fi` -lknlopt -lslax19 -lpls19  -lrt -lplp19 -ljavavm19 -lserver19  -lwwg  `cat /u01/app/oracle/product/19.0.0/dbhome_1/lib/ldflags`    -lncrypt19 -lnsgr19 -lnzjs19 -ln19 -lnl19 -lngsmshd19 -lnro19 `cat /u01/app/oracle/product/19.0.0/dbhome_1/lib/ldflags`    -lncrypt19 -lnsgr19 -lnzjs19 -ln19 -lnl19 -lngsmshd19 -lnnzst19 -lzt19 -lztkg19 -lmm -lsnls19 -lnls19  -lcore19 -lsnls19 -lnls19 -lcore19 -lsnls19 -lnls19 -lxml19 -lcore19 -lunls19 -lsnls19 -lnls19 -lcore19 -lnls19 -lztkg19 `cat /u01/app/oracle/product/19.0.0/dbhome_1/lib/ldflags`    -lncrypt19 -lnsgr19 -lnzjs19 -ln19 -lnl19 -lngsmshd19 -lnro19 `cat /u01/app/oracle/product/19.0.0/dbhome_1/lib/ldflags`    -lncrypt19 -lnsgr19 -lnzjs19 -ln19 -lnl19 -lngsmshd19 -lnnzst19 -lzt19 -lztkg19   -lsnls19 -lnls19  -lcore19 -lsnls19 -lnls19 -lcore19 -lsnls19 -lnls19 -lxml19 -lcore19 -lunls19 -lsnls19 -lnls19 -lcore19 -lnls19 `if /usr/bin/ar tv /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/libknlopt.a | grep "kxmnsd.o" > /dev/null 2>&1 ; then echo " " ; else echo "-lordsdo19 -lserver19"; fi` -L/u01/app/oracle/product/19.0.0/dbhome_1/ctx/lib/ -lctxc19 -lctx19 -lzx19 -lgx19 -lctx19 -lzx19 -lgx19 -lclscest19 -loevm -lclsra19 -ldbcfg19 -lhasgen19 -lskgxn2 -lnnzst19 -lzt19 -lxml19 -lgeneric19 -locr19 -locrb19 -locrutl19 -lhasgen19 -lskgxn2 -lnnzst19 -lzt19 -lxml19 -lgeneric19  -lgeneric19 -lorazip -loraz -llzopro5 -lorabz2 -lorazstd -loralz4 -lipp_z -lipp_bz2 -lippdc -lipps -lippcore  -lippcp -lsnls19 -lnls19  -lcore19 -lsnls19 -lnls19 -lcore19 -lsnls19 -lnls19 -lxml19 -lcore19 -lunls19 -lsnls19 -lnls19 -lcore19 -lnls19 -lsnls19 -lunls19  -lsnls19 -lnls19  -lcore19 -lsnls19 -lnls19 -lcore19 -lsnls19 -lnls19 -lxml19 -lcore19 -lunls19 -lsnls19 -lnls19 -lcore19 -lnls19 -lasmclnt19 -lcommon19 -lcore19  -ledtn19 -laio -lons  -lmql1 -lipc1 -lfthread19    `cat /u01/app/oracle/product/19.0.0/dbhome_1/lib/sysliblist` -Wl,-rpath,/u01/app/oracle/product/19.0.0/dbhome_1/lib -lm    `cat /u01/app/oracle/product/19.0.0/dbhome_1/lib/sysliblist` -ldl -lm   -L/u01/app/oracle/product/19.0.0/dbhome_1/lib `test -x /usr/bin/hugeedit -a -r /usr/lib64/libhugetlbfs.so && test -r /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/shugetlbfs.o && echo -Wl,-zcommon-page-size=2097152 -Wl,-zmax-page-size=2097152 -lhugetlbfs`

rm -f /u01/app/oracle/product/19.0.0/dbhome_1/bin/oracle
mv /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/lib/oracle /u01/app/oracle/product/19.0.0/dbhome_1/bin/oracle
chmod 6751 /u01/app/oracle/product/19.0.0/dbhome_1/bin/oracle
(if [ ! -f /u01/app/oracle/product/19.0.0/dbhome_1/bin/crsd.bin ]; then \
    getcrshome="/u01/app/oracle/product/19.0.0/dbhome_1/srvm/admin/getcrshome" ; \
    if [ -f "$getcrshome" ]; then \
        crshome="`$getcrshome`"; \
        if [ -n "$crshome" ]; then \
            if [ $crshome != /u01/app/oracle/product/19.0.0/dbhome_1 ]; then \
                oracle="/u01/app/oracle/product/19.0.0/dbhome_1/bin/oracle"; \
                $crshome/bin/setasmgidwrap oracle_binary_path=$oracle; \
            fi \
        fi \
    fi \
fi\
);



c) Start database.

sqlplus / as sysdba

Command: - startup;

Output

SQL> startup;
ORACLE instance started.

Total System Global Area 3439326896 bytes
Fixed Size                  8902320 bytes
Variable Size             687865856 bytes
Database Buffers         2734686208 bytes
Redo Buffers                7872512 bytes
Database mounted.
Database opened.



d) Verify Unified Auditing Status.

SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Unified Auditing';


3. Create Audit Policies for DBA Privileges
Oracle 19c Unified Auditing allows you to group multiple audit rules into audit policies. 
These policies help track who grants DBA power, who uses it, and when privileged access occurs.

A. Audit When DBA Role Is Granted or Revoked.

1A)  Command : -

CREATE AUDIT POLICY audit_dba_role_grants
ACTIONS
GRANT,
REVOKE
ROLES DBA;

Output

SQL> CREATE AUDIT POLICY audit_dba_role_grants
ACTIONS
GRANT,
REVOKE
ROLES DBA;

Audit policy created.


2B) Now enable the Policy (audit_dba_role_grants)

AUDIT POLICY audit_dba_role_grants;

Output

SQL> AUDIT POLICY audit_dba_role_grants;

Audit succeeded.
B. Audit All DBA Privilege Usage.

1B) Command: -

CREATE AUDIT POLICY audit_dba_activities
PRIVILEGES
ALTER SYSTEM,
ALTER DATABASE,
CREATE USER,
DROP USER,
ALTER USER,
CREATE ROLE,
DROP ANY TABLE,
DELETE ANY TABLE,
DROP ANY PROCEDURE,
GRANT ANY PRIVILEGE,
GRANT ANY ROLE;

Note: - This policy audits actual usage of powerful DBA-level privileges, not just role assignment.

Output

SQL> CREATE AUDIT POLICY audit_dba_activities
PRIVILEGES
ALTER SYSTEM,
ALTER DATABASE,
CREATE USER,
DROP USER,
ALTER USER,
CREATE ROLE,
DROP ANY TABLE,
DELETE ANY TABLE,
DROP ANY PROCEDURE,
GRANT ANY PRIVILEGE,
GRANT ANY ROLE;

Audit policy created.


2B) Now enable the Policy (audit_dba_activities)

AUDIT POLICY audit_dba_activities;

Note: - Enables auditing for all users who use these privileges.

Output

SQL> AUDIT POLICY audit_dba_activities;

Audit succeeded.
C. Audit SYSDBA / SYSOPER Connections.

SYSDBA and SYSOPER are the highest privilege levels in Oracle. Auditing these connections is mandatory for security and compliance.

1C) Create policy for privileged connections

CREATE AUDIT POLICY audit_privileged_connections ACTIONS LOGON;

Note: - it will help to audits every database login attempt like Time of login, User,Host machine, Success or failure.

Output

SQL> CREATE AUDIT POLICY audit_privileged_connections
ACTIONS LOGON;  2

Audit policy created.


2C) Enable Policy for DBA-Level Users (SYSDBA and SYSOPER)

AUDIT POLICY audit_privileged_connections BY USERS WITH GRANTED ROLES DBA;

Note: - It will Applies only to users with DBA role.

Output

SQL> AUDIT POLICY audit_privileged_connections BY USERS WITH GRANTED ROLES DBA;

Audit succeeded.
D. Audit SYS Operations (OS-Authenticated Actions)

This parameter controls auditing of SYSDBA actions performed outside the database 
like Startup / Shutdown, Recovery, OS-authenticated SYS connections. It is enabled 
by default, if not then we can enable it using below commands

Command: - SHOW PARAMETER audit_sys_operations;

Output

SQL> SHOW PARAMETER audit_sys_operations;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_sys_operations                 boolean     TRUE


Note: - If it is not enable you can use below command to enable it which also requires database reboot.

ALTER SYSTEM SET audit_sys_operations=TRUE SCOPE=SPFILE;
E. How to View These Audit Records

You can view these records using below command.

set lines 999 pages 999
COL EVENT_TIMESTAMP for a40
COL DBUSERNAME for a20
COL ACTION_NAME for a20
COL CLIENT_PROGRAM_NAME for a50
COL USERHOST for a25
SELECT
  EVENT_TIMESTAMP,
  DBUSERNAME,
  ACTION_NAME,
  USERHOST,
  CLIENT_PROGRAM_NAME
FROM UNIFIED_AUDIT_TRAIL
ORDER BY EVENT_TIMESTAMP DESC;

4. Create Read-Only Role for Non-Privileged Users
A read-only role is used for users who only need to view data (reports, dashboards, audits) 
and must not change anything in the database.

A. Create a Read-Only Role.

CREATE ROLE readonly_user;

Note: - Above command will help to creates a container role to hold all read-only permissions

Output

SQL> CREATE ROLE readonly_user;

Role created.
B. Grant SELECT on Specific Schema Objects.

BEGIN
  FOR t IN (SELECT table_name FROM dba_tables WHERE owner = 'HR') LOOP
    EXECUTE IMMEDIATE 
      'GRANT SELECT ON HR.' || t.table_name || ' TO readonly_user';
  END LOOP;
END;
/

Output

PL/SQL procedure successfully completed.

C. Grant SELECT ANY TABLE (more permissive)

GRANT SELECT ANY TABLE TO readonly_user;

Output

SQL> GRANT SELECT ANY TABLE TO readonly_user;

Grant succeeded.
D. Grant Basic Session Privilege

GRANT CREATE SESSION TO readonly_user;

Note: - Above command allows users to log in to the database because Without this, 
the user cannot connect, even with SELECT privileges

Output

SQL> GRANT CREATE SESSION TO readonly_user;

Grant succeeded.
E. Create read-only user

CREATE USER report_user IDENTIFIED BY "SecurePass123#";

Output

SQL> CREATE USER report_user IDENTIFIED BY "SecurePass123#";

User created.
F. Assign the Read-Only Role to the User

GRANT readonly_user TO report_user;

Output

SQL> GRANT readonly_user TO report_user;

Grant succeeded.

5. Audit Policy for Monitoring Read-Only Users
Sometimes even read-only users can become a security risk like Privileges are granted 
by mistake, Roles are misconfigured, Applications attempt write operations, Someone 
tries to misuse access intentionally.

This audit policy helps you detect and prove such violations.

A. Create Audit Policy for Read-Only Violations.

CREATE AUDIT POLICY audit_readonly_violations
ACTIONS
INSERT,
UPDATE,
DELETE,
CREATE TABLE,
DROP TABLE,
ALTER TABLE;

Output

SQL> CREATE AUDIT POLICY audit_readonly_violations
ACTIONS
INSERT,
UPDATE,
DELETE,
CREATE TABLE,
DROP TABLE,
ALTER TABLE;

Audit policy created.
B. Enable the Policy Only for Read-Only Users

AUDIT POLICY audit_readonly_violations BY USERS WITH GRANTED ROLES readonly_user;

Output

SQL> AUDIT POLICY audit_readonly_violations BY USERS WITH GRANTED ROLES readonly_user;

Audit succeeded.
6. Viewing Unified Audit Records
A. View All Unified Audit Records (Last 7 Days)

set lines 999 pages 999
col USERHOST for a20
col OS_USERNAME for a20
col SQL_TEXT for a40
SELECT
EVENT_TIMESTAMP,
DBUSERNAME,
ACTION_NAME,
OBJECT_SCHEMA,
OBJECT_NAME,
SQL_TEXT,
RETURN_CODE,
OS_USERNAME,
USERHOST
FROM UNIFIED_AUDIT_TRAIL
WHERE EVENT_TIMESTAMP > SYSDATE - 7
ORDER BY EVENT_TIMESTAMP DESC;
B. View DBA privilege usage

set lines 999 pages 999
COL EVENT_TIMESTAMP for a40
COL DBUSERNAME for a20
COL ACTION_NAME for a20
col SYSTEM_PRIVILEGE_USED for a30
SELECT
EVENT_TIMESTAMP,
DBUSERNAME,
ACTION_NAME,
SYSTEM_PRIVILEGE_USED,
RETURN_CODE
FROM UNIFIED_AUDIT_TRAIL
WHERE SYSTEM_PRIVILEGE_USED IS NOT NULL
ORDER BY EVENT_TIMESTAMP DESC;
C. View failed login attempts

set lines 999 pages 999
COL EVENT_TIMESTAMP for a40
col USERHOST for a30
col OS_USERNAME for a20
COL DBUSERNAME for a20
SELECT
EVENT_TIMESTAMP,
DBUSERNAME,
OS_USERNAME,
USERHOST,
RETURN_CODE
FROM UNIFIED_AUDIT_TRAIL
WHERE ACTION_NAME = 'LOGON'
AND RETURN_CODE != 0
ORDER BY EVENT_TIMESTAMP DESC;
7. Set the Audit Retention Window
BEGIN
  DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
    AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
    LAST_ARCHIVE_TIME => SYSTIMESTAMP - 90
  );
END;
/

Note: - Above command will help to clear Audit records older than 90 days which are eligible for cleanup.
8. Create an Automatic Cleanup (Purge) Job
BEGIN
  DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
    AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
    AUDIT_TRAIL_PURGE_INTERVAL => 24, -- hours
    AUDIT_TRAIL_PURGE_NAME => 'DAILY_AUDIT_PURGE',
    USE_LAST_ARCH_TIMESTAMP => TRUE
  );
END;
/

Note: - Above command will help to creates a scheduled job which runs every 24 hours and delete only audit records  older than 90 days.
9. Disable Unified Auditing in Oracle 19c
A. Shutdown the database.

sqlplus / as sysdba
SHUTDOWN IMMEDIATE;
EXIT;
B. Relink Oracle Binary to Disable Unified Auditing.

cd $ORACLE_HOME/rdbms/lib

make -f ins_rdbms.mk uniaud_off ioracle
C. Start the Database.

sqlplus / as sysdba
STARTUP;
D. Verify Unified Auditing Is Disabled.

SELECT VALUE
FROM V$OPTION
WHERE PARAMETER = 'Unified Auditing';
Conclusion
We have covered the Step by Step Oracle 19c DBA auditing configuration.

If you enjoyed the article, please leave a comment and share it with your friends. Also, let 
me know which Oracle and MySQL topics you'd like to see covered in future articles.

Note: – If you want to practice this whole activity in your home lab, then you'll need a platform 
to perform the installation. To set that up, you first need to download and install Oracle VirtualBox, 
followed by the operating system, the Oracle binary software, and finally, create the database.
