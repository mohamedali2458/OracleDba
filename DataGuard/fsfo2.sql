fsfo

--set below on Primary and Standby
alter system set DG_BROKER_START=TRUE SCOPE=BOTH;

--run below command on standby
alter system set LOG_ARCHIVE_DEST_2='';

show parameter BROKER

--Connect DGMGRL session on primary
dgmgrl sys/oracle@oradb as sysdba

show configuration;

DataGuardBroker.sql
===================
show configuration;
create configuration 'my_dg' as primarry database is 'oradb' connect identified is oradb;
add database oradb_s2 as connect identified is oradb_s2 maintained as physical;
show configuration;
edit database oradb set property staticconnectidentifier='';
edit database oradb_s2 set property staticconnectidentifier='';
edit database oradb set property ApplyLagThreshold=0;
edit database oradb set property TransportLagThreshold=0;
https://www.youtube.com/watch?v=-vEqwLQVBS0&list=PLQw5NrLjJKwPLkNtiDk_oXc9znwtnB7lB&index=4
3.59



https://youtu.be/ROcwqNmkYog
Fast-Start Failover FSFO Standby Part-1

DGMGRL> enable fast_start failover;

DGMGRL> show configuration;

DGMGRL> show database;

DGMGRL> enable fast_start failover observe only;

Installing and Running the Observer

DGMGRL> connect sys/<password>@orcl

DGMGRL> start observer;

Wrap the observer start-up in a script, so it reboots with 
the system or restarts automatically if needed 

nohup dgmgrl sys/<password>@orcl "start observer 
snob2 file is 
/u01/app/oracle/admin/db1/observer/fsfo.dat logfile is 
/u01/app/oracle/admin/db1/observer/snob2.log;" &

DGMGRL> show fast_start failover;

dgmgrl sys/<password>@orcl 

DGMGRL> show configuration verbose;

4:09