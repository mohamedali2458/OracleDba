Oracle Data Guard Manual Switchover and Failover on Physical Standby

  
Perform Manual Switchover on Physical Standby

Connect to proddb database via client and keep querying below

sqlplus sys/sys@proddb as sysdba

select name, open_mode, db_unique_name, database_role from v$database;

NAME      OPEN_MODE      DB_UNIQUE_NAME         DATABASE_ROLE
--------- -------------- ---------------------- --------------
proddb    READ WRITE     proddb                 PRIMARY

Check primary and standby for any gaps

On primary:
===========
select STATUS, GAP_STATUS from V$ARCHIVE_DEST_STATUS where DEST_ID = 2;

On standby:
===========
select NAME, VALUE, DATUM_TIME from V$DATAGUARD_STATS;

We will first convert primary to standby and later standby to primary

On primary:
===========
select SWITCHOVER_STATUS from V$DATABASE;

You must see TO STANDBY or SESSIONS ACTIVE

alter database commit to switchover to physical standby with session shutdown;

startup mount;

At this stage, there is no primary to accept queries from client. Run below query on client putty terminal. The query will hang and wait until standby is converted to primary

select name, open_mode, db_unique_name, database_role from v$database;

Convert standby to primary: Our primary is already converted to standby. Now it’s time to convert original standby into primary

select SWITCHOVER_STATUS from V$DATABASE;

alter database commit to switchover to primary with session shutdown;

alter database open;

At this stage, the client query would execute successfully!


On new standby – Initially your primary database: Start MRP

alter database recover managed standby database disconnect;

Revert back: Once again follow the above process from top and re-execute steps in proper databases to revert back to original setup.
