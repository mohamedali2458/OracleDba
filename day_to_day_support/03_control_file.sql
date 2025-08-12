--backup of controlfile to trace
SQL> alter database backup controlfile to trace as '/u01/backup.ctl';

--Multiplexing the Control file

set linesize 200
col name for a90
select name from v$controlfile;

show parameter control_files;

--we got 2 control files and we are adding the 3rd one
sql> alter system set control_files='/u01/prod/control01.ctl', '/u01/prod/control02.ctl','/u01/prod/control03.ctl' SCOPE=spfile;

SQL> shutdown immediate;

SQL> ! cp /u01/prod/control01.ctl /u01/prod/control03.ctl

sql> startup

set linesize 200
col name for a90
select name from v$controlfile;

