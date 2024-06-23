Configuring Oracle Data Guard Broker for High Availability

Oracle Data Guard is one of the finest technology that is developed by Oracle. It is created in order to have high 
availability of database even when your production system crashes due to natural disaster or server crash.

When you setup Data Guard, you will have to manually monitor the log shipping, log apply and resolve any gaps. 
Even for switchover and failover, you need to perform the activities manually.


In a data guard configuration, you will observe
    One primary database and combination of standby databases
    Connected by Oracle Net service
    Primary & standby may reside in different geographic locations
    Standby stays in sync with primary by applying redo


Oracle Data Guard Broker

Let us understand the literal meaning of Broker first

A mediator between two or more person (things)

In a data guard configuration, we know that there are minimum two servers that take part: one is primary and another one is standby.

A data guard broker logically groups these primary and standby databases into a Broker Configuration. This allows Data Guard broker 
to manage and monitor (primary and standby) as one single unit.


Benefits of Data Guard Broker

One of the biggest benefits of Data Guard broker is that is centralizes the configuration, management and monitoring of Oracle Data Guard configurations.

Some of the operations that Data Guard broker simplifies are
    Create Data Guard configuration between primary and standby databases
    Add additional standby databases to existing Data Guard configuration
    Mange Data Guard protection modes
    Start switchover / failover by just one single command
    Automate failover in case of primary not reachable
    Monitor redo apply, gaps and data guard performance
    Perform all above operations locally or remotely !

Configure Data Guard Broker

Follow below steps to configure Data Guard broker.

Note: At the time of writing article, below steps were performed on existing Primary and Standby setup that was created manually.

Edit listeners

If you look at the listener configuration file, there is a dedicated service we have to create for DGMGRL. This is required in order 
enable Data Guard Broker. If this is not set, add below entry (proddb_DGMGRL and it has to be exactly in the same format <SID>_DGMGRL) 
and restart listener on both primary and standby

su - grid
cd $ORACLE_HOME/network/admin
cat listener.ora

LISTENER =
 (DESCRIPTION_LIST =
   (DESCRIPTION =
     (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.211)(PORT = 1521))
     (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
   )
 )

SID_LIST_LISTENER=
 (SID_LIST=
   (SID_DESC=
     (GLOBAL_DBNAME=proddb)
     (SID_NAME=proddb)
     (ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1)
   )
   (SID_DESC=
     (GLOBAL_DBNAME=proddb_DGMGRL)
     (SID_NAME=proddb)
     (ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1)
   )
 )   


Stop MRP on standby

We would like to manage our data guard configuration using Data Guard Broker. Stop MRP and clear Log_Archive_dest_2 parameter

On standby:
===========
SQL> alter database recover managed standby database cancel;
SQL> alter system set LOG_ARCHIVE_DEST_2='' SCOPE=BOTH sid='*';

On primary:
===========
SQL> alter system set LOG_ARCHIVE_DEST_2='' SCOPE=BOTH sid='*';


Enable broker

We need to start the broker by enabling it on both primary and standby

On primary:
===========
SQL> alter system set dg_broker_start=true;
SQL> show parameter dg_broker_start;

On standby:
===========
SQL> alter system set dg_broker_start=true;
SQL> show parameter dg_broker_start;


Register primary with broker

On primary, connect to DGMGRL utility and register the primary database with broker

On primary:
===========
dgmgrl sys/sys@proddb
DGMGRL> create configuration proddb as primary database is proddb connect identifier is proddb;
DGMGRL> show configuration;


Register standby with broker

In the same DGMGRL utility, register standby from primary server itself

DGMGRL> add database proddb_st as connect identifier is proddb_st;
DGMGRL> show configuration;


Enable Data Guard broker

Once primary and standby are registered, we must enable broker

DGMGRL> ENABLE CONFIGURATION;
DGMGRL> SHOW CONFIGURATION;
DGMGRL> SHOW DATABASE proddb;
DGMGRL> SHOW DATABASE proddb_st;


Manage Redo Apply via Broker

Like how we start / stop MRP manually, we can start / stop redo apply on standby using broker

Stop log apply:
===============
dgmgrl sys/sys@proddb
DGMGRL> show configuration;
DGMGRL> show database proddb_st;
DGMGRL> edit database proddb_st set state=APPLY-OFF;
DGMGRL> show database proddb_st;

Start log apply:
================
dgmgrl sys/sys@proddb
DGMGRL> show configuration;
DGMGRL> show database proddb_st;
DGMGRL> edit database proddb_st set state=APPLY-ON;
DGMGRL> show database proddb_st;


Start/stop log shipping via Broker

How we can manually enable log shipping from primary to standby, the same way we can use broker to enable log shipping

Disable log shipping/transport:
===============================
dgmgrl sys/sys@proddb
DGMGRL> show configuration;
DGMGRL> show database proddb;
DGMGRL> edit database proddb set state=TRANSPORT-OFF;
DGMGRL> show database proddb;

Enable log shipping/transport:
==============================
dgmgrl sys/sys@proddb
DGMGRL> show configuration;
DGMGRL> show database proddb;
DGMGRL> edit database proddb set state=TRANSPORT-ON;
DGMGRL> show database proddb;
