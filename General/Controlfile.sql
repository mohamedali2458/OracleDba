CONTROL FILE MANAGEMENT

(Backup of ControlFile)
SQL> alter database backup controlfile to trace as '/u01/backup.ctl';


Multiplexing the Control file
  
Steps:-
1. 
select name from v$controlfile;
(suppose we have 2 files only and we want to add a 3rd control file)
  
sql> alter system set control_files='/u01/prod/control01.ctl','/u01/prod/control02.ctl','/u01/prod/control03.ctl' SCOPE=spfile;
SQL> shutdown immediate;

2. $cp /u01/prod/control01.ctl /u01/prod/control03.ctl
3. sql> startup
4. sql> select name from v$controlfile;
