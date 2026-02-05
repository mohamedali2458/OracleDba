Topic : Physical Backups in Oracle DBA (With Explanation & Commands)

Physical backups are exact copies of Oracle database files like datafiles, 
control files, and redo logs. They are taken using RMAN and used for 
complete recovery.

Types of Physical Backups 👇 

1) Full Database Backup
Backs up all datafiles in the database. Used as base backup.
RMAN> BACKUP DATABASE;

2)Incremental Backup
Backs up only changed data blocks, saving time and space.

a) Level 0 → Base incremental backup
RMAN> BACKUP INCREMENTAL LEVEL 0 DATABASE;

b) Level 1 Differential → Changes since last backup
Backs up only the blocks changed since the last incremental backup (Level 0 or Level 1).
Smaller & faster backups, Recovery needs more backup pieces.
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;

c) Level 1 Cumulative → Changes since last Level 0
Backs up all blocks changed since the last Level 0 backup.
Larger backup size, Faster recovery (fewer backups to apply)
RMAN> BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE;

3) Control File Backup
Backs up database structure (datafiles, redo logs info).
RMAN> BACKUP CURRENT CONTROLFILE;

4) SPFILE Backup
Backs up database initialization parameters.
RMAN> BACKUP SPFILE;

5) Archive Log Backup
Backs up archived redo logs for point-in-time recovery.
RMAN> BACKUP ARCHIVELOG ALL;