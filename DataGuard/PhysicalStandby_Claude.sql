give me steps to configure oracle physical standby database

Here’s a clear, step-by-step guide to configure an Oracle Physical Standby 
Database (Data Guard configuration). This is a high-level procedure that 
assumes you already have a primary database configured and running in 
ARCHIVELOG mode.

1. Prepare the Primary Database
===============================

1. Enable ARCHIVELOG mode

sql

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

2. Force logging

sql

ALTER DATABASE FORCE LOGGING;

3. Create a standby redo log (SRL) on primary
Create one more SRL group than the number of primary redo log groups.

sql

ALTER DATABASE ADD STANDBY LOGFILE (
  '/u01/app/oracle/oradata/DBNAME/srl01.log' SIZE 500M,
  '/u01/app/oracle/oradata/DBNAME/srl02.log' SIZE 500M,
  '/u01/app/oracle/oradata/DBNAME/srl03.log' SIZE 500M,
  '/u01/app/oracle/oradata/DBNAME/srl04.log' SIZE 500M
);

4. Configure initialization parameters for Data Guard:

sql


ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(DBPRIM,DBSTBY)';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DBPRIM';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=DBSTBY ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DBSTBY';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE;
ALTER SYSTEM SET FAL_SERVER=DBSTBY;
ALTER SYSTEM SET FAL_CLIENT=DBPRIM;
ALTER SYSTEM SET DB_FILE_NAME_CONVERT='/u01/app/oracle/oradata/DBSTBY/','/u01/app/oracle/oradata/DBPRIM/' SCOPE=SPFILE;
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='/u01/app/oracle/oradata/DBSTBY/','/u01/app/oracle/oradata/DBPRIM/' SCOPE=SPFILE;
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;


2. Prepare the Standby Instance
===============================

1. Create an Oracle password file identical to the primary.
On the standby host:

bash

orapwd file=$ORACLE_HOME/dbs/orapwDBSTBY password=your_password entries=5

2. Copy primary database files to the standby:
  -Initialization parameter file (PFILE or SPFILE)
  -Control file for standby

sql

ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/tmp/stbyctrl.ctl';


Datafiles using RMAN or manual copy

Example with RMAN:

bash

RMAN> CONNECT TARGET sys@DBPRIM;
RMAN> BACKUP DATABASE FORMAT '/tmp/backup_%U.bkp';
RMAN> BACKUP CURRENT CONTROLFILE FOR STANDBY FORMAT '/tmp/standby.ctl';

Then, on the standby:
bash

RMAN> CONNECT TARGET sys@DBSTBY;
RMAN> RESTORE CONTROLFILE FROM '/tmp/standby.ctl';
RMAN> RESTORE DATABASE;


3. Modify the standby init.ora or SPFILE parameters (mirror of primary changes) with:

sql

DB_UNIQUE_NAME=DBSTBY
LOG_ARCHIVE_CONFIG='DG_CONFIG=(DBPRIM,DBSTBY)'
LOG_ARCHIVE_DEST_1='LOCATION=/arch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DBSTBY'
LOG_ARCHIVE_DEST_2='SERVICE=DBPRIM ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DBPRIM'
FAL_SERVER=DBPRIM
FAL_CLIENT=DBSTBY
STANDBY_FILE_MANAGEMENT=AUTO


3. Start the Standby Database
=============================
1. Mount the standby database:
sql

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;


2. Start redo apply (physical standby managed recovery):
sql

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

Or for Active Data Guard (open read-only with apply):
sql

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;
ALTER DATABASE OPEN READ ONLY;


4. Validate Configuration
=========================
Check database roles:
sql

SELECT DATABASE_ROLE FROM V$DATABASE;

Verify log shipping and apply status:
sql

SELECT DEST_ID,STATUS,ERROR FROM V$ARCHIVE_DEST_STATUS;

5. Switchover or Failover
=========================

To switch roles: On primary:
sql

ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

On standby:
sql

ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
Would you like me to show this procedure specifically using RMAN DUPLICATE FROM ACTIVE DATABASE, which avoids manual file copies and is the most common method in Oracle 12c and later?




Type a message...
