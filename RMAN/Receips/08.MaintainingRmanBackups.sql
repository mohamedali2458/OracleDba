Maintaining RMAN Backups and the Repository
===========================================
Oracle recommends that you implement the following policies as the foundation of your RMAN backup and repository maintenance strategy:
• A fast recovery area
• An archived redo log deletion policy
• A backup retention policy

Adding User-Made Backups to the Repository
==========================================
RMAN> catalog datafilecopy '/u01/app/oracl/example1.bkp';
RMAN> catalog datafilecopy '/u01/app/oracle/example01.bkp' level 0;

To catalog a copy made by you in the RMAN repository, the copy must be available on disk, and it must be a complete
image copy of a single data file, control file, archived redo log file, or backup piece.

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
page number 236
