starting a standby database
startup nomount
alter database mount standby database;
alter database open read only;
alter database recover managed standby database disconnect;
alter database recover managed standby database disconnect from session;

select process,status,thread#,sequence#,client_process from v$managed_standby;

Starting Up
===========
startup;
(The STARTUP statement starts the database, mounts the database as a physical standby database, and opens the database for read-only access.)

startup mount;
(The STARTUP MOUNT statement starts and mounts the database as a physical standby database, but does not open the database.)

Once mounted, the database can receive archived redo data from the primary database. You then have the option of either starting Redo Apply or opening the database for read-only access. Typically, you start Redo Apply.

Start and mount the database:
STARTUP MOUNT;

Start log apply services:

To start Redo Apply, issue the following statement:
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

To start real-time apply, issue the following statement:
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE;

On the primary database, query the RECOVERY_MODE column in the V$ARCHIVE_DEST_STATUS view,
which displays the standby database's operation as MANAGED_RECOVERY for Redo Apply 
and MANAGED REAL TIME APPLY for real-time apply.

select dest_id,status,database_mode,recovery_mode,db_unique_name 
from v$archive_dest_status
where recovery_mode <> 'IDLE';


Shutting Down a Physical Standby Database
=========================================
To shut down a physical standby database and stop log apply services, use the SQL*Plus SHUTDOWN IMMEDIATE statement. 
Control is not returned to the session that initiates a database shutdown until shutdown is complete.

If the primary database is up and running, defer the destination on the primary database and perform a log switch 
before shutting down the standby database.

To stop log apply services before shutting down the database, use the following steps:
1. Issue the following query to find out if the standby database is performing Redo Apply or real-time apply. 
If the MRP0 or MRP process exists, then the standby database is applying redo.
SQL> SELECT PROCESS, STATUS, SEQUENCE# FROM V$MANAGED_STANDBY;

2. If log apply services are running, cancel them as shown in the following example:
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

3. Shut down the standby database.
SQL> SHUTDOWN;



Using a Standby Database That Is Open for Read-Only Access
==========================================================
When a standby database is open for read-only access, users can query the standby database but cannot 
update it. Thus, you can reduce the load on the primary database by using the standby database for 
reporting purposes. You can periodically open the standby database for read-only access and perform 
ad hoc queries to verify log apply services are updating the standby database correctly. 
(Note that for distributed queries, you must first issue the ALTER DATABASE SET TRANSACTION READ ONLY 
statement before you can issue a query on the read-only database.)

PENDING
https://docs.oracle.com/cd/B13789_01/server.101/b10823/manage_ps.htm
