Configuring RMAN

$ rman target /
RMAN> backup database;

If you experience a media failure, you can restore all data files, as follows:
RMAN> shutdown immediate;
RMAN> startup mount;
RMAN> restore database;

After your database is restored, you can fully recover it:
RMAN> recover database;
RMAN> alter database open;


1. Running the RMAN Client Remotely or Locally
$ rman target sys/foo@remote_db

to run locally
$ rman target /

2. Specifying the Backup User
$ rman target BACKUPUSER/$password

$ rman target

3. Using Online or Offline Backups
Your database must be in archivelog mode for online
backups. You need to consider carefully how to place archivelogs, how to format them,
how often to back them up, and how long to retain them before deletion.

If you make offline backups, you must shut down your database with
IMMEDIATE, NORMAL, or TRANSACTIONAL and then place it in mount mode.
RMAN needs the database in mount mode so that it can read from and write to the
control file.

4. Setting the Archivelog Destination and File Format
The default file name format for archivelogs is %t_%s_%r.dbf
The %t is timestamp, %s is log sequence number and %r is reset logs ID.

FRA format 
/<fra>/<dbuname>/archivelog/<YYYY_MM_DD>/o1_mf_1_1078_68dx5dyj_.arc

To use the LOG_ARCHIVE_DEST_N
log_archive_dest_1='LOCATION=/oraarch1/CHNPRD'
log_archive_format='%t_%s_%r.arc'

better user .arc extention so that not confuse between data files.

5. Configuring the RMAN Backup Location and File Format
731
