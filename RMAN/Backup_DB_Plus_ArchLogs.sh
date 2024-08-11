ORACLE_SID=oradb;export ORACLE_SID
rman << EOF
connect target /
spool log to Backup_DB_plus_ArchLogs.LOG
backup as compressed backupset database;
sql 'alter system switch logfile';
sql 'alter system archive log current';
backup as compressed backupset archivelog all;
backup as compressed backupset current controlfile ;
EOF
