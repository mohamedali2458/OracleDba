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
