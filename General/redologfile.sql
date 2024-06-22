REDOLOG FILE MANAGEMENT

Adding redo log group to the database

alter database add logfile group 4 '/u01/db1/redo04a.log' size 10m;

Adding redo log member to existing group
  
alter database add logfile member '/u01/db1/redo04b.log' to group 4;

Drop redo log member from the database
  
column member format a30
select group#, member from v$logfile;

alter database drop logfile member '/u01/db1/redo04b.log';

select group#, member from v$logfile order by 1;

Droping redo log group from database
  
select group#, member from v$logfile;

alter database drop logfile group 4;

Resizing redo log groups
  
select group#,status,bytes/1024/1024/1024 size_GB from v$log order by 1;

alter database add logfile group 4 '/u01/db1/redo04.log' size 100m;
alter database add logfile group 5 '/u01/db1/redo05.log' size 100m;
alter database add logfile group 6 '/u01/db1/redo06.log' size 100m;

do few log switches
  
alter system switch logfile;
/
/
/

select group#, members, status from v$log;

now drop the old ones
alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;

select group#, members, status, bytes from v$log;

now all will be of 100m size
