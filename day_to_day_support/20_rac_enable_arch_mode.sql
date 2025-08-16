Enabling Archive Log Mode In Oracle 19c RAC Database
====================================================
Step:-1 Before Changing the archivelog mode check the status. 

SQL> select log_mode,name from v$database;
LOG_MODE     NAME
------------ ---------
NOARCHIVELOG DEV

SQL> archive log list
Database log mode              No Archive Mode
Automatic archival             Disabled
Archive destination            /u01/home/app/11.2.0/db_1/dbs/arch
Oldest online log sequence     29
Current log sequence           30

SQL> exit;


Step:-2 Stop the rac database service.

srvctl stop database -d dev
srvctl status database -d dev


Step:-3 Start the rac database in mount state.

srvctl start database -d dev -o mount
srvctl status database -d dev


Step:-4 Enable archive log mode rac database and set destination to a ASM DISK group

sqlplus / as sysdba

alter system set log_archive_dest_1='LOCATION=+DATA/' scope=both sid='*';

alter database archivelog;


Step:-5 Stop the rac database service.

srvctl stop database -d dev
srvctl status database -d dev

  
Step:-6 Restart the rac database

srvctl start database -d dev 
srvctl status database -d dev 


Step:-7 Check Archivelog Status.

sqlplus / as sysdba
SQL> archive log list

SQL> select log_mode,name from v$database;

