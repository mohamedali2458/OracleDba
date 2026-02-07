Maintaining RMAN Backups and the Repository
===========================================
Oracle recommends that you implement the following policies as the foundation 
of your RMAN backup and repository maintenance strategy:
• A fast recovery area
• An archived redo log deletion policy
• A backup retention policy

Adding User-Made Backups to the Repository
==========================================
RMAN> catalog datafilecopy '/u01/app/oracl/example1.bkp';
RMAN> catalog datafilecopy '/u01/app/oracle/example01.bkp' level 0;

To catalog a copy made by you in the RMAN repository, the copy 
must be available on disk, and it must be a complete image copy of 
a single data file, control file, archived redo log file, or backup piece.

If you copy or move an RMAN backup piece manually, you can use the catalog command to make that
backup piece usable by RMAN. The following is an example of cataloging an RMAN backup piece on tape.
The list command shows that a certain backup piece is uncataloged.

RMAN> list backuppiece 'ilif2lo4_1_1';

Use the catalog command to make the uncataloged backup piece available to RMAN, as shown here:
RMAN> catalog device type sbt backuppiece 'ilif2lo4_1_1';

You can check that the backup piece has been cataloged successfully by issuing the list command again,
as shown here:
RMAN> list backuppiece 'ilif2lo4_1_1';

If you have to catalog multiple files that you had backed up to a directory, use the catalog start with
command, as shown in the following example:
RMAN> catalog start with '/u01/app/oracle/backup' noprompt;

You can catalog all files in the flash recovery area by using the following command:
RMAN> catalog recovery area;


Finding Data Files and Archive Logs that Need a Backup
======================================================
RMAN> report need backup;
RMAN> show retention policy;
RMAN> configure retention policy to none;

If you now issue the report need backup command, you’ll see the following error:
RMAN> report need backup;

RMAN> report need backup redundancy n;
RMAN> report need backup recovery window of n days
This command shows data files that require more than n days’ worth of archived redo logs for a recovery:
RMAN> report need backup days=n;

This command shows only the required backups on disk:
RMAN> report need backup device type disk;

This command shows only required backups on tape:
RMAN> report need backup device type sbt;


Finding Data Files Affected by Unrecoverable Operations
=======================================================
Use the report unrecoverable command to find out which data files in the database have been marked
unrecoverable because they’re part of an unrecoverable operation. Here’s an example showing how to use the report
unrecoverable command:
RMAN> report unrecoverable;

The report unrecoverable command reveals that the example01.dbf file is currently marked unrecoverable and
that it needs a full backup to make it recoverable if necessary.


Identifying Obsolete Backups
============================
The report obsolete command reports on any obsolete backups. Always run the crosscheck command first to
update the status of the backups in the RMAN repository to that on disk and tape.

RMAN> crosscheck backup;
RMAN> report obsolete;

RMAN> report obsolete recovery window of 5 days;
RMAN> report obsolete redundancy 2;
RMAN> report obsolete recovery window of 5 days device type disk;

Note that the last command in the preceding code examples specifies that only disk backups be considered in
determining whether there are any obsolete backups. If you don’t specify the device type, RMAN takes into account
both disk and sbt backups in determining whether a backup is obsolete according to the configured policy.


Displaying Information About Database Files
===========================================
RMAN> report schema;
RMAN> report schema at time 'sysdate-1';
The previous command requires that you use a recovery catalog. You can also specify the at scn or at sequence
clause instead of the at time clause to get a report specific to a certain SCN or log sequence number.


Listing RMAN Backups
====================
RMAN> list backup;
RMAN> list backup by file;

RC_DATAFILE_COPY
RC_ARCHIVED_LOG
SELECT * FROM V$BACKUP_FILES;

SET LINESIZE 300
SET PAGESIZE 100
COL DEVICE_TYPE FOR A14
SELECT BACKUP_TYPE,FILE_TYPE,STATUS,DEVICE_TYPE,COMPRESSED,OBSOLETE,BYTES,BS_TYPE,BS_INCR_TYPE FROM V$BACKUP_FILES;

RMAN> list backup summary;
RMAN> list expired backup summary;

You can use optional clauses with the list command to narrow down your search of backup information or
to list only a specific type of backup.

RMAN> list backupset;
RMAN> list copy;
RMAN> list datafilecopy '/a01/app/oracle/users01.dbf';
RMAN> list backupset tag 'weekly_full_db_backup';
RMAN> list copy of datafile 1 completed between '01-JAN-2012' AND '15-JAN-2012';
RMAN> list archivelog all backed up 2 times to device type sbt;
RMAN> list backup of database;

list incarnation;
list restore point;
list script names;
list failure;
You can run the crosscheck and delete commands against the backups and copies displayed by the
list command.


Listing Expired Backups
=======================
You want to find out which of your backups are marked in the RMAN repository as expired, meaning they were not
found during the execution of an RMAN crosscheck command.

RMAN> list expired backup;
RMAN> list expired archivelog all;


Listing Only Recoverable Backups and Copies
===========================================
You want to review all data file backups and copies that you can actually use for a restore and recovery.

RMAN> list recoverable backup;

The list backup command shows all backups and copies from the repository, irrespective of their status. Since you
can use the backups and copies only with the available status, it’s a good idea to run the list recoverable backup
command instead when you want to know what usable backups you really do have.


Listing Restore Points
======================
RMAN> list restore point all;

You can use the list restore point command to effectively manage any restore points you created in a database.
Any guaranteed restore points will never age out of the control file. You must manually delete a guaranteed
restore point by using the drop restore point command. Oracle retains the 2,048 most recent restore points,
no matter how old they are. In addition, Oracle saves all restore points more recent than the value of the
control_file_record_keep_time initialization parameter. All other normal restore points automatically age out of
the control file eventually.


Listing Database Incarnations
=============================
You want to find out what incarnations of a database are currently recorded in the RMAN repository so you can use
this information during potential restore and recovery operations.

When you perform an open resetlogs operation, it results in the creation of a new incarnation of the database.

RMAN> list incarnation;

If the list incarnation command shows three incarnations of a database, for example, it means you’ve reset the
online redo logs of this database twice. Each time you reset the online redo logs, you create a new incarnation of
that database.

RMAN can use backups both from the current incarnation of a database and from a previous incarnation as the
basis for subsequent incremental backups if incremental backups are part of your backup strategy. As long as all the
necessary archived redo logs are available, RMAN can also use backups from a previous incarnation for performing
restore and recovery operations.


Updating the RMAN Repository After Manually Deleting Backups
============================================================
You have deleted some unneeded archived redo logs from disk using an operating system command instead of using
the RMAN delete command. The RMAN repository, however, continues to indicate that the deleted archived redo
logs are available on disk. You want to update this outdated RMAN repository information about the deleted backups.

RMAN> change datafilecopy '/u01/app/oracle/users01.dbf' uncatalog;

RMAN> change backuppiece 'ilif2lo4_1_1' uncatalog;

If you’re using a recovery catalog, the change ... uncatalog command will also delete the backup record you
are specifying in the change ... uncatalog command from the recovery catalog.

The command removes all RMAN repository references for the file you manually
deleted. Otherwise, RMAN won’t know about the files you deleted unless you run the crosscheck command.


Synchronizing the Repository with the Actual Backups
====================================================
You’ve manually removed some old archived redo logs from disk and want to make sure you update the RMAN
repository (in the control file and in the recovery catalog) to match the actual backup situation both on disk and in the
media management catalog.

RMAN> delete backup;
RMAN> crosscheck backup;

The crosscheck command helps you update backup information about corrupted backups on disk and tape,
as well as any manually deleted archived redo logs or other backup files. For disk backups, the crosscheck command
validates the file headers, and for tape backups, it checks whether the backups are in the media management layer
(MML) catalog.

It’s a good strategy to always first use the list command to see what backups you have and follow it up with the
crosscheck command to make sure you really do have those backups. You can use the delete expired command to
remove RMAN repository data for all those backups that fail the checking performed by the crosscheck command.

The crosscheck backup command checks all backups on both disk and tape, provided you’ve already configured
an automatic channel for your tape backups. As you know, RMAN already comes with a single preconfigured disk
channel.

If you haven’t configured an automatic sbt channel, you must allocate a maintenance channel within a run block
before you execute the crosscheck command, as shown here:

RMAN> allocate channel for maintenance device type sbt;
crosscheck backup;
  
Once you’ve configured an sbt channel through the configure command or manually allocated it through the
allocate channel command shown previously, you can then check backups on both disk and tape with a single
crosscheck command, as shown here:

RMAN> crosscheck backup;  
  
There are three possible values for the status of a file following the execution of the crosscheck command—
available, unavailable, and expired.

RMAN> crosscheck backup;
RMAN> delete expired backup;

RMAN> crosscheck backupset of tablespace users device type sbt completed before 'sysdate-14';
RMAN> delete expired backupset of tablespace users device type sbt completed before 'sysdate-14';  

RMAN> crosscheck copy;

You can use various options of the crosscheck command to perform the cross-checking of a specific tablespace,
data file, archived redo log, control file, and so on. Here are some examples that show how to restrict the crosschecking
to specify types of backups:

# cross-checking just backup sets.
RMAN> crosscheck backupset;

# cross-checking a copy of a database
RMAN> crosscheck copy of database;

# cross-checking specific backupsets;
RMAN> crosscheck backupset 1001, 1002;

# cross-checking using a backup tag
RMAN> crosscheck backuppiece tag = 'weekly_backup';

# cross-checking a control file copy;
RMAN> crosscheck controlfilecopy '/tmp/control01.ctl';

# cross-checking backups completed after a specific time
RMAN> crosscheck backup of datafile "/u01/app/oracle/prod1/system01.dbf" completed after 'sysdate-14';

# cross-checking of all archivelogs and the spfile;
RMAN> crosscheck backup of archivelog all spfile;

# cross-checking a proxy copy
RMAN> crosscheck proxy 999;

Use the completed after clause to restrict the crosscheck command to check only those backups that were
created after a specific point in time. The following command will check only for backups of a data file made in the
last week:

RMAN> crosscheck backup of datafile 2 completed after 'sysdate -7';

It’s important to understand that the crosscheck command doesn’t delete the RMAN repository records
of backup files that were manually removed. It simply updates those records in the repository to reflect that the
backup isn’t available any longer by marking the file status as expired. You must use the delete command to
actually remove the records of these expired backups from the RMAN repository. On the other hand, if a file was
expired at one time and is now made available again on disk or on media management layer, RMAN will mark the
file’s status as available.


Deleting Backups
================
RMAN> delete backup;

RMAN> delete backuppiece 999;
RMAN> delete copy of controlfile like '/u01/%';
RMAN> delete backup tag='old_production';
RMAN> delete backup of tablespace sysaux device type sbt;

In some special situations, you may want to delete all backups—including backup sets, proxy copies, and image
copies—belonging to a database. This can happen when you decide to drop a database and get rid of all of its backups
as well. Use a pair of crosscheck commands first, one for backups and the other for the image copies, to make sure
the repository and the physical media are synchronized. Then issue two delete commands, one for the backups and
the other for the copies. Here are the commands:

RMAN> crosscheck backup;
RMAN> crosscheck copy;
RMAN> delete backup;
RMAN> delete copy;

When you issue the delete backup command, RMAN does the following:
1. Removes the physical file from the backup media
2. Marks the status of the deleted backup in the control file as deleted
3. Deletes the rows pertaining to the deleted backup from the recovery catalog repository,
   which is actually stored in database tables, if you are using a recovery catalog and are
   actually connected to it while deleting the backup.

If you issue the delete backup command, you may sometimes get the RMAN prompt back right away without
any messages about deleted backups. However, that doesn’t mean RMAN has deleted all backups. This actually
means RMAN didn’t find any backups to delete. Here’s an example:

RMAN> delete backup;
using channel ORA_DISK_1

If you issue the simple delete command, without specifying the force option, the deletion mechanism works in
the following manner under different circumstances:
1.
If the status of the object is listed as available in the repository but the physical copy isn’t
found on the media, RMAN doesn’t delete the object or alter the repository status.

2.
If the status is listed as unavailable in the repository, RMAN deletes the object if it exists and
removes the repository record for the object.

3.
If the object has the expired status and RMAN can’t find the object on the media, RMAN
doesn’t delete the object or update its repository status.


Here are some options you can use with the delete command when deleting backups:

delete force: Deletes the specified files whether they actually exist on media or not and
removes their records from the RMAN repository as well

delete expired: Deletes only those files marked expired pursuant to the issuance of the
crosscheck command.

delete obsolete: Deletes data file backups and copies and the archived redo logs and log
backups that are recorded as obsolete in the RMAN repository


Deleting Archived Redo Logs
===========================
You want to manually delete some unneeded archived redo logs.

RMAN> delete archivelog all;
RMAN> delete archivelog all backed up 3 times to sbt;
RMAN> delete archivelog until sequence = 999;
RMAN> backup device type sbt archivelog all delete all input;
RMAN> backup archivelog like '/arch%' delete input;

RMAN uses the configured archived redo log deletion policy to determine which of the archived redo logs are eligible
for deletion, including those archived redo logs that are stored in the flash recovery area. RMAN automatically deletes
the eligible archived redo logs from the flash recovery area. An archived redo log is considered eligible for deletion
when the flash recovery area becomes full.

Suppose you have configured the following archived redo log deletion policy:

RMAN> configure archivelog deletion policy to backed up 2 times to device type sbt;

The previous command specifies that all archived redo log files will be eligible for deletion from all locations
when those files have been backed up twice or more to tape. Once you set the archived redo log deletion policy shown
here, a delete archivelog all or backup ... delete input command will delete all archived redo logs that satisfy
the requirements of your configured deletion policy, which requires that RMAN back up all archived redo logs to
tape twice.

If you haven’t configured an archived redo log deletion policy (by default there is no policy set), RMAN will deem
any archived redo log file in the flash recovery area eligible for deletion, if both of the following are true:

1.
The archived redo logs have been successfully sent to all the destinations specified by the
log_archive_dest_n parameter.

2.
You have copied the archived redo logs to disk or to tape at least once, or the archived redo
logs are obsolete per your configured backup retention policy.

If you execute the delete command with the force option, RMAN will ignore any configured archived redo log
retention polices and delete all the specified archived redo logs.


Deleting Obsolete RMAN Backups
==============================
You want to delete just those RMAN backups that are obsolete according to the defined retention policy.

RMAN> delete obsolete;

The delete obsolete command relies only on the backup retention policy in force. It doesn’t consider the
configured archived redo log deletion policy in effect to determine which archived redo logs are obsolete. The delete
archivelog all command, on the other hand, relies entirely on the configured archived redo log deletion policy.

RMAN> delete obsolete redundancy = 2;

RMAN> delete obsolete recovery window of 14 days;


Changing the Status of an RMAN Backup Record
============================================
You have migrated some backups off-site and want to let RMAN know that those files aren’t available to it.

RMAN> change backupset 10 unavailable;

Use the change ... unavailable option when you know you don’t want a particular backup or copy to be
restored yet but don’t want to delete that backup or copy either. If you uncatalog the backup set, it’ll have a status of
deleted in the repository. However, if you just use the change command to make the backup set unavailable, you can
always make that available again when you have more space on this disk and are able to move the backup set to its
original location.

Once you mark a backup file unavailable, RMAN won’t use that file in a restore or recover operation. Note that you
can’t mark files in the flash recovery area as unavailable. Once you find copies of the unavailable, misplaced, or lost
backups and restore them, you can mark all the backups you had marked unavailable previously as available again by
using the keyword available as part of the change command, as shown here:

RMAN> change backupset 10 available;

For example, if you performed a backup using an NFS-mounted disk and that
disk subsequently becomes inaccessible, you can connect to either the primary database or the standby database
and issue the change command to set the status of the backup as unavailable. Later, once the disk becomes accessible
again, you can change its status back to available.


Changing the Status of Archival Backups
=======================================
You have made an archival backup for long-term storage to comply with some business requirements. These
requirements have changed over time, and you now want to change the status of the archival backup.

If you have previously specified the keep forever option to create an archival backup and have now decided to
alter the status of this backup to that of a regular backup, use the change ... nokeep command to alter the status of
the archival backup. Here’s an example:

1. Use the change command to modify a regular consistent database backup into an archival backup:
RMAN> change backup tag 'consistent_db_bkup' keep forever;

Since this is a consistent backup, it won’t need any recovery, and as such, you won’t need any archived redo
log backups.

2. Use the CHANGE command to change the archival backup to a normal database backup
subject to the backup obsoletion policies you have in place:
RMAN> change backup tag 'consistent_db_backup' nokeep;

RMAN> change backupset 111 keep until time 'sysdate+180';


Testing the Integrity of an RMAN Backup
=======================================
You want to test your backup operation without actually performing a backup to a disk or tape device to make sure
that RMAN can indeed make good backups of your data files. Your goal is to ensure that all the data files exist in the
correct locations and that they aren’t physically or logically corrupt.

RMAN> backup validate database archivelog all;

The backup validate command shows that all the necessary data files and archived redo logs can be backed up
successfully by RMAN. The output of this command is identical to that of an actual RMAN backup command, but as
with the other validation command shown in this recipe, no actual backup takes place.

To check for logical corruption, use the following variation of the backup validate command:

RMAN> backup validate check logical database archivelog all;

The check logical clause means that RMAN will check for logical corruption only.

The backup ... validate command confirms that all the data files are indeed where they are supposed to be. The
command also checks for both physical and logical corruption. Look up the V$DATABASE_BLOCK_CORRUPTION
view for any corruption identified by RMAN after the backup ... validate command finishes executing.


Validating Data Files, Backup Sets, and Data Blocks
===================================================
You aren’t sure whether a particular data file is missing and you want to run a check to validate the file(s). In addition,
you may also want to check whether a particular backup set or a data block is corrupt.

RMAN> validate backupset 3;

You can also use the validate command to check all data files at once, as shown here:
RMAN> validate database;

Note that when you issue the backup ... validate command, the command begins with the message “Starting
validate” and not “Starting backup,” as is the case with the backup ... validate command.

The semantics of the validate command are similar to those of the backup ... validate command, with the big
advantage that the validate command can check at a much more granular level than the backup ... validate
command. You can use the validate command with individual data files, backup sets, and even data blocks.

You can speed up the validation of a large data file by using the section size clause with the validate
command after first configuring multiple channels. The allocation of multiple channels with the section size clause
parallelizes the data file validation, making it considerably faster. Here’s an example using two disk channels, with the
section size clause dividing up the validation work between the two channels:

RMAN> run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
validate datafile 1 section size = 250m;
}


The validate command always skips all the data blocks that were never used, in each of the data files it validates.
The larger the value of the section size clause you set, the faster the validation process completes. You can use the
validate command with the following options, among others:
  • validate recovery area
  • validate recovery files
  • validate spfile
  • validate tablespace <tablespace_name>
  • validate controlfilecopy <filename>
  • validate backupset <primary_key>



page number 236
