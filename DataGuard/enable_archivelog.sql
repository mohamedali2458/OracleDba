Enable the database in Archivelog mode

Step 1: Set the following parameters in parameter file.

SQL> ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='%t_%s_%r.dbf' SCOPE=SPFILE;
SQL> ALTER SYSTEM SET log_archive_dest_1='location=/u01/app/oracle/oradata/MYSID/archive/' SCOPE=both;

Step 2: Enable archivelog using below commands.

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ARCHIVE LOG LIST;
ALTER DATABASE OPEN;

It is recommended to take a full backup before/after you brought the database in archive log mode.
