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





--Steps for Creating New Control Files
--1.	Make a list of all datafiles and redo log files of the database.
SELECT MEMBER FROM V$LOGFILE;

SELECT NAME FROM V$DATAFILE;

SELECT VALUE FROM V$PARAMETER WHERE NAME = 'control_files';

--2.	Shutdown the database.
shutdown abort;

--3.	Back up all datafiles and redo log files of the database.

--4.	Start up a new instance, but do not mount or open the database.

sql> startup nomount;

--5.	Create a new control file for the database using the CREATE CONTROLFILE statement.

--6.	Store a backup of the new control file on an offline storage device.

--7.	Edit the CONTROL_FILES initialization parameter for the database to indicate all of the control files now part of your database as created in step 5 (not including the backup control file). If you are renaming the database, edit the DB_NAME parameter in your instance parameter file to specify the new name.

--8.	Recover the database if necessary. If you are not recovering the database, skip to step 9.

--9.	Open the database using one of the following methods:

sql> alter database open;

sql> ALTER DATABASE OPEN RESETLOGS;



--creating lost control file manually based on available files
CREATE CONTROL FILE SET DATABASE test
	LOGFILE GROUP 1 ('/u01/prod/redo01_01.log','/u01/prod/redo01_02.log'),
		  GROUP 2 ('/u01/prod/redo02_01.log','/u01/prod/redo02_02.log'),
              GROUP 3 ('/u01/prod/redo03_01.log’,'/u01/prod/redo03_02.log')
RESETLOGS
DATAFILE '/u01/prod/system01.dbf' SIZE 100M,
         '/u01/prod/rbs01.dbf' SIZE 100M,
         '/u01/prod/users01.dbf' SIZE 100M,
         '/u01/prod/temp01.dbf' SIZE 50M
MAXLOGFILES 50
MAXLOGMEMBERS 3
MAXLOGHISTORY 400
MAXDATAFILES 200
MAXINSTANCES 6
ARCHIVELOG;
