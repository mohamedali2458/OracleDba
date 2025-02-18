FSFO

set lines 300 pages 300
col name for a40
col value for a60
select name,value from v$parameter
where name in(
'local_listener','spfile','remote_login_passwordfile','db_unique_name','db_recovery_file_dest',
'db_recovery_file_dest_size','standby_file_management','log_archive_config','db_flashback_retention_target')
order by name;

select 'FORCE LOGGING' SCOPE,force_logging from v$database;

select 'PASSWORD FILE USERS' SCOPE, count(*) from v$pwfile_users
where username='SYS' and sysdba='TRUE' and authentication_type='PASSWORD';

SELECT 'SRL COUNT' SCOPE, COUNT(*) FROM V$LOGFILE WHERE TYPE='STANDBY';

SELECT 'FLASHBACK STATUS' SCOPE,FLASHBACK_ON FROM V$DATABASE;

flashback must be enabled in both primary and standby
to do this we need to stop mrp
alter database recover managed standby database cancel;
alter database flashback on;
alter database recover managed standby database using current logfile disconnect;

DGMGRL is a must, as Observer is a part of dgmgrl

dgmgrl sys/password
show configuration

for observer max availability is mandatory
from 19c max performance is enough

redo log transfer must be in sync

DGMGRL> show database oradb 'LogXptMode';
ASYNC

DGMGRL> show database oradb_s2 'LogXptMode';
ASYNC

DGMGRL> show database oradb 'NetTimeout';
NetTimeout = '30'

DGMGRL> show database oradb_s2 'NetTimeout';
NetTimeout = '30'

DGMGRL> edit database oradb set property NetTimeout=10;
Property "nettimeout" updated
DGMGRL> edit database oradb_s2 set property NetTimeout=10;
Property "nettimeout" updated

DGMGRL> enable fast_start failover;
Enabled in Potential Data Loss Mode.
(because we are still in maxperformance mode)

DGMGRL> enable fast_start failover observe only;

show configuration

DGMGRL> SHOW FAST_START FAILOVER;

go to observer host
tnsping testdg1
tnsping testdg2

dgmgrl sys/password@testdg1
dgmgrl> start observer;
show configuration;
show observer
stop observer

dgmgrl sys/testdg@testdg1 "start observer file='$ORACLE_HOME/dbs/fsfo.dat'" -logfile $ORACLE_HOME/dbs/observer.log &

tail -f $ORACLE_HOME/dbs/observer.log

open another session

show configuration;

col FS_FAILOVER_OBSERVER_HOST FOR A25
select FS_FAILOVER_STATUS, FS_FAILOVER_CURRENT_TARGET,FS_FAILOVER_THRESHOLD,FS_FAILOVER_OBSERVER_PRESENT,FS_FAILOVER_OBSERVER_HOST 
from v$database;

create 3 sessions to monitor (tail -f) 
1. observer log
2. primary alert log
3. standby alert log

shutdown abort; on primary

it will failover to standby

go to primary
startup mount;


go to testdg2
dgmgrl> show configuration;
give sometime to remove warnings
