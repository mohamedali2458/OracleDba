Change the DBNAME with NID utility in Oracle

1. Check the location of data files

set line 200 pages 200
column name for a50
column file_name for a50
column member for a50
select name from v$controlfile;
select file_name from dba_data_files;
select file_name from dba_temp_files;
select member from v$logfile;

SQL> select name from v$controlfile;

NAME
——————————————
E:\ORADATA\IC11G\CONTROL01.CTL
E:\ORADATA\IC11G\CONTROL02.CTL

SQL> select file_name from dba_data_files;

FILE_NAME
——————————————
E:\ORADATA\IC11G\USERS01.DBF
E:\ORADATA\IC11G\UNDOTBS01.DBF
E:\ORADATA\IC11G\SYSAUX01.DBF
E:\ORADATA\IC11G\SYSTEM01.DBF

SQL> select file_name from dba_temp_files;

FILE_NAME
——————————————
E:\ORADATA\IC11G\TEMP01.DBF

SQL> select member from v$logfile;

MEMBER
——————————————
E:\ORADATA\IC11G\REDO03.LOG
E:\ORADATA\IC11G\REDO02.LOG
E:\ORADATA\IC11G\REDO01.LOG

Note: In Windows under the ORADATA folder, we can also change folder name IC11g to ORCL



2. Shut down the database to change the name with the nid process.

Shutdown immediate;

3. Startup the database at mount state for using the NID utility

startup mount

4. Use the NID utility to change the name
Note: Change db name from IC11g to ORCL

SET oracle_Sid=IC11G

nid target=sys/sys123 dbname=ORCL

Output:
C:\Users\e3019447>nid target=sys/sys123 dbname=ORCL

DBNEWID: Release 11.2.0.4.0 – Production on Mon Jun 5 01:04:32 2017

Copyright (c) 1982, 2011, Oracle and/or its affiliates. All rights reserved.

Connected to database IC11G (DBID=231578491)

Connected to server version 11.2.0

Control Files in the database:
E:\ORADATA\IC11G\CONTROL01.CTL
E:\ORADATA\IC11G\CONTROL02.CTL

Change database ID and database name IC11G to ORCL? (Y/[N]) => Y

Proceeding with operation
Changing database ID from 231578491 to 1473611297
Changing database name from IC11G to ORCL
Control File E:\ORADATA\IC11G\CONTROL01.CTL – modified
Control File E:\ORADATA\IC11G\CONTROL02.CTL – modified
Datafile E:\ORADATA\IC11G\SYSTEM01.DB – dbid changed, wrote new name
Datafile E:\ORADATA\IC11G\SYSAUX01.DB – dbid changed, wrote new name
Datafile E:\ORADATA\IC11G\UNDOTBS01.DB – dbid changed, wrote new name
Datafile E:\ORADATA\IC11G\USERS01.DB – dbid changed, wrote new name
Datafile E:\ORADATA\IC11G\TEMP01.DB – dbid changed, wrote new name
Control File E:\ORADATA\IC11G\CONTROL01.CTL – dbid changed, wrote new name
Control File E:\ORADATA\IC11G\CONTROL02.CTL – dbid changed, wrote new name
Instance shut down

The database name changed to ORCL.
Modify the parameter file and generate a new password file before restarting.
The database ID for database ORCL changed to 1473611297.
All previous backups and archived redo logs for this database are unusable.
The database has been shut down, open the database with RESETLOGS option.
Successfully changed database name and ID.
DBNEWID – Completed succesfully.


5. After the NID utility is done, try to start the database in the open state

ALTER SYSTEM SET DB_NAME=ORCL SCOPE=spfile;
startup nomount;
alter database mount;
alter database open resetlogs;

Note: The following error may occur after the NID utility
ORA-01103: The database name ‘ORCL’ in the control file is not ‘IC11G’

Solution: Alter the db_name parameter in SPFile
ALTER SYSTEM SET DB_NAME=ORCL SCOPE=spfile;

When you start the database may occur so change your environment variable from ORACLE_SID to ORCL
Set ORACLE_SID=ORCL
OR
Change the service name on the window platform
oradim -Delete -SID IC11g
oradim -NEW -SID ORCL

ORA-12560: TNS: Protocol adapter error
Go to folder %oracle_home%\database in windows:
Rename the password file from PWDIC11g.ora to PWDORCL.ora
Rename Spfile from SPFILEIC11g.ora to SPFILEORCL.ora


6. If you like to move database as new database name as default setting, it better to rename the folder associated with database for future better handling.
Note: We are renaming all folder associated with old oracle home like oradata has IC11g name and change parameter control_file to move in new destination.

-- Creating Pfile for editing parameters
Create pfile='E:\pfile.txt' from spfile;

— Spooling rename file from IC11g to ORCL folder
set line 200 pages 200
spool E:\rename.txt
— rename datafile
select ‘Alter database rename file ”’||file_name||”’ TO ”’||replace(file_name,’IC11G’,’ORCL’)||”’;’ from dba_Data_files;
— rename temp files
select ‘Alter database rename file ”’||file_name||”’ TO ”’||replace(file_name,’IC11G’,’ORCL’)||”’;’ from dba_temp_files;
— rename redo log files
select ‘Alter database rename file ”’||member||”’ TO ”’||replace(member,’IC11G’,’ORCL’)||”’;’ from v$logfile;
spool off


7. Shutdown the database

shutdown immediate;

8. Edit the pfile.txt and change the parameter as needed.
I found following parameter using IC11g as default location, Change to ORCL

*.audit_file_dest='C:\Oracle11g\admin\ORCL\adump'
*.control_files='E:\Oradata\ORCL\control01.ctl','E:\Oradata\ORCL\control02.ctl'

9. Now move on to windows and check the location which mentioned is present

Note: Rename the folder from IC11g to ORCL in windows

Rename the folder in admin directory from IC11g to ORCL
Rename the folder under oradata directory from IC11g to ORCL


10. Startup nomount the database from pfile

sqlplus sys as sysdba
create spfile from pfile='E:\pfile.txt'
startup nomount;
alter database mount;


11. Change the location of the database file with rename folder
Note: Fire the alter command created in step 6.

Alter database rename file 'E:\ORADATA\IC11G\USERS01.DBF' TO 'E:\ORADATA\ORCL\USERS01.DBF';

Alter database rename file 'E:\ORADATA\IC11G\UNDOTBS01.DBF' TO 'E:\ORADATA\ORCL\UNDOTBS01.DBF';

Alter database rename file 'E:\ORADATA\IC11G\SYSAUX01.DBF' TO 'E:\ORADATA\ORCL\SYSAUX01.DBF';

Alter database rename file 'E:\ORADATA\IC11G\SYSTEM01.DBF' TO 'E:\ORADATA\ORCL\SYSTEM01.DBF';

Alter database rename file 'E:\ORADATA\IC11G\TEMP01.DBF' TO 'E:\ORADATA\ORCL\TEMP01.DBF';

Alter database rename file 'E:\ORADATA\IC11G\REDO03.LOG' TO 'E:\ORADATA\ORCL\REDO03.LOG';

Alter database rename file 'E:\ORADATA\IC11G\REDO02.LOG' TO 'E:\ORADATA\ORCL\REDO02.LOG';

Alter database rename file 'E:\ORADATA\IC11G\REDO01.LOG' TO 'E:\ORADATA\ORCL\REDO01.LOG';


12. After open the database in normal mode:

alter database open;

13. Change the service name in listener.ora and tnsnames.ora

