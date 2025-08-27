--Reinstate the old Primary as a Standby after failover with broker

primary:
select open_mode, database_role, flashback_on from v$database;

alter system switch logfile;

archive log list;

standby:
select open_mode, database_role, flashback_on from v$database;

select sequence#, process, status from v$managed_standby;

--both sides flashback is on.
--both sides archivelog sequence no is same 

--to create failover situation, shutdown the primary 

--p
shut immediate;

select sequence#, process, status from v$managed_standby;

-- we can notice RFS is missing as primary is down 

exit;

--S
dgmgrl sys/manager 

DGMGRL> show configuration;

--primary is showing as ORA-1034: oracle not available

DGMGRL> failover to standbydb;

DGMGRL> show configuration;

--now standby is the new primary
SQL> select database_role, open_mode from v$database;

SQL> def 

archive log list 
--sequence got reset to 1

--do some log switches

alter system switch logfile;

/

/

/

archive log list;

--connect to old primary 
SQL> startup mount;

--we cannot start it normally as its still primary

SQL> select open_mode, database_role from v$database;

SQL> def 

exit;

dgmgrl sys/manager

DGMGRL> show configuration;

DGMGRL> reinstate database primarydb;

DGMGRL> show configuration;

--old primary 
select open_mode, database_role from v$database;

select sequence#, process, status from v$managed_standby;

DGMGRL> switchover to primarydb;

DGMGRL> show configuration;

--same as old 
