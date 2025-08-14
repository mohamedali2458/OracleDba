--backup of controlfile to trace
SQL> alter database backup controlfile to trace as '/u01/backup.ctl';

SQL> alter database backup controlfile to trace;

SQL> alter database backup controlfile to '/u02/oradata/backup/control.bkp';

--Multiplexing the Control file

set linesize 200
col name for a90
select name from v$controlfile;

show parameter control_files;

--we got 2 control files and we are adding the 3rd one
sql> alter system set control_files='/u01/prod/control01.ctl', '/u01/prod/control02.ctl','/u01/prod/control03.ctl' SCOPE=spfile;

SQL> shutdown immediate;

SQL> ! cp /u01/prod/control01.ctl /u01/prod/control03.ctl

sql> startup

set linesize 200
col name for a90
select name from v$controlfile;


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
