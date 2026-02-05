Oracle Data Guard Physical Standby Configuration With Broker

We assume that primary server has a database (SID=ip7) up and running. The standby 
database has Oracle 12cR2 installation done in the same oracle home location as primary

Physical Standby With Broker Overview

Primary details

SID: ip7
ORACLE_HOME: /u01/app/oracle/product/12.2.0.1
Host Name: srv1.dbagenesis.com

Standby details

SID: ip7
ORACLE_HOME: /u01/app/oracle/product/12.2.0.1
Host Name: srv2.dbagenesis.com


Primary Database Changes

Primary must run in archive log mode. Check the archive log mode

SQL> SELECT log_mode FROM v$database;
LOG_MODE
------------
NOARCHIVELOG

If it is not running in archive log mode, then enable it

SQL> shutdown immediate
SQL> startup mount
SQL> alter database archivelog;
SQL> alter database open;
SQL> archive log list;

Enable force logging on primary: In oracle, users can restrict redo 
generation for SQL by using NOLOGGING clause. This NOLOGGING transaction 
will be a problem for physical standby. Hence, we force logging so even 
user uses NOLOGGING clause, every SQL will be logged on to redo.

SQL> alter database force logging;
SQL> select name, force_logging from v$database;

Standby file management: We need to make sure whenever we add/drop datafile 
in primary database, those files are also added / dropped on standby.

SQL> alter system set standby_file_management = 'AUTO';

Create standby log files: You must create standby log files on primary. These 
files are used by a standby database to store redo it receives from primary database.


Our primary may become standby later and we would need them, so better to create it. 
First check the current log groups:

SQL> select GROUP#, THREAD#, bytes/1024/1024, MEMBERS, STATUS from v$log;
    GROUP#    THREAD# BYTES/1024/1024    MEMBERS STATUS
---------- ---------- --------------- ---------- ----------------
         1          1             200          1 INACTIVE
         2          1             200          1 CURRENT
         3          1             200          1 INACTIVE

SQL> select member from v$logfile;
MEMBER
---------------------------------------------------
/u01/data/db_files/ip7/redo03.log
/u01/data/db_files/ip7/redo02.log
/u01/data/db_files/ip7/redo01.log

Add the standby logfiles, make sure group number should be from a different 
series like in this case we choose to start with 11 and above. This helps in easy differentiation.

Make sure to keep the thread# and logfile size exactly same. Oracle also recommends to always 
create n+1 standby log files. Where n is the total number of logfiles

ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 11 '/u01/data/db_files/ip7/stb_redo1.log' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 12 '/u01/data/db_files/ip7/stb_redo2.log' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 13 '/u01/data/db_files/ip7/stb_redo3.log' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 14 '/u01/data/db_files/ip7/stb_redo4.log' SIZE 200M;

Check the standby log files via below query

SQL> SELECT GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS FROM V$STANDBY_LOG ORDER BY GROUP#;

Enable flashback on primary: Flashback database is highly recommended because in 
case of failover, you need not re-create primary database from scratch

SQL> alter system set db_recovery_file_dest_size=45g;
SQL> alter database flashback on;
SQL> select flashback_on from v$database;

Check DB Unique name parameter on primary: Make sure your primary database has DB_UNIQUE_NAME 
parameter set for consistency. If it’s not set properly, use ALTER SYSTEM SET command

SQL> show parameter db_name
NAME                                 TYPE        VALUE
------------------------------------ ----------- -------------
db_name                              string      ip7

SQL> show parameter db_unique_name
NAME                                 TYPE        VALUE
------------------------------------ ----------- -------------
db_unique_name                       string      ip7

Create password file for standby: This is needed for cloning purpose. Even if there is one 
password file in $ORACLE_HOME/dbs location, create a new one with standby SID

orapwd file=$ORACLE_HOME/dbs/orapwip7 entries=10 force=y

scp orapwip7 oracle@srv2:$ORACLE_HOME/dbs


Configure Network

Add below tns entry to both primary and standby server

Notice the use of the SID, rather than the SERVICE_NAME in the entries. This is important as 
the broker will need to connect to the databases when they are down, so the services will not 
be present

vi $ORACLE_HOME/network/admin/tnsnames.ora

ip7 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = srv1.dbagenesis.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = ip7)
    )
  )

ip7_stb =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = srv2.dbagenesis.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = ip7)
    )
  )    

Configure listener on primary database: Since the broker will need to connect to the 
database when it’s down, we can’t rely on auto-registration with the listener, hence 
the explicit entry for the database

vi $ORACLE_HOME/network/admin/listener.ora

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = srv1.dbagenesis.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = ip7_DGMGRL)
      (ORACLE_HOME = /u01/app/oracle/product/12.2.0.1)
      (SID_NAME = ip7)
    )
  )

ADR_BASE_LISTENER = /u01/app/oracle

Configure listener on standby: Since the broker will need to connect to the database 
when it’s down, we can’t rely on auto-registration with the listener, hence the explicit 
entry for the database

vi $ORACLE_HOME/network/admin/listener.ora

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = srv2.dbagenesis.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = ip7_stb_DGMGRL)
      (ORACLE_HOME = /u01/app/oracle/product/12.2.0.1)
      (SID_NAME = ip7)
    )
  )

ADR_BASE_LISTENER = /u01/app/oracle

Once the listener.ora changes are in place, restart the listener on both servers

lsnrctl stop
lsnrctl start


Standby Server Changes

On standby server, create parameter file with below contents

On standby server
=================
vi /tmp/initip7.ora
*.db_name='ip7'

Create pfile on primary, open it and create the necessary directories on the standby server

On Primary Server
=================
SQL> create pfile from spfile;
exit

$ cd $ORACLE_HOME/dbs
$ cat initip7.ora

On Standby Server
=================
on standby, create directories as you find in the initip7.ora file

mkdir -p /u01/app/oracle/admin/ip7/adump
mkdir -p /u01/data/db_files/ip7
mkdir -p /u01/FRA/ip7
  
Start the auxiliary instance on the standby server by starting it using the temporary init.ora file

On Standby Server
=================
$ export ORACLE_SID=ip7
$ sqlplus / as sysdba

SQL> STARTUP NOMOUNT PFILE='/tmp/initip7.ora';
SQL> exit;

--you must exit from sqlplus, else cloning will fail

Duplicate primary database via RMAN: In this step, we will use RMAN to duplicate primary 
database for our standby database.

On primary, connect to RMAN, specifying a full connect string for both the TARGET and 
AUXILIARY instances. Do not attempt to use OS authentication or the database cloning will fail

On primary server
=================
$ rman TARGET sys@ip7

RMAN> connect auxiliary sys@ip7_stb

RMAN> DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE 
DORECOVER 
SPFILE 
SET db_unique_name='ip7_stb' 
COMMENT 'Is standby' 
NOFILENAMECHECK;

Once cloning is done, you should see below at RMAN prompt

Finished Duplicate Db at 07-DEC-2015

Enable flashback on standby: As we know the importance of flashback in data guard, we must enable it on standby as well

On Standby Server
=================
SQL> alter database flashback on;

Enable Data Guard Broker

At this point we have a primary database and a standby database, so now we need to start using the 
Data Guard Broker to manage them. Connect to both databases (primary and standby) and issue the following command:

On primary:
===========
SQL> alter system set dg_broker_start=true;
SQL> show parameter dg_broker_start;

On standby:
===========
SQL> alter system set dg_broker_start=true;
SQL> show parameter dg_broker_start;

On primary, connect to DGMGRL utility and register the primary database with broker

On primary:
===========
dgmgrl sys@ip7
DGMGRL> create configuration my_dg as primary database is ip7 connect identifier is ip7;
DGMGRL> show configuration;

Now add standby database

DGMGRL> add database ip7_stb as connect identifier is ip7_stb;
DGMGRL> show configuration;

Enable configuration

DGMGRL> ENABLE CONFIGURATION;
Enabled.

The following commands show how to check the configuration and status of the databases 
from the broker. Like how we start / stop MRP manually, we can start / stop redo apply 
on standby using broker.

Stop log apply:
===============
dgmgrl sys/sys@ip7
DGMGRL> show configuration;
DGMGRL> show database ip7_stb;
DGMGRL> edit database ip7_stb set state=APPLY-OFF;
DGMGRL> show database ip7_stb;

Start log apply:
================
DGMGRL> edit database ip7_stb set state=APPLY-ON;
DGMGRL> show database ip7_stb;

How we can manually enable log shipping from primary to standby, the same way we can use broker to enable log shipping

Disable log shipping/transport:
===============================
dgmgrl sys/sys@ip7
DGMGRL> show configuration;
DGMGRL> edit database ip7 set state=TRANSPORT-OFF;
DGMGRL> show database ip7;

Enable log shipping/transport:
==============================
DGMGRL> edit database ip7 set state=TRANSPORT-ON;
DGMGRL> show database ip7;
