Rman Backup & Recovery Questions & Answers
******************************************
1) What is RMAN?
   Recovery Manager (RMAN) is a utility that can manage your entire Oracle backup and recovery activities.

2) What is the difference between using recovery catalog and control file?
    When new incarnation happens, the old backup information in control file will be lost. It will be preserved in recovery catalog.
    In recovery catalog we can store scripts.
    Recovery catalog is central and can have information of many databases.

3) How do you know that how much RMAN task has been completed?
    By querying v$rman_status or v$session_longops

4) Command to delete archive logs older than 7days?
    RMAN> delete archivelog all completed before sysdate-7;

5) How many times does oracle ask before dropping a catalog?
    The default is two times one for the actual command, the other for confirmation.

6) How to view the current defaults for the database.
    RMAN> show all;

7) What is the use of crosscheck command in RMAN?
     Crosscheck will be useful to check whether the catalog information is intact with OS level information. This command only updates repository records with the status of the backups.

8) Which one is good, differential (incremental) backup or cumulative (incremental) backup?
     A differential backup, which backs up all blocks changed after the most recent incremental backup at level 1 or 0.
     A cumulative backup, which backs up all blocks changed after the most recent incremental backup at level 0.
     Cumulative backups are preferable to differential backups when recovery time is more important than disk space, because during recovery each differential backup must be applied in succession. 
     Use cumulative incremental backups instead of differential, if enough disk space is available to store cumulative incremental backups.

9) What is the difference between backup set and backup piece?
     Backup set is logical and backup piece is physical.

10) What is obsolete backup & expired backup?
       A status of  expired  means that the backup piece or backup set is not found in the backup destination.
       A status of  obsolete  means the backup piece is still available, but it is no longer needed. The backup piece is no longer needed since RMAN has been configured to no longer need this piece after so many days have elapsed, or so many backups have been performed.

11) What is the difference between hot backup & RMAN backup?
       For hot backup, we have to put database in begin backup mode, then take backup.
       RMAN won t put database in backup mode.

12) What are the Architectural components of RMAN?
       RMAN Executables
       Server process
       Channels
       Target database
       Recovery catalog database (optional)
      Media management Layer (optional)
      Backups, backup sets and backup pieces

13) Why is the catalog optional?
       Because RMAN manages backup and recovery operations, it requires a place to store necessary information about the database. RMAN always stores this information in the target database control file. You can also store RMAN metadata in a recovery catalog schema contained in a separate database. The recovery catalog schema must be stored in a database other than the target database.

14) What is a Backup set?
       A logical grouping of backup files   the backup pieces   that are created when you issue an RMAN backup command. A backup set is RMAN s name for a collection of files associated with a backup. A backup set is composed of one or more backup pieces.

15) What are the benefits of using RMAN?
      Incremental backups that only copy data blocks that have changed since the last backup.
      Tablespaces are not put in backup mode, thus there is noextra redo log generation during online backups.
      Detection of corrupt blocks during backups.
      Parallelization of I/O operations.
      Automatic logging of all backup and recovery operations.
      Built-in reporting and listing commands.

16) How do you identify what are the all the target databases that are being backed-up with RMAN database?
      You don t have any view to identify whether it is backed up or not. The only option is connect to the target database and give list backup this will give you the backup information with date and timing

17) How do you clone the database using RMAN software? Give brief steps? When do you use crosscheck command?
      Check whether backup pieces proxy copies or disk copies still exist.
      Two commands available in RMAN to clone database:
      1) Duplicate
      2) Restore.

18) List some of the RMAN catalog view names which contain the catalog information?
      RC_DATABASE_INCARNATION RC_BACKUP_COPY_DETAILS
      RC_BACKUP_CORRUPTION
      RC_BACKUP-DATAFILE_SUMMARY

19) How do you install the RMAN recovery catalog?
      1) Create connection string at catalog database.
      2) At catalog database create one new user or use existing user and give that user a recovery_catalog_owner privilege.
      3) Login into RMAN with connection string
      a) export ORACLE_SID
      b) rman target catalog @connection string
      4) rman> create catalog;
      5) register database;

20) What is the difference between physical and logical backups?
       In Oracle Logical Backup is which is taken using either Traditional Export/Import or Latest Data Pump. Where as Physical backup is known  when you take Physical O/s Database related Files as Backup.

21) What is RAID? What is RAID0? What is RAID1?
       RAID: It is a redundant array of independent disk
       RAID0: Concatenation and stripping
       RAID1: Mirroring

22) What is auxiliary channel in RMAN? When do you need this?
       An auxiliary channel is a link to auxiliary instance. If you do not have automatic channels configured, then before issuing the DUPLICATE command, manually allocate at least one auxiliary channel within the same RUN command.

23) How do you use the V$RECOVERY_FILE_DEST view to display information regarding the flashrecovery area?
       SQL> SELECT name, space_limit, space_used,space_reclaimable, number_of_filesFROM v$recovery_file_dest;

24) How can you display warning messages?
      SQL> SELECT object_type, message_type,message_level, reason, suggested_actionFROM dba_outstanding_alerts;

25) How do you backup the entire database?
      RMAN> BACKUP DATABASE;

26) How do you backup an individual tablespaces?
      RMAN> CONFIGURE DEFAULT DEVICE TYPE TO DISK;
      RMAN> BACKUP TABLESPACE system;

27) How do you backup datafiles and control files?
      RMAN> BACKUP DATAFILE 3;
      RMAN> BACKUP CURRENT CONTROLFILE;

28) What are the benefits of RMAN over user-managed backup-recovery process?
 powerful Data Recovery Advisor feature
 simpler backup and recovery commands
 automatically manages the backup files without DBA intervention.
 automatically deletes unnecessary backup datafiles and archived redo log files both from disk and tape.
 provides you with detailed reporting of backup actions
 Easy to duplicate a database or create standby database.
 Without actually restoring data, you can test whether you will be able to do it or not
 Incremental backup! only RMAN can do that.

29) How important is Database Redundancy Set and where you should plan to keep it?
      Database Redundancy Set is essential set of recovery-related files. 
 Recent backups of all datafiles & control file 
 All archived redo logs made after the last backup
 Current control files and online redo file copies 
 Oracle database-related configuration file copies 

30) What is the benefit of making automatic control file backup to ON?
       Remember that control file is absolutely necessary during a recovery.
       RMAN> configure controlfile autobackup on
       Now at the end of every RMAN backup command, RMAN automatically backs up the control file

31) What all you can store in Flash Recovery Area(FRA)?
 backupset: for RMAN regular backups.
 datafile: for RMAN image copies.
 autobackup: for control file autobackups.
 flashback: If your database runs in flashback mode, you will see flashback logs in this subdirectory.
 archivelog: for Archived redo logs
 controlfile: The control file, if configured to go to the flash recovery area.
 onlinelog: Online redo logs can also be made to go to the flash recovery area

32) Is putting control file and online redo logs in Flash Recovery Area (FRA) advisable?
      Control file is very important file for the database operation. Loosing a single control file will make the database unstable and will lead to interruption in service.
      So we will always try to put control file in a safe and stable place.
      Similarly online logs are equally important and loosing them can also cause database to crash, incomplete recovery and possible data loss.

33) How to check the syntax of RMAN commands?
      Start the RMAN client with the operating system command-line argument checksyntax.
      $ rman checksyntax

34) What is the benefit of using Recovery Catalog?
 provides larger storage capacity, thus enabling access to a longer history of backups
 you can create and store RMAN scripts in the recovery catalog and Any client that can connect to the recovery catalog and a target database can use these stored scripts
 Can service many target databases
 you can use  KEEP FOREVER  clause of RMAN backup command.
 Allows you to list the data files and tablespaces that are or  were in the target database at a given time

35) How to check the version of your recovery catalog?
      RMAN@rmandb > select * from rcver;

36) What all files can NOT be backed up by RMAN?
       1) Oracle home-related files
       2) External files
       3) Network configuration files
       4) Password files

37) What is the difference between to back up the current control file and to backup up control file copy?
       If you backup  current control file  you backup control file which is currently open by an instance where as If you backup  controlfile file copy" you backup the copy of control file which is created either with SVRMGRL command "alter system backup controlfile to .." or with RMAN command "copy current controlfile to ...". 
       In the other words, the control file copy is not current controlfile backup current controlfile creates a BACKUPSET containing controlfile. 
       You don't have to give the FILENAME where as backup controlfile copy creates a BACKUPSET from a copy of controlfile. 
       You have to give the FILENAME.

38) How much of overhead in running BACKUP VALIDATE DATABASE and RESTORE VALIDATE DATABASE commands to check for block corruptions using RMAN? 
      Backup validate works against the backups not against the live database so no impact on the live database, same for restore validate they do not impact the real thing (it is reading the files there only). 

39) What is the advantage of using PIPE in rman backups? In what circumstances one would use PIPE to backup and restore?                                                                                                                                                                 
       It lets 3rd parties (anyone really) build an alternative interface to RMAN as it permits anyone                                                                   
       that can connect to an Oracle instance to control RMAN programmatically

40) Where should the catalog be created?                                                                                                                                  
        The recovery catalog to be used by Rman should be created in a separate database other than the target database. 
        The reason is that the target database will be shutdown while datafiles are restored.                 

41) How many times does oracle ask before dropping a catalog?
      The default is two times one for the actual command, the other for confirmation. 

42) What are the various reports available with RMAN?  
       rman>list backup; 
       rman> list archive;     

43) What is the use of snapshot controlfile in terms of RMAN backup?  
      Rman uses the snapshot controlfile as a way to get a read consistent copy of the controlfile,
      it uses this to do things like RESYNC the catalog (else the controlfile is a  moving target , constantly changing and Rman would get blocked and block the database)                                       

44) How to Increase Size of Redo Log   
      1. Add new log files (groups) with new size                                                                                                              
          ALTER DATABASE ADD LOGFILE GROUP                                                                                                                                                                                                                                                  
      2. Switch with  alter system switch log file  until a new log file group is in state current                                                         
      3. Now you can delete the old log file                                                                                                      
          ALTER DATABASE DROP LOGFILE MEMBER  

45) How you will check flashback is enabled or not?   
      Select flashback_on from v$database;  

46) RMAN command to backup for creating standby database?
      RMAN> duplicate target database to standby database ....

47) How to do cloning by using RMAN?
      RMAN> duplicate target database  

48) How to check RMAN configuration?
      RMAN>Show all;

49) How to reset to default configuration?
      To reset the default configuration setting use Connect to the target database from sqlplus and run
      SQL> connect @target_database;  
      SQL> execute dbms_backup_restore.resetConfig; 
      RMAN Catalog Database

50) What is Catalog database and How to configure it?
      This is a separate database which contains catalog schema
      You can use the same target database as the catalog database but it s not at all recommended

51) How Many catalog database I can have?
      You can have multiple catalog databases for the same target database 
      But at a time you can connect to only 1 catalog database via RMAN. Its not recommended to have multiple catalog database

52) What are the database file's that RMAN can backup?
       RMAN can backup Controlfile, Datafiles, Archive logs, standby database controfile, Spfile

53) What are the database file's that RMAN cannot backup?
       RMAN can not take backup of the pfile, Redo logs, network configuration files, password files, external tables and the contents of the Oracle home files 

54) What is the difference between backup set backup and Image copy backup?
        A backup set is an RMAN-specific proprietary format, whereas an image copy is a bit-for-bit copy of a file 
        By default, RMAN creates backup sets

55) What is RMAN consistent backup and inconsistent backup?
      A consistent backup occurs when the database is in a consistent state 
      That means backup of the database taken after a shutdown immediate, shutdown normal or shutdown transactional 
      If the database is shutdown with abort option then its not a consistent backup 
      A backup when the database is up and running is called an inconsistent backup 
     When a database is restored from an inconsistent backup, Oracle must perform media recovery before the database can be opened, applying any pending changes from the redo logs 
     You can not take inconsistent backup when the database is in Noarchivelog mode

56) What is Oracle Secure backup?
      Oracle Secure Backup is a media manager provided by oracle that provides reliable and secure data protection through file system backup to tape
      All major tape drives and tape libraries in SAN, Gigabit Ethernet, and SCSI environments are supported

57) Difference between catalog and nocatalog?
      Recovery catalog is central and can have information of many databases.

58) What is difference between Restoring and Recovery of database?
       Restoring means copying the database object from the backup media to the destination where actually it is required where as recovery means to apply the database object copied earlier (roll forward) in order to bring the database into consistent state.

59) What is the difference between complete and incomplete recovery?
       An incomplete database recovery is a recovery that it does not reach to the point of failure. The recovery can be either point of time or particular SCN or Particular archive log specially incase of missing archive log or redolog failure where as a complete recovery recovers to the point of failure possibly when having all archive log backup.

60) What is the benefit of running the DB in archivelog mode over no archivelog mode?
      When a database is in no archivelog mode whenever log switch happens there will be a loss of some redoes log information in order to avoid this, redo logs must be archived. This can be achieved by configuring the database in archivelog mode.

61) Which tools can you use for full backup?
      Oracle recommended the use of RMAN.

62) what is catalog command and how is it used?
      Add information of backup pieces and images copies in the repository that are on disk.
      Record information about the level 0 backup in the RMAN repository.
      Record information about the copy taken by the operating system.

62) How do you mark the beginning of backup and what happens after that/
      sql> alter database begin backup;
      freezing the header of datafiles.
     After that, the files cannot be changed. the changes in the data will be recorded in the files after the backup is complete.

63) How do you find the total database size in the database/
     dba_segments
     dba_data_files
     v$log

64) How does RMAN improve performance of backup?
      RMAN uses multiple channels and does not take backup of free blocks. this is the reason why performance of RMAN backup is better.

64) what is a recovery catalog/
      It is an inventory of the backup taken by RMAN.

65) what does RMAN backup consist of/
      It is a backup of all or part of database. the results from issuing an RMAN backup command. A backup consists of one or more backup sets.

66) What is instance recovery?
       Instance recovery is used in Real Application cluster (RAC) environment only.
       It occurs in an open database when one instance detects that another instance has crashed.

67) What is complete recovery?
      Complete recovery uses redo data or incremental backups combined with a backup of a database, datafile or tablespace to update it to the most current point in time.
      Oracle applies all the redo changes contained in the archived and online logs to the backup.
      During a complete recovery, all the changes made to the restored file since the time of the backup are redone.
 	

68) What is full backup?
       A full backup is a backup of all the datafiles, control files and SPFILE.
       A full backup can be made with RMAN or the operating system commands while the database is open or closed.
       As a rule, you must perform full backup, if your database is not running in the archiving log mode.
 
69) What is a recovery catalog?
       Recovery catalog is an inventory of the backup taken by RMAN for the database.
       It is used to restore a physical backup, reconstruct it, and make it available to the Oracle server.

70) What are channels?
      RMAN process uses channel to communicate with I/O devices.
      You can control the type of I/O device, parallelism, number of files and size of files by allocating channels.

71) What is the difference between incremental backup and differential backup?
       Both, incremental and differential backup files that have been modified or created after the previous backup.
       However, attributes are reset after the incremental backup but not after the differential backup.
 	

72) What is logical backup?
       Logical backup is a process of extracting data in the form of SQL statements, where it is useful to recover in case the objects are lost.
       The main drawback of using this backup is that MEAN TIME TO RECOVER is high.

73) Which tools can you use for full backup?
       You can use either the operating system utilities or the RMAN utility for full backup.
       However, Oracle recommends the use of RMAN utility.
 	

74) What is catalog command?
      Catalog command is used to register different types of information with RMAN s repository.
 	

75) What are time based and change based recoveries?
       Time based and change based recoveries are forms of incomplete recovery.
       These are used when one knows the time or system change number up to which one wants to recover the database.

76) What is a backup set?
       Backup set is a logical grouping of backup files that are created when you issue an RMAN backup command.
       It is RMAN's name for a collection of files associated with a backup. A backup set is composed of one or more backup pieces.
 	

77) Which is more efficient   incremental backups using RMAN or incremental export?
       RMAN incremental backup is more efficient than the incremental export.

78) What is the difference between hot backup and cold backup?
       Hot backup is taken when database is still online while cold backup is taken when database is offline.
       Database needs to be in the archive log mode for the hot backup but there is no such requirement for the cold backup.

79) Which files must be backed up?
       Database files
       Control files
       Archived log files
       Password files
       INIT.ORA

80) What does RMAN backup consist of?
       RMAN backup consists of a backup of all or part of a database.
       This result from issuing an RMAN backup command.
       A backup consists of one or more backup sets.
    

81) What is catalog command and how it is used?
      Catalog command is used to register different types of information with RMAN's repository.

82) What are the benefits of using RMAN?
       Incremental backups that only copy data blocks, which have changed since the last backup
       Tablespaces are not put in the backup mode; therefore, there is no extra redo log generation during online backups.
       Detection of corrupt blocks during backups
       Parallelization of I/O operations
       Automatic logging of all the backup and recovery operations
       Built in reporting and listing commands.

83) What is factured block or corrupted block.?
       A block in which the header and footer are not consistent at a given SCN. In a user-managed backup, an operating system utility can back up a datafile at the same time that DBWR is updating the file.
       It is possible for the operating system utility to read a block in a half-updated state, so that the block that is copied to the backup media is updated in its first half, while the second half contains older data. 
       In this case, the block is fractured.

84) How do u came to know tht which table is dropped.?
      Data pump exports - If you care about the data in this table, you would have exported it nightly.
      RMAN - You can recover a single dropped table by restoring the entire database into your test environment using RMAN, and then roll forward. You can then extract the table and copy it from test to production using CTAS over a database link and then re-add the indexes and constraints.
      LogMiner - Oracle LogMiner can used to recover a dropped table.  See here, the steps to recover a dropped table using LogMiner. 
      Flashback - It's easy to recover a dropped table with these steps in flashback.

85) Which type of backup u can take in oracle.
       1.RMAN 2.User Managed  3.IMP/EXP

86) How will u take backup of controlfile.
      1.alter database backup conrtrol file to trace;
      2.alter database backup controlfile to '/u01/opt/control02.ctl';

========================================================================THE END===============================================================================	



















