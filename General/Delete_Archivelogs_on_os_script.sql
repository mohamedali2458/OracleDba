Delete Archivelogs from Primary Server
======================================
To delete safely archive logs from primary oracle database server, I have created 
a SQL script on the primary database to generate a OS batch file to delete archive 
logs those are applied on the Standby server.

We can delete archive logs status=applied from the primary server.

steps are below

1.cmd     connect to standby server and run the sql script to find the archive logs=applied

set ORACLE_SID=oradb
sqlplus -silent sys/pass@oradb_STBY as sysdba @E:\Dailybackups\delete-archive-logs\2delete-archivelogs.sql


2. delete-archivelogs.sql

spool E:\Dailybackups\delete-archive-logs\os-script-to-delete-archivelogs.cmd
set pagesize 9999
set linesize 1000
select 'del E:\ORACLE\Arch\oradb\' ||
SUBSTR(NAME,INSTR(NAME,'\',-1) +1)||''
FROM V$ARCHIVED_LOG where name is not null and applied='YES';
spool off;


3. script-to-delete-archivelogs.cmd (output) this script will be creating through the above sql automatically.

del E:\ORACLE\Arch\oradb\ARC0000176181_0846842746.0001 
del E:\ORACLE\Arch\oradb\ARC0000176182_0846842746.0001 
del E:\ORACLE\Arch\oradb\ARC0000176183_0846842746.0001 
del E:\ORACLE\Arch\oradb\ARC0000176184_0846842746.0001 
del E:\ORACLE\Arch\oradb\ARC0000176185_0846842746.0001


4. rman-delete-expired-archivelogs.txt

Once we deleted the archive logs at OS level now should be crosschecked and deleted the expired archive logs.

run
{
allocate channel d1 type disk;
allocate channel d2 type disk;
crosscheck archivelog all;
delete noprompt expired archivelog all;
}


schedule-delete-applied-archivelogs.cmd

you need to schedule only this file schedule-delete-applied-archivelogs.cmd

call E:\Dailybackups\delete-archive-logs\1.cmd
call E:\Dailybackups\delete-archive-logs\os-script-to-delete-archivelogs.cmd
call D:\app\Administrator\product\11.2.0\dbhome_1\bin\rman target sys/uaelivesforevergis nocatalog 
cmdfile='E:\Dailybackups\delete-archive-logs\rman-delete-expired-archivelogs.txt' log=E:\Dailybackups\delete-archive-logs\\archive-log-backup-log"%date:~7,2%%date:~4,2%%date:~10,4%".log
