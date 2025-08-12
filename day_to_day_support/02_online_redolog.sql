--Online Redologs
  
set linesize 300
select * from v$log order by group#;

set linesize 300
col member for a80
select * from v$logfile order by group#;

SELECT A.GROUP#,B.MEMBER,THREAD#,SEQUENCE#,ROUND(BYTES/1024/1024/1024) "GB",MEMBERS,ARCHIVED,A.STATUS
FROM V$LOG A, V$LOGFILE B
WHERE A.GROUP# = B.GROUP#
ORDER BY A.GROUP#;

--Adding redo log group to the database
alter database add logfile 
group 4 '/u01/prod/redo04a.log'
size 50m;

--Adding redo log member to existing group
alter database 
add logfile member '/u01/prod/redo04b.log'
to group 4;


--Drop  redo log member from the database
column member format a80
select group#, member from v$logfile;

alter database drop logfile 
member '/u01/prod/redo04b.log';

select group#, member from v$logfile order by 1;

--Droping redo log group from database
select group#, member from v$logfile;

alter database drop logfile group 4;


--Resizing redo log groups
select group#, status, round(bytes/1024/1024) MB from v$log order by group#;

alter database add logfile group 4 '/u01/prod/redo04.log' size 100m;
alter database add logfile group 5 '/u01/prod/redo05.log' size 100m;
alter database add logfile group 6 '/u01/prod/redo06.log' size 100m;

--do few log switches
alter system switch logfile;
/
/
/

select group#, members, status from v$log;

--now drop the old ones, make sure their status is IN-ACTIVE before drop
alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;

select group#, members, status,bytes from v$log;
--now all will be of 100m size


--Redolog File Multiplexing

--Check redolog file members

SQL> select member from v$logfile;

--To check redolog group info,status and size
SQL> select group#, members, status, sum(bytes/1024/1024) "Mb" from v$log group by group#,members,status;

--To add a redolog file group
SQL> alter database add logfile group 4('/u01/prod/redo04a.log','/u02/prod/redo04b.log') size 50m;

--To add a redolog member
SQL> alter database add logfile member '/u02/prod/redo01b.log' to group 1;

--To drop a redolog group
SQL> alter database drop logfile group 4;

--To drop a redolog member
SQL> alter database drop logfile member '/u02/prod/redo01b.log';

--Rename or Relocate Redolog file, shutdown the DB
SQL> shutdown immediate;
SQL>! cp /u02/prod/redo01.log /u02/prod/redo01a.log
--(If relocating, use the source and destination paths)

SQL> startup mount
SQL> alter database rename file '/u02/prod/redo01.log' to '/u02/prod/redo01a.log';

SQL> alter database open;
--The server process will update Control File with new redolog location.
