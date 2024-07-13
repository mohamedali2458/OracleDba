BACKUP AND RECOVERY (User Managed)
==================================
Backup:-Identical copy of the database.

Offline (Cold) backup
---------------------
Steps:
1. Shut down your database instance grace fully.
2. At OS level copy all datafiles, controlfiles and online redo log files (optional).
	$cp -v /u01/prod/*.dbf /u01/backup
	$cp -v /u01/prod/*.ctl /u01/backup
	$cp -v /u01/prod/*.log /u01/backup
3. Startup the database instance
	sqlplus / as sysdba
	sql> startup


Online (Hot) backup
-------------------
Steps:
1. Perform log switch
	alter system switch logfile;
2. Put the database into backup mode
	alter database begin backup; (from 10g onwards)
	select * from v$backup;
3. Go to OS level and copy all datafiles.
	$cp -v /u01/prod/*.dbf /u01/backup
4. End the backup mode of database.
	alter database end backup;
	select * from v$backup;
5. Take backup of control file.
	alter database backup controlfile to '/u01/backup/bkp1.ctl';
	alter database backup controlfile to trace as '/u01/backup/bkp2.sql';


Optional Steps
6. Backup archived logs (into Tape Cartridges)
7. Never backup Online Redologs.


Online Backup of Database Tablespace Wise
----------------------------------------- 
To backup data files of a particular Tablespace
Steps:
1. Perform Log Switch.
	alter system switch logfile;
2. Put the Tablespace into backup mode.
	alter tablespace users begin backup; (from 10g)
3. Go to OS level and copy all datafiles.
	$cp /u01/prod/users*.dbf /u01/backup
4. End the backup mode of tablespace.
	alter tablespace users end backup;

To check whether database is in backup mode:
select * from v$backup;











Important Views
---------------
v$backup
select * from v$backup;
V$BACKUP displays the backup status of all online datafiles.
Column	Datatype	Description
FILE#	NUMBER	File identifier
STATUS	VARCHAR2(18)	File status: NOT ACTIVE, ACTIVE (backup in progress), OFFLINE NORMAL, or description of an error
CHANGE#	NUMBER	System change number when backup started
TIME	DATE	Time the backup started



v$datafile
This view contains datafile information from the control file.
Column	Datatype	Description
FILE#	NUMBER	File identification number
CREATION_CHANGE#	NUMBER	Change number at which the datafile was created
CREATION_TIME	DATE	Timestamp of the datafile creation
TS#	NUMBER	Tablespace number
RFILE#	NUMBER	Tablespace relative datafile number
STATUS	VARCHAR2(7)	Type of file (system or user) and its status. Values: OFFLINE, ONLINE, SYSTEM, RECOVER, SYSOFF (an offline file from the SYSTEMtablespace)
ENABLED	VARCHAR2(10)	Describes how accessible the file is from SQL:
•	DISABLED - No SQL access allowed
•	READ ONLY - No SQL updates allowed
•	READ WRITE - Full access allowed
•	UNKNOWN - should not occur unless the control file is corrupted
CHECKPOINT_CHANGE#	NUMBER	SCN at last checkpoint
CHECKPOINT_TIME	DATE	Timestamp of the checkpoint#
UNRECOVERABLE_CHANGE#	NUMBER	Last unrecoverable change number made to this datafile. If the database is in ARCHIVELOGmode, then this column is updated when an unrecoverable operation completes. If the database is not in ARCHIVELOGmode, this column does not get updated.
UNRECOVERABLE_TIME	DATE	Timestamp of the last unrecoverable change. This column is updated only if the database is in ARCHIVELOGmode.
LAST_CHANGE#	NUMBER	Last change number made to this datafile (null if the datafile is being changed)
LAST_TIME	DATE	Timestamp of the last change
OFFLINE_CHANGE#	NUMBER	Offline change number of the last offline range. This column is updated only when the datafile is brought online.
ONLINE_CHANGE#	NUMBER	Online change number of the last offline range
ONLINE_TIME	DATE	Online timestamp of the last offline range
BYTES	NUMBER	Current datafile size (in bytes); 0 if inaccessible
BLOCKS	NUMBER	Current datafile size (in blocks); 0 if inaccessible
CREATE_BYTES	NUMBER	Size when created (in bytes)
BLOCK_SIZE	NUMBER	Block size of the datafile
NAME	VARCHAR2(513)	Name of the datafile
PLUGGED_IN	NUMBER	Describes whether the tablespace is plugged in. The value is 1 if the tablespace is plugged in and has not been made read/write, 0 if not.
BLOCK1_OFFSET	NUMBER	Offset from the beginning of the file to where the Oracle generic information begins. The exact length of the file can be computed as follows: BYTES + BLOCK1_OFFSET.
AUX_NAME	VARCHAR2(513)	Auxiliary name that has been set for this file via CONFIGURE AUXNAME
FIRST_NONLOGGED_SCN	NUMBER	First nonlogged SCN
FIRST_NONLOGGED_TIME	DATE	First nonlogged time

column name format a30
select file#, name from v$datafile;

v$controlfile
select name from v$controlfile;
V$CONTROLFILE displays the names of the control files.
Column	Datatype	Description
STATUS	VARCHAR2(7)	INVALID if the name cannot be determined (which should not occur); NULL if the name can be determined
NAME	VARCHAR2(513)	Name of the control file
IS_RECOVERY_DEST_FILE	VARCHAR2(3)	Indicates whether the file was created in the flash recovery area (YES) or not (NO)
BLOCK_SIZE	NUMBER	Control file block size
FILE_SIZE_BLKS	NUMBER	Control file size (in blocks)


v$datafile_header
select name, status from v$datafile_header;
V$DATAFILE_HEADER displays datafile information from the datafile headers.
Column	Datatype	Description
FILE#	NUMBER	Datafile number (from control file)
STATUS	VARCHAR2(7)	ONLINE | OFFLINE (from control file)
ERROR	VARCHAR2(18)	NULL if the datafile header read and validation were successful. If the read failed then the rest of the columns are NULL. If the validation failed then the rest of columns may display invalid data. If there is an error then usually the datafile must be restored from a backup before it can be recovered or used.
FORMAT	NUMBER	Indicates the format for the header block. The possible values are 6, 7, 8, or 0.
6 - indicates Oracle Version 6
7 - indicates Oracle Version 7
8 - indicates Oracle Version 8
0 - indicates the format could not be determined (for example, the header could not be read)
RECOVER	VARCHAR2(3)	File needs media recovery (YES | NO)
FUZZY	VARCHAR2(3)	File is fuzzy (YES | NO)
CREATION_CHANGE#	NUMBER	Datafile creation change#
CREATION_TIME	DATE	Datafile creation timestamp
TABLESPACE_NAME	VARCHAR2(30)	Tablespace name
TS#	NUMBER	Tablespace number
RFILE#	NUMBER	Tablespace relative datafile number
RESETLOGS_CHANGE#	NUMBER	Resetlogs change#
RESETLOGS_TIME	DATE	Resetlogs timestamp
CHECKPOINT_CHANGE#	NUMBER	Datafile checkpoint change#
CHECKPOINT_TIME	DATE	Datafile checkpoint timestamp
CHECKPOINT_COUNT	NUMBER	Datafile checkpoint count
BYTES	NUMBER	Current datafile size in bytes
BLOCKS	NUMBER	Current datafile size in blocks
NAME	VARCHAR2(513)	Datafile name
SPACE_HEADER	VARCHAR2(40)	The amount of space currently being used and the amount that is free, as identified in the space header
LAST_DEALLOC_SCN	VARCHAR2(16)	Last deallocated SCN


To take the backup of Oracle Software / Binaries (ORACLE_HOME)
Steps:
1. Stop the db services (instance, listener)
2. Backup the software
	$cp -R $ORACLE_HOME /u01/backup/orasoft
3. Startup the db services (instance, listener)














BACKUP AND RECOVERY (User Managed) - 2
======================================
Recovery Scenarios
1. Loss of non-system datafile.
Steps:
	1. Restore the loss datafile.
	     $cp/u01/backup/users01.dbf /u01/prod
	2. Offline the datafile
	     alter database datafile '/u01/prod/users01.dbf' offline;
	     select ts#, file#, status from v$datafile order by 1,2;
	3. Recover datafile.
	recover datafile 4;
	4. Online the datafile.
	alter database datafile 4 online;

2. Loss of system datafile.
Steps:
	1. Shut abort and start the database in mount stage.
	2. Restore the system datafile
		$cp /u01/backup/system01.dbf /u01/prod/
	3. Recover database or recover system datafile.
		recover datafile '/u01/prod/system01.dbf';
	4. Open the database.
		alter database open;

3. Loss of all datafiles.
Steps:
	1. Shut abort and start the database in mount stage.
	2. Restore all the datafiles.
		$cd /u01/prod
		$cp /u01/backup/*.dbf .
	3. Recover  the database.
		recover database;
	4. Open the database
		alter database open;

4. Loss of all control files
Steps:
	1. select group#, status from v$log;
	2. note down the current logfile sequence.
	3. delete or move the control files in a working db.
	4. Shut abort;
	5. start the database in nomount stage(as we don’t have ctl files).
	6. Restore the control files from recent online backup.
		$cd /u01/prod
		$cp /u01/backup/bkp.ctl conrol01.ctl
		$cp /u01/backup/bkp.ctl conrol02.ctl
	7. Recover database using backup controlfile.
		sql> recover database using backup controlfile until cancel;
		specify redo logfile (online) that has unarchived data(if required)
	8. Open the database with resetlogs.
		sql> alter database open resetlogs;
	9. Take full backup of database (recommended).

5. Loss of online redo log files
steps: when status is (current or active)
	1. shut down the database grace fully.
	2. start the database in mount stage.
	3. recover database and open with resetlogs.
	sql> alter database recover automatic using backup controlfile until cancel;
	sql> recover cancel;
	sql> alter database open resetlogs;
	4. Take full backup of database.

6. Recovering datafile without backup
steps:
	1. offline the datafile.
	sql> alter database datafile 5 offline;
	2. create new datafile with same name and location.
	sql> alter database create datafile 5;
	3. Recover the datafile.
	sql> recover datafile 5;
	4. online the datafile
	sql> alter database datafile 5 online;

7. Time based recovery
	Steps:
	1. Restore the damaged files from the backup.
	2. Mount the database.
	3. Start the recovery.
	sql> recover database until time '1999-01-01:12:00:00';
	4. Open the database with resetlogs;
	5. Take full backup of database.

What happens on db resetlogs
When we open the database with resetlogs a new resetid will generate and logseq number will set to 1.  If the logfiles are not there then it will create new redolog files.
Whenever you perform incomplete recovery or recovery with a backup control file, you must reset the online logs when you open the database. The new version of the reset database is called a new incarnation.

About Opening with the RESETLOGS Option
The RESETLOGS option is always required after incomplete media recovery or recovery using a backup control file. Resetting the redo log does the following:
•	Archives the current online redo logs (if they are accessible) and then erases the contents of the online redo logs and resets the log sequence number to 1. For example, if the current online redo logs are sequence 1000 and 1001 when you open RESETLOGS, then the database archives logs 1000 and 1001 and then resets the online logs to sequence 1 and 2.
•	Creates the online redo log files if they do not currently exist.
•	Reinitializes the control file metadata about online redo logs and redo threads.
•	Updates all current datafiles and online redo logs and all subsequent archived redo logs with a new RESETLOGS SCN and time stamp.
Because the database will not apply an archived log to a datafile unless the RESETLOGS SCN and time stamps match, the RESETLOGS prevents you from corrupting datafiles with archived logs that are not from direct parent incarnations of the current incarnation.
In prior releases, it was recommended that you back up the database immediately after the RESETLOGS. Because you can now easily recover a pre-RESETLOGS backup like any other backup, making a new database backup is optional. In order to perform recovery through resetlogs you must have all archived logs generated since the last backup and at least one control file (current, backup, or created).
Figure below shows the case of a database that can only be recovered to log sequence 2500 because an archived redo log is missing. When the online redo log is at sequence 4000, the database crashes. You restore the sequence 1000 backup and prepare for complete recovery. Unfortunately, one of your archived logs is corrupted. The log before the missing log contains sequence 2500, so you recover to this log sequence and open RESETLOGS. As part of the RESETLOGS, the database archives the current online logs (sequence 4000 and 4001) and resets the log sequence to 1.
You generate changes in the new incarnation of the database, eventually reaching log sequence 4000. The changes between sequence 2500 and sequence 4000 for the new incarnation of the database are different from the changes between sequence 2500 and sequence 4000 for the old incarnation. You cannot apply logs generated after 2500 in the old incarnation to the new incarnation, but you can apply the logs generated before sequence 2500 in the old incarnation to the new incarnation. The logs from after sequence 2500 are said to be orphaned in the new incarnation because they are unusable for recovery in that incarnation.
 

Executing the ALTER DATABASE OPEN Statements
To preserve the log sequence number when opening a database after media recovery, execute either of the following statements:
ALTER DATABASE OPEN NORESETLOGS;
ALTER DATABASE OPEN;

To reset the log sequence number when opening a database after recovery and thereby create a new incarnation of the database, execute the following statement:
ALTER DATABASE OPEN RESETLOGS;

If you open with the RESETLOGS option, the database returns different messages depending on whether recovery was complete or incomplete. If the recovery was complete, then the following message appears in the alert_SID.log file:
RESETLOGS after complete recovery through change scn

If the recovery was incomplete, then this message is reported in the alert_SID.log file, where scn refers to the end point of incomplete recovery:
RESETLOGS after incomplete recovery UNTIL CHANGE scn

If you attempt to OPEN RESETLOGS when you should not, or if you neglect to reset the log when you should, then the database returns an error and does not open the database. Correct the problem and try again.

Checking the Alert Log After a RESETLOGS Operation
After opening the database with the RESETLOGS option, check the alert_SID.log to see whether the database detected inconsistencies between the data dictionary and the control file, for example, a datafile that the data dictionary includes but which is not listed in the new control file. The following table describes two possible scenarios.
Control File	Data Dictionary	Result
Datafile is listed	Datafile is not listed	References to the unlisted datafile are removed from the control file. A message in the alert log indicates what was found.
Datafile is not listed	Datafile is listed	The database creates a placeholder entry in the control file under MISSINGnnnnn (where nnnnn is the file number in decimal). MISSINGnnnnn is flagged in the control file as offline and requiring media recovery. You can make the datafile corresponding to MISSINGnnnnn accessible by using ALTER DATABASE RENAME FILE for MISSINGnnnnn so that it points to the datafile. If you do not have a backup of this datafile, then drop the tablespace.
