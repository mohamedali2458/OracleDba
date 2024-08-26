How to change Archive destination
  
Use similar commands to change archive destination, to change archive destination no need to bounce the database.

1. Verify existing values

SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /u01/app/oracle/arch/vada <------
Oldest online log sequence     147
Next log sequence to archive   149
Current log sequence           149

SQL> show parameter log_archive_dest_1
NAME                                 TYPE        VALUE
------------------------------------ ----------- ----------------------------------
log_archive_dest_1                   string      LOCATION=/u01/app/oracle/arch/vada


2. Modify the archive destination

SQL> alter system set log_archive_dest_1='LOCATION=/u02/arch/vada' scope=both;
System altered.


3. Verify the results

SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /u02/arch/vada <----
Oldest online log sequence     147
Next log sequence to archive   149
Current log sequence           149

SQL> show parameter log_archive_dest_1
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
log_archive_dest_1                   string      LOCATION=/u02/arch/vada

Note: If you set log_archive_dest_1 and log_archive_dest_2, it will store same log file in both locations.
