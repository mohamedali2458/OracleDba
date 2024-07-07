CONTROL FILE AND REDOLOG FILE MANAGEMENT
========================================

Control File Management
=======================
SQL> alter database backup controlfile to trace as '/u01/backup.ctl';
(Backup of ControlFile)

Multiplexing the Control file
Steps:-
1. select name from v$controlfile; 
(suppose we have 2 files only and we want to add a 3rd control file)

sql> alter system set control_files='/u01/prod/control01.ctl', '/u01/prod/control02.ctl','/u01/prod/control03.ctl' SCOPE=spfile;
SQL> shutdown immediate;
2. $cp /u01/prod/control01.ctl /u01/prod/control03.ctl
3. sql> startup
4. sql> select name from v$controlfile;

Important Views

v$controlfile
select name from v$controlfile;
V$CONTROLFILE displays the names of the control files.




Redolog file management
=======================
select * from v$log;
select * from v$logfile;

Adding redo log group to the database
alter database add logfile 
group 4 '/u01/prod/redo04a.log'
size 10m;

Adding redo log member to existing group
alter database 
add logfile member '/u01/prod/redo04b.log'
to group 4;

Drop  redo log member from the database

column member format a30
select group#, member from v$logfile;

alter database drop logfile 
member '/u01/prod/redo04b.log';

select group#, member from v$logfile order by 1;

Droping redo log group from database
select group#, member from v$logfile;
alter database drop logfile group 4;

Resizing redo log groups
select group#, status, bytes/1024/1024 MB from v$log order by 1;
alter database add logfile group 4 '/u01/prod/redo04.log' size 100m;
alter database add logfile group 5 '/u01/prod/redo05.log' size 100m;
alter database add logfile group 6 '/u01/prod/redo06.log' size 100m;
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

select group#, members, status,bytes from v$log;

now all will be of 100m size

Important views

v$log
V$LOG displays log file information from the control file.

v$logfile
This view contains information about redo log files.





9. Managing Control Files
What is a Control File ?
Every Oracle Database has a control file, which is a small binary file that records the physical structure of the database. The control file includes:
    •	The database name
    •	Names and locations of associated datafiles and redo log files
    •	The timestamp of the database creation
    •	The current log sequence number
    •	Checkpoint information
The control file must be available for writing by the Oracle Database server whenever the database is open. 
Without the control file, the database cannot be mounted and recovery is difficult.
The control file of an Oracle Database is created at the same time as the database. 
By default, at least one copy of the control file is created during database creation. 
On some operating systems the default is to create multiple copies. You should create 
two or more copies of the control file during database creation. You can also create 
control files later, if you lose control files or want to change particular settings 
in the control files.


Guidelines for Control Files
Guidelines you can use to manage the control files for a database, and contains the following topics:

Provide Filenames for the Control Files
You specify control file names using the CONTROL_FILES initialization parameter in the database 
initialization parameter file. The instance recognizes and opens all the listed files during 
startup, and the instance writes to and maintains all listed control files during database operation.

If you do not specify files for CONTROL_FILES before database creation:
•	If you are not using Oracle-managed files, then the database creates a 
control file and uses a default filename. The default name is operating system specific.
•	If you are using Oracle-managed files, then the initialization parameters you set 
to enable that feature determine the name and location of the control files, as 
described in Chapter 15, "Using Oracle-Managed Files".
•	If you are using Automatic Storage Management, you can place incomplete ASM filenames 
in the DB_CREATE_FILE_DEST and DB_RECOVERY_FILE_DEST initialization parameters. 
ASM then automatically creates control files in the appropriate places. 

Multiplex Control Files on Different Disks
Every Oracle Database should have at least two control files, each stored on a different 
physical disk. If a control file is damaged due to a disk failure, the associated instance 
must be shut down. Once the disk drive is repaired, the damaged control file can be restored 
using the intact copy of the control file from the other disk and the instance can be restarted. 
In this case, no media recovery is required.

The behavior of multiplexed control files is this:
•	The database writes to all filenames listed for the initialization parameter 
CONTROL_FILES in the database initialization parameter file.
•	The database reads only the first file listed in the CONTROL_FILES parameter during database operation.
•	If any of the control files become unavailable during database operation, the instance becomes 
inoperable and should be aborted.

Note: Oracle strongly recommends that your database has a minimum of two control files and that 
they are located on separate physical disks.
One way to multiplex control files is to store a control file copy on every disk drive that 
stores members of redo log groups, if the redo log is multiplexed. By storing control files 
in these locations, you minimize the risk that all control files and all groups of the redo 
log will be lost in a single disk failure.

Back Up Control Files
It is very important that you back up your control files.  This is true initially, and every 
time you change the physical structure of your database.  Such structural changes include:
•	Adding, dropping, or renaming datafiles
•	Adding or dropping a tablespace, or altering the read/write state of the tablespace
•	Adding or dropping redo log files or groups

Manage the Size of Control Files
The main determinants of the size of a control file are the values set for the MAXDATAFILES, 
MAXLOGFILES, MAXLOGMEMBERS, MAXLOGHISTORY, and MAXINSTANCES parameters in the CREATE DATABASE 
statement that created the associated database.  Increasing the values of these parameters 
increases the size of a control file of the associated database.


Creating Control Files
Creating Initial Control Files
The initial control files of an Oracle Database are created when you issue the CREATE DATABASE 
statement. The names of the control files are specified by the CONTROL_FILES parameter in the 
initialization parameter file used during database creation. The filenames specified in CONTROL_FILES 
should be fully specified and are operating system specific. The following is an example of 
a CONTROL_FILES initialization parameter:

CONTROL_FILES = (/home/oracle/test/control01.ctl,
                 /home/oracle/test/control02.ctl,
			           /home/oracle/test/control03.ctl)

If files with the specified names currently exist at the time of database creation, you must specify the 
CONTROLFILE REUSE clause in the CREATE DATABASE statement, or else an error occurs. Also, if the size of 
the old control file differs from the SIZE parameter of the new one, you cannot use the REUSE clause.

The size of the control file changes between some releases of Oracle Database, as well as when the 
number of files specified in the control file changes. Configuration parameters such as MAXLOGFILES, 
MAXLOGMEMBERS, MAXLOGHISTORY, MAXDATAFILES, and MAXINSTANCES affect control file size.

You can subsequently change the value of the CONTROL_FILES initialization parameter to add more 
control files or to change the names or locations of existing control files.

Creating Additional Copies, Renaming, and Relocating Control Files
You can create an additional control file copy for multiplexing by copying an existing control 
file to a new location and adding the file name to the list of control files. Similarly, you 
rename an existing control file by copying the file to its new name or location, and changing 
the file name in the control file list. In both cases, to guarantee that control files do not 
change during the procedure, shut down the database before copying the control file.

To add a multiplexed copy of the current control file or to rename a control file:
•	Shut down the database.
•	Copy an existing control file to a new location, using operating system commands.
•	Edit the CONTROL_FILES parameter in the database initialization parameter file to add the 
new control file name, or to change the existing control filename.
•	Restart the database.



Creating New Control Files
When to Create New Control Files
It is necessary for you to create new control files in the following situations:
•	All control files for the database have been permanently damaged and you do not have a control file backup.
•	You want to change the database name.

For example, you would change a database name if it conflicted with another database name in a distributed environment.
Note: You can change the database name and DBID (internal database identifier) using the DBNEWID utility.

•	The compatibility level is set to a value that is earlier than 10.2.0, and you must make a change to 
an area of database configuration that relates to any of the following parameters from the CREATE DATABASE 
or CREATE CONTROLFILE commands: MAXLOGFILES, MAXLOGMEMBERS, MAXLOGHISTORY, and MAXINSTANCES.  

If compatibility is 10.2.0 or later, you do not have to create new control files when you make such a change; 
the control files automatically expand, if necessary, to accommodate the new configuration information.
For example, assume that when you created the database or recreated the control files, you set MAXLOGFILES 
to 3.  Suppose that now you want to add a fourth redo log file group to the database with the ALTER DATABASE 
command.  If compatibility is set to 10.2.0 or later, you can do so and the controlfiles automatically expand 
to accommodate the new logfile information.  However, with compatibility set earlier than 10.2.0, your ALTER 
DATABASE command would generate an error, and you would have to first create new control files.


The CREATE CONTROLFILE Statement
You can create a new control file for a database using the CREATE CONTROLFILE statement.  The following 
statement creates a new control file for the test database (a database that formerly used a different 
database name):

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

Note: The CREATE CONTROLFILE statement can potentially damage specified datafiles and redo log files.  
Omitting a filename can cause loss of the data in that file, or loss of access to the entire database.  

If the database had forced logging enabled before creating the new control file, and you want it to 
continue to be enabled, then you must specify the FORCE LOGGING clause in the CREATE CONTROLFILE statement.



Steps for Creating New Control Files
Complete the following steps to create a new control file:
1.	Make a list of all datafiles and redo log files of the database.

If you follow recommendations for control file backups as discussed in "Backing Up Control Files", 
you will already have a list of datafiles and redo log files that reflect the current structure of 
the database. However, if you have no such list, executing the following statements will produce one.

SELECT MEMBER FROM V$LOGFILE;

SELECT NAME FROM V$DATAFILE;

SELECT VALUE FROM V$PARAMETER WHERE NAME = 'control_files';

If you have no such lists and your control file has been damaged so that the database cannot be 
opened, try to locate all of the datafiles and redo log files that constitute the database. 
Any files not specified in step 5 are not recoverable once a new control file has been created. 
Moreover, if you omit any of the files that make up the SYSTEM tablespace, you might not be 
able to recover the database.

2.	Shutdown the database.

If the database is open, shut down the database normally if possible.  Use the IMMEDIATE or 
ABORT clauses only as a last resort.

3.	Back up all datafiles and redo log files of the database.

4.	Start up a new instance, but do not mount or open the database.

STARTUP NOMOUNT

5.	Create a new control file for the database using the CREATE CONTROLFILE statement.

When creating a new control file, specify the RESETLOGS clause if you have lost any redo log groups 
in addition to control files. In this case, you will need to recover from the loss of the redo 
logs (step 8). You must specify the RESETLOGS clause if you have renamed the database. 
Otherwise, select the NORESETLOGS clause.

6.	Store a backup of the new control file on an offline storage device.

7.	Edit the CONTROL_FILES initialization parameter for the database to indicate all of 
the control files now part of your database as created in step 5 (not including the 
backup control file). If you are renaming the database, edit the DB_NAME parameter 
in your instance parameter file to specify the new name.

8.	Recover the database if necessary. If you are not recovering the database, skip to step 9.

If you are creating the control file as part of recovery, recover the database. If the new 
control file was created using the NORESETLOGS clause (step 5), you can recover the database 
with complete, closed database recovery.

If the new control file was created using the RESETLOGS clause, you must specify USING BACKUP 
CONTROL FILE. If you have lost online or archived redo logs or datafiles, use the procedures 
for recovering those files.

9.	Open the database using one of the following methods:

If you did not perform recovery, or you performed complete, closed database recovery in step 8, 
open the database normally.

alter database open;

If you specified RESETLOGS when creating the control file, use the ALTER DATABASE statement, indicating RESETLOGS.

ALTER DATABASE OPEN RESETLOGS;

The database is now open and available for use.
