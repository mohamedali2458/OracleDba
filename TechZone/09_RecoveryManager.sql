RECOVERY Manager - 1
====================
RMAN client utility:
rman (executable) -> $ORACLE_HOME/bin
recover.bsq -> $ORACLE_HOME/admin/recover.bsq

PL/SQL Packages
dbms_backup_restore
dbms_revcat	owned by user sys

Connecting to the Target Database Without a Catalog from the Command Line
$rman target / nocatalog

To backup the db (all datafiles)
RMAN> backup database;

It generates backup pieces and stores in $ORACLE_HOME/dbs folder and backup 
set (backup info) into the target db controlfile.

Basic commands for rman:
========================
To backup a single datafile
RMAN> backup datafile 4;

To backup a single tablespace
RMAN> backup tablespace users;

To backup controlfile
RMAN> backup current controlfile;

To backup all archive log files
RMAN> backup archivelog all;

To backup spfile
RMAN> backup spfile;

To backup archive logs and delete them
RMAN> backup archivelog all delete input;

To backup all files at a time
RMAN> backup database include current controlfile plus archivelog;
RMAN> backup database include current controlfile plus archivelog delete input;

To store backup (piece) in a particular location
RMAN> backup database format '/u01/bkp/full_bkp_%U';

List & Report Commands
======================
To get information about backups
RMAN> list backup;
RMAN> list backup of database;
RMAN> list backup of datafile 7;
RMAN> LIST BACKUP OF DATAFILE '/u01/app/oracle/oradata/ORADB/users01.dbf';
RMAN> list backup of archivelog all;
RMAN> list backup of controlfile;
RMAN> list backup of spfile;
RMAN> list backup of tablespace users;

RMAN> list archivelog all;

RMAN> list backupset 44;

RMAN> list datafilecopy all;
RMAN> list datafilecopy 26;
RMAN> LIST DATAFILECOPY '/u01/app/oracle/copy/users01.dbf';

RMAN> LIST COPY OF CONTROLFILE;

RMAN> LIST CONTROLFILECOPY 20;

Incarnations
============
The LIST INCARNATION command shows the incarnations of the database. 
Note that multiple incarnations may share the same database ID.

RMAN> LIST INCARNATION;

set linesize 300 pagesize 200
col inputbytes for a20
col outputbytes for a20
col timetaken for a30
select session_key, input_type, status, start_time, end_time,
round(elapsed_seconds) elap_sec, input_bytes_display "InputBytes", output_bytes_display "OutputBytes",
output_device_type "Device", autobackup_count "Auto_Cnt", autobackup_done "AutoStatus", time_taken_display "TimeTaken"
from v$rman_backup_job_details
order by session_key;


rman> list backup summary;

LV column lists the following:
0 = incremental level 0 backup
1 = incremental level 1 backup
A = archivelogs
F = full - backup database command

S is the status:
A = available
U = unavailable

As mentioned above F can represent either “FULL” backup or “Control File” Backup. 
If your RMAN configuration is for controlfile auto-backup is set to “ON”, the 
control file backup will be taken automatically each time RMAN backup runs as 
shown in the above picture.




To delete backup
RMAN> delete backup;
noprompt



Recovery Manager - II
=====================
Catalog (tables & views) -> Central repository that stores information of backups.

Configure catalog:
In a separate box (machine) install Oracle software. The version must be same or higher from the 
target databases and configure the Listener and do the following:

Steps:
a) Create a new database for the catalog : rman
b) Create a tablespace: rmants
SET LINESIZE 300
COL NAME FOR A100
SELECT FILE#,NAME FROM V$DATAFILE ORDER BY FILE#;

CREATE TABLESPACE rmants DATAFILE '/u01/app/oracle/oradata/RMAN/rmants01.dbf' SIZE 100M;

c) Create a user: rman and assign the above tablespace rmants as default
CREATE USER rman IDENTIFIED BY rman DEFAULT TABLESPACE rmants QUOTA UNLIMITED ON rmants;

d) Grant resource and recovery_catalog_owner roles (privileges) to rman user
	(no need connect privilege, as recovery_catalog_owner has it)
	1) SQL> grant resource, recovery_catalog_owner to rman;
e) connect to RMAN and create the catalog:
$rman catalog rman/rman@torman
$rman catalog=rman/rman@torman
RMAN> create catalog;

For each Target database:
Configure tns service for recovery catalog: torman and register the database
$rman target=/ catalog=rman/pwd@torman
RMAN> register database;

Note: Connect to catalog user
SQL> select * from rc_database;
(to check the registered Database Information)
Continue the same for other target databases.

Taking backup of Target db with Catalog
From the Target host connect to rman,

$export ORACLE_SID=prod
$rman target / catalog cat/pwd@torman
RMAN> backup database;


Virtual Private Catalog
=======================
- catalog db (rman), target db -> prod, one more production db -> db1
At catalog side
- create one more catalog user (vcat) in catalog db

create user vcat identified by pwd
default tablespace rmants
quota unlimited on rmants;

grant resource, recovery_catalog_owner to vcat;

From target database (db1)
$export ORACLE_SID=db1
$rman target / catalog rman/pwd@torman
RMAN> register database;
RMAN> grant catalog for database "db1" to vcat;
RMAN> list db_unique_name all;
EXIT
Note: Connect to RMAN through VCAT user
	$rman catalog vcat/pwd@torman
	RMAN> create virtual catalog;
	RMAN> list db_unique_name all;
now for "db1" database backup information will be stored in virtual private catalog(vcat schema) as well as base catalog (rman schema).




CONFIGURE commands
==================
RMAN> configure controlfile autobackup on;
(on backup of database/datafile controlfile & spfile will be auto backed up)
RMAN> configure retention policy to redundancy 1;
	OR
RMAN> configure retention policy to recovery window of 30 days;
RMAN> configure backup optimization on;

run block
=========
To execute multiple commands at a time.
Eg:
RMAN>run{
backup current controlfile;
backup datafile 7;}

Configure FRA (flash recovery area)
===================================
configure below parameters:
db_recovery_file_dest_size
db_recovery_file_dest

SQL> alter system set db_recovery_file_dest_size=4g scope=both;
SQL> alter system set db_recovery_file_dest='/u01/fra' scope=both;

RMAN Scripts
============
1. Creating RMAN Script:
	RMAN> create script bkp{
	backup database;
	backup spfile;
	backup current controlfile;
	backup archivelog all;}
2. Executing rman script:
	RMAN> run{execute script bkp;}
3. To see the code of script:
	RMAN> print script bkp;
	RMAN> delete script bkp;
view: we can check following views to see rman scripts
	rc_stored_script		(displays scripts name)
	rc_stored_script_line		(display text of script)

set linesize 300
select db_name,script_name from rc_stored_script;

set linesize 300
col script_name for a20
col text for a100
select script_name,line,text from rc_stored_script_line order by line;

note: we can create rman script in catalog mode only.






Recovery Manager - 3
====================
Restore and Recovery Scenarios:
Loss of non system datafile: Ex: USERS01.DBF / 4 (file id)
Steps: 
	1. Offline the datafile
	     RMAN>sql 'alter database datafile 4 offline';
	2. Restore and recover the datafile
                 RMAN> restore datafile 4;
	3. RMAN> recover datafile 4;
	4. Online the datafile
	     RMAN>sql 'alter database datafile 4 online';

Loss of all datafiles:
	1. Shut down and start the database in mount state
	2. Restore and recover database
	     RMAN> restore database;
	     RMAN> recover database;
	3. Open the database
	     RMAN>sql 'alter database open';

Loss of all Controlfiles:
make sure full backup is there.  Delete all the control files manually.	
	1. Shut down (shut abort) the database and start in nomount state
	2. Restore the controlfile
	     RMAN> restore controlfile from autobackup;
	3. Change database state to mount state
	     RMAN>sql 'alter database mount';
	4. Recover the database and open database with resetlogs
	     RMAN> recover database;
	     RMAN>sql 'alter database open resetlogs';
	5. Take full database backup (recommended)

Loss of all online redologfiles:  Status = current (logseq 6)
before deleting log files, notedown the current logfile sequence.
	1. Shut down (shut immediate) the database and start in mount state
	2. Check current log sequence
		SQL> archive log list;
	3. Set the log sequence restore and recover the database and open database with resetlogs.
		RMAN>run{
                        set until logseq 6;
		        restore database;
		        recover database;
		        sql 'alter database open resetlogs';
                                        }
	4. Take full database backup;

Disaster Recovery
=================
Loss of all files (spfile, datafile and controlfiles, online redo log files)
Before deleting all these files note down current log sequence and dbid.
steps:
	1. Shut down (abort) the database (if running)
	2. Find database id (from catalog) and set that dbid from rman
		RMAN> set dbid 316146113;
	3. Start database in nomount state
		RMAN> startup nomount; --> starts with dummy parameter file
		RMAN> restore spfile from autobackup;
		RMAN> startup force nomount;
	4. Restore controlfile and bring database in mount state
		RMAN> restore controlfile from autobackup;
		RMAN>sql 'alter database mount';
	5. Recover database until last log sequence
		RMAN>run{set until logseq 7;	--(suppose the last logseq# was 7)
		restore database;
		recover database;
		sql 'alter database open resetlogs';}


INCREMENTAL and CUMULATIVE backups:
===================================
backup incremental level 0 database;
backup incremental level 1 database;
backup incremental level 2 database;
backup incremental level 1 cumulative database;
backup incremental level 1 tablespace users;
backup incremental level 1 datafile 4;

backup as compressed backupset incremental level 0 database;
backup as compressed backupset incremental level 1 database;

backup incremental level 1
tablespace users
datafile '/u01/prod/users01.dbf';
(taking 2 times)

backup incremental level=1 cumulative
tablespace users;

Incrementally updated backups:
run{
recover copy of database with tag 'incr_update';
backup incremental level 1 for recover of copy with tag 'incr_update' database;}

Incrementally updated backups: One week example:
run{
recover copy of database with tag 'incr_update'until time 'sysdate-7';
backup incremental level 1 for recover of copy with tag 'incr_update'database;}

RMAN> backup incremental level 0 database format '/u01/bkp/full_incre_%U';
RMAN> backup incremental level 1 database format '/u01/bkp/full_bkp_%U';
RMAN> backup cumulative incremental level 0 database format
		'/u01/bkp/full_cumm_bkp_%U';

We can check the backups using the below query:
select file#, incremental_level, completion_time, blocks, datafile_blocks
from v$backup_datafile;

select file#, incremental_level, completion_time, blocks, datafile_blocks
from v$backup_datafile
where incremental_level> 0
and blocks / datafile_blocks> .5
order by completion_time;


Change Tracking
===============
Checking whether change tracking is enabled or disable:
select * from v$block_change_tracking;

SQL>desc V$BLOCK_CHANGE_TRACKING

We can also create the change tracking file in a location we choose 
our self, using the following SQL statement:

$mkdir bkptrc

alter database enable block change tracking using file '/u01/bkptrc/bkptrc.trc';
alter database enable block change tracking using file '/u01/bkptrc/bkptrc.trc' reuse;

The REUSE option tells Oracle to overwrite any existing file with the specified name.

To store the change tracking file in the database area, set DB_CREATE_FILE_DEST in 
the target database, then issue the following SQL statement to enable change tracking:

alter database enable block change tracking;

Note: After enabling block change tracking CTWR process will be started and starts writing to the created file.

$ps -eaf | grep ctwr

[oracle@m1 bkptrc]$ ps -eaf|grep ctwr
oracle    7809     1  0 11:57 ?        00:00:00 ora_ctwr_prod
oracle    8396  5621  0 11:59 pts/1    00:00:00 grep ctwr

To disable change tracking:
alter database disable block change tracking;

If the change tracking file was stored in the database area, then it is deleted when you disable change tracking.

Moving or relocating the change tracking file:
Steps:
select filename from v$block_change_tracking;
shutdown immediate;
at OS level move the tracking file to new location.
startup mount;
alter database rename file '/u01/bkptrc/bkptrc.trc' to '/u01/new/bkptrc.trc';
alter database open;

Sometimes we cannot shutdown the database, then we must disable the change tracking 
and re-enable it at the new location:

alter database disable block change tracking;
alter database enable block change tracking using file 'new_location_file';

OS SCRIPTS:
At OS Prompt:
$vi hotbkp.sh
#!/bin/bash
rman target / catalog rman/rman@torman<<EOF
backup database;
backup spfile;
backup current controlfile;
backup archivelog all;
exit;
<<EOF
:wq

Once the file is created check its permissions using 'll' command.
chmod -R 777 hotbkp.sh
Run the script:
$sh hotbkp.sh


Recovery Manager - 4
====================
Tablespace Point in time recovery (TSPITR):
Push the tablespace to past time.
Steps:
1. Create a directory that will keep the auxiliary database
	$mkdir -p /u01/auxdb
2. Recover the tablespace up to a particular time by following command:
SQL> alter tablespace users offline;
RMAN> recover tablespace users until time "to_date('19:49:53 21-oct-2010',
		'hh24:mi:ss dd-mon-yyyy')" 
		auxiliary destination '/u01/auxdb';
3. Online tablespace
	SQL> alter tablespace users online;

Maintenance commands
	1. Updating the catalog
		Eg:
		RMAN> crosscheck backup;
		RMAN> crosscheck backupset;
		RMAN> crosscheck archivelog all;
	2. Re-synchronization of catalog
		RMAN>resync catalog;
	3. Taking backup of image copy of datafile
		RMAN> backup as copy database;
		RMAN> backup as copy datafile 4;
		RMAN> backup as copy tablespace users;

Block Recovery
Using rman we can recover corrupted block using following commands:
RMAN> block recover datafile 4 block 1233;
RMAN> block recover corruption list;
RMAN> backup validate database;
RMAN> validate database; //to verify corruption
				(OR)
			Block Corruption
$dd of=datafile name bs=8192 conv=notrunc seek=131 <<EOF
	#MESSAGE#
	EOF
RMAN> validate database;
RMAN> list failure; (list block corruption and data failure)
RMAN> list failure <id>
RMAN> advise failure;
RMAN> repair failure;

view
v$database_block_corruption
V$DATABASE_BLOCK_CORRUPTION displays information about database blocks that were corrupted after the last backup.
Column	Datatype	Description
FILE#	NUMBER	Absolute file number of the datafile that contains the corrupt blocks
BLOCK#	NUMBER	Block number of the first corrupt block in the range of corrupted blocks
BLOCKS	NUMBER	Number of corrupted blocks found starting with BLOCK#
CORRUPTION_CHANGE#	NUMBER	Change number at which the logical corruption was detected. Set to 0 to indicate media corruption.
CORRUPTION_TYPE	VARCHAR2(9)	Type of block corruption in the datafile:
•	ALL ZERO - Block header on disk contained only zeros. The block may be valid if it was never filled and if it is in an Oracle7 file. The buffer will be reformatted to the Oracle8 standard for an empty block.
•	FRACTURED - Block header looks reasonable, but the front and back of the block are different versions.
•	CHECKSUM - optional check value shows that the block is not self-consistent. It is impossible to determine exactly why the check value fails, but it probably fails because sectors in the middle of the block are from different versions.
•	CORRUPT - Block is wrongly identified or is not a data block (for example, the data block address is missing)
•	LOGICAL - Block is logically corrupt
•	NOLOGGING - Block does not have redo log entries (for example, NOLOGGING operations on primary database can introduce this type of corruption on a physical standby)


Parallel backup through section(chunks)
rman> run{
		allocate channel c1 device type disk;
		allocate channel c2 device type disk;
		allocate channel c3 device type disk;
		backup database section size 500m;
		}
