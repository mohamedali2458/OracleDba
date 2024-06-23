Enable Fast Start Failover Data Guard Broker

While Oracle Data Guard definitely protects a database when the entire production site is lost via its failover 
capabilities, it’s still necessary for an Oracle DBA to intervene to complete the failover process.

    Configure FSFO 
    Test FSFO Configuration 
    Reinstate Failed Primary 
    Disable FSFO 

With this activity, we can enable automatic failover using Fast-Start-Failover Observer with Data Guard broker.


Configure Fast Start Failover

Check StaticConnectIdentifier: In order to enable FSFO, the StaticConnectIdentifier parameter must be set both in primary and standby

On primary(proddb):
===================
dgmgrl sys/sys@proddb

DGMGRL> show database proddb StaticConnectIdentifier;
DGMGRL> show database proddb_st StaticConnectIdentifier;

If StaticConnectIdentifier is blank: The StaticConnectIdentifier takes its value from LOCAL_LISTENER parameter from 
the database. If this value is not set (or blank) for any database above, then connect to sqlplus and edit LOCAL_LISTENER parameter

SQL> ALTER SYSTEM SET LOCAL_LISTENER='(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.0.204)(PORT=1521))';

Once you make changes to LOCAL_LISTENER parameter, you must restart the listener.


Define FastStartFailoverTarget: In general, there can be more than one physical standby database. So, we need to pair physical 
standby with primary to let Fast Start Failover know which physical standby to be activated

On primary (proddb):
====================
dgmgrl sys/sys@proddb
DGMGRL> SHOW FAST_START FAILOVER
DGMGRL> EDIT DATABASE proddb SET PROPERTY FastStartFailoverTarget = 'proddb_st';
DGMGRL> EDIT DATABASE proddb_st SET PROPERTY FastStartFailoverTarget = 'proddb';
DGMGRL> show database verbose proddb;
DGMGRL> show database verbose proddb_st;

Define FastStartFailoverThreshold: Next we need to let broker know when to initiate automatic failover. What is the time (in seconds) 
that FSFO will wait before initiating failover

DGMGRL> EDIT CONFIGURATION SET PROPERTY FastStartFailoverThreshold=30;
DGMGRL> show fast_start failover

Define FastStartFailoverLagLimit: We can optionally define how much time (in seconds) data we are ready to lose in case the Data Guard is in Max Performance Mode

DGMGRL> EDIT CONFIGURATION SET PROPERTY FastStartFailoverLagLimit = 30;

Enable FSFO: Now we can enable FSFO. Never start observer on production database

On Standby Server:
==================

dgmgrl sys/sys@proddb_st

DGMGRL> ENABLE FAST_START FAILOVER;
DGMGRL> show configuration;
DGMGRL> start observer;


Test FSFO Configuration

Let us simulate a failure. We will abort primary (proddb) instance and wait for FSFO to perform automatic failover.

Simulate failure: On proddb, the current primary, let us shut abort the instance

On primary (proddb):
===================
sqlplus / as sysdba
SQL> shut abort;

Check logfiles: At this stage, check alert log and observer log files. FSFO must perform automatic failover and proddb_st would be your new primary database

On new primary (proddb_st):
===========================
sqlplus / as sysdba
SQL> select name, open_mode, db_unique_name from v$database;


Reinstate Failed Primary

Mount the failed primary (proddb) and it will auto reinstate. 

Note: Do not open the database as it will be switched to physical standby

On failed primary (proddb):
===========================
sqlplus / as sysdba
SQL> startup mount;

dgmgrl sys/sys@proddb
DGMGRL> show configuration;

You can perform switchover to get back the original configuration

On current primary (proddb_st):
===============================
dgmgrl sys/sys@proddb_st
DGMGRL> show configuration;
DGMGRL> switchover to proddb;

Disable FSFO
dgmgrl sys/sys@proddb
DGMGRL> DISABLE FAST_START FAILOVER;

Stop observer:
==============
dgmgrl sys/sys@proddb_st
DGMGRL> stop observer;
