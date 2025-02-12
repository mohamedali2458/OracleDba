log archive destination full - What to do?

1. log archive destination full, what to do?
2. Unable to switch / generate the archive log due to log archive destination full
3. Database is hung due to log archive destination full

Solution1: Delete the archive logs
Solution2: Increase the archive log destination 
Solution3: Change the archive log destination 
Solution4: Move archive logs from FRA to temporary location


Solution1: Delete the archive logs:
===================================
SQL> archive log list
SQL> show parameter db_recovery_file_dest

SQL> 
set lines 1000 pages 1000
col DEST_NAME for a20
col STATUS for a15
col DESTINATION for a30 
select dest_name, status, destination from v$archive_dest;  

run {
crosscheck archivelog all;
crosscheck backup;
delete noprompt obsolete;
delete noprompt expired archivelog all;
delete noprompt expired backup;
}


Solution2: Increase the archive log destination 
===============================================
select * from v$recovery_area_usage;
 
set lines 1000 pages 1000
col NAME for a50
select * from v$recovery_file_dest;

select SPACE_USED/1024/1204/1024 "GB" from v$recovery_file_dest;

select SPACE_USED/1024/1204/1024 from dual;

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 1G SCOPE=BOTH SID='*';


Solution3: Change the archive log destination 
=============================================
SQL> archive log list
SQL> show parameter db_recovery_file_dest

set lines 1000 pages 1000
col DEST_NAME for a20
col STATUS for a15
col DESTINATION for a30 
select dest_name, status, destination from v$archive_dest;  

show parameter log_archive_format
ALTER SYSTEM SET log_archive_dest_1='location=/u01/backup' scope=both;


Solution4: Move archive logs from FRA to temporary location
===========================================================
cd $FRA 
mv * /u01/backup/. 

Note:
alter system set db_recovery_file_dest_size=100M scope=both;
ALTER SYSTEM SET log_archive_dest='location=USE_DB_RECOVERY_FILE_DEST' scope=both;



Logs:
=====
env | grep ORA
sqlplus / as sysdba
SQL> archive log list
SQL> show parameter recovery

SQL> alter system switch logfile;
^C alter system switch logfile
*
ERROR at line 1:
ORA-01013: user requested cancel of current operation


set lines 1000 pages 1000
col DEST_NAME for a20
col STATUS for a15
col DESTINATION for a30
select dest_name, status, destination from v$archive_dest;


rman target /

RMAN> run {
crosscheck archivelog all;
crosscheck backup;
delete noprompt obsolete;
delete noprompt expired archivelog all;
delete noprompt expired backup;
}



sqlplus / as sysdba
SQL> set lines 1000 pages 1000
SQL> select * from v$recovery_area_usage;

SQL> set lines 1000 pages 1000
col NAME for a50
select * from v$recovery_file_dest;
select SPACE_USED/1024/1204/1024 from v$recovery_file_dest;


SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 650M SCOPE=BOTH SID='*';

SQL> show parameter recovery


SQL> alter system switch logfile;
^C alter system switch logfile
*
ERROR at line 1:
ORA-01013: user requested cancel of current operation


SQL> archive log list;

SQL> show parameter recovery

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 1G SCOPE=BOTH SID='*';

SQL> show parameter recovery

SQL> alter system switch logfile;
System altered.

set lines 1000 pages 1000
col DEST_NAME for a20
col STATUS for a15
col DESTINATION for a30
select dest_name, status, destination from v$archive_dest;

SQL> show parameter log_archive_format

SQL> ALTER SYSTEM SET log_archive_dest_1='location=/u01/backup' scope=both;

SQL> select dest_name, status, destination from v$archive_dest;

SQL> alter system reset LOG_ARCHIVE_DEST_1 scope=spfile;

SQL> startup force;

SQL> select dest_name, status, destination from v$archive_dest;

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 700M scope=both sid='*';

SQL> show parameter recovery

SQL> ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 650M scope=both sid='*';

SQL> show parameter recovery

