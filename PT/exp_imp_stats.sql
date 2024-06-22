Export and Import statistics

Export and Import schema statistics from one database to another

On Source

0. Environment
1. Create table to store statistics
2. Store schema stats to table STATS_TABLE
3. Export the table STATS_TABLE using datapump
4. Transfer the dump to target server

On Target

5. Delete the stats before import on target server
6. Import using impdp
7. Importing stats into same schema dbms_stats
8. Importing into different schema


Environment:

Source:

OS: Oracle Linux 5.7
Database version : 11.2.0.3.0
Database Name: orcl
Schema Name: SH
Host name: rac1.rajasekhar.com

Target:

OS: Oracle Linux 5.7
Database version : 11.2.0.3.0
Database Name: cat
Schema Name: SH
Host name: rac2.rajasekhar.com


  
Step 1: Create table to store statistics

SQL> show user
USER is "SYS"
SQL> EXEC DBMS_STATS.CREATE_STAT_TABLE('SH', 'STATS_TABLE');

PL/SQL procedure successfully completed.

SQL> select OWNER, OBJECT_NAME, object_type, CREATED from dba_objects where OBJECT_NAME='STATS_TABLE';

OWNER    OBJECT_NAME          OBJECT_TYPE         CREATED
-------- -------------------- ------------------- ---------
SH       STATS_TABLE          TABLE               31-AUG-16
SH       STATS_TABLE          INDEX               31-AUG-16

SQL>

SQL> select count(*) from sh.STATS_TABLE;

  COUNT(*)
----------
         0


Step 2: Export schema stats – will be stored in the ‘STATS_TABLE’

SQL> exec dbms_stats.export_schema_stats(ownname => 'SH', stattab => 'STATS_TABLE');

PL/SQL procedure successfully completed.

SQL> select count(*) from sh.STATS_TABLE;

  COUNT(*)
----------
      3966


Step 3: Export the table STATS_TABLE using datapump

[oracle@rac1 ~]$ . oraenv
ORACLE_SID = [orcl] ?
[oracle@rac1 ~]$ expdp directory=DATA_PUMP_DIR dumpfile=stats.dmp logfile=stats.log tables=SH.STATS_TABLE

Export: Release 11.2.0.3.0 - Production on Wed Aug 31 16:59:34 2016

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

Username: / as sysdba

Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options
Starting "SYS"."SYS_EXPORT_TABLE_01":  /******** AS SYSDBA directory=DATA_PUMP_DIR dumpfile=stats.dmp logfile=stats.log tables=SH.STATS_TABLE
Estimate in progress using BLOCKS method...
Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
Total estimation using BLOCKS method: 640 KB
Processing object type TABLE_EXPORT/TABLE/TABLE
Processing object type TABLE_EXPORT/TABLE/INDEX/INDEX
Processing object type TABLE_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
. . exported "SH"."STATS_TABLE"                          425.6 KB    3966 rows
Master table "SYS"."SYS_EXPORT_TABLE_01" successfully loaded/unloaded
******************************************************************************
Dump file set for SYS.SYS_EXPORT_TABLE_01 is:
  /u01/app/oracle/admin/orcl/dpdump/stats.dmp
Job "SYS"."SYS_EXPORT_TABLE_01" successfully completed at 16:59:58

[oracle@rac1 ~]$


Step 4: Transfer the dump to target server

[oracle@rac1 ~]$ cd /u01/app/oracle/admin/orcl/dpdump/
[oracle@rac1 dpdump]$ scp stats.dmp oracle@rac2.rajasekhar.com:/u01/app/oracle/admin/cat/dpdump/
stats.dmp 						 100%  532KB 532.0KB/s   00:00
[oracle@rac1 dpdump]$


On Target
===========

Step 5: Delete the stats before import on target server

-- before delete stats, please have backup but i am not taking here because it is test machine.

EXEC DBMS_STATS.CREATE_STAT_TABLE('SH', 'STATS');
exec dbms_stats.export_schema_stats(ownname => 'SH',stattab => 'STATS');

SQL> EXEC DBMS_STATS.delete_schema_stats('SH');

PL/SQL procedure successfully completed.


Step 6: Importing STATS_TABLE table in scott schema

[oracle@rac2 ~]$ . oraenv
ORACLE_SID = [cat] ?
The Oracle base remains unchanged with value /u01/app/oracle
[oracle@rac2 ~]$ impdp directory=DATA_PUMP_DIR dumpfile=stats.dmp logfile=impstats.log TABLES=SH.STATS_TABLE

Import: Release 11.2.0.3.0 - Production on Wed Aug 31 17:08:15 2016

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

Username: / as sysdba

Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
Master table "SYS"."SYS_IMPORT_TABLE_01" successfully loaded/unloaded
Starting "SYS"."SYS_IMPORT_TABLE_01":  /******** AS SYSDBA directory=DATA_PUMP_DIR dumpfile=stats.dmp logfile=impstats.log TABLES=SH.STATS_TABLE
Processing object type TABLE_EXPORT/TABLE/TABLE
Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
. . imported "SH"."STATS_TABLE"                          425.6 KB    3966 rows
Processing object type TABLE_EXPORT/TABLE/INDEX/INDEX
Processing object type TABLE_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Job "SYS"."SYS_IMPORT_TABLE_01" successfully completed at 17:08:20

[oracle@rac2 ~]$


SQL> select OWNER, OBJECT_NAME, object_type, CREATED from dba_objects where OBJECT_NAME='STATS_TABLE';

OWNER   OBJECT_NAME          OBJECT_TYPE         CREATED
------- -------------------- ------------------- ---------
SH      STATS_TABLE          INDEX               31-AUG-16
SH      STATS_TABLE          TABLE               31-AUG-16

SQL> select count(*) from sh.STATS_TABLE;

  COUNT(*)
----------
      3966


Step 7: Importing into same schema(SH – SH), then ignore step 8

SQL> exec dbms_stats.import_schema_stats(OWNNAME=>'SH', STATTAB=>'STATS_TABLE');

PL/SQL procedure successfully completed.


Step 8: Importing into different schema( USER A – USER B), then skip step 7

update newschema.STATS_TABLE set c5='NEW_SCHEMA_NAME';
commit;
dbms_stats.import_schema_stats(OWNNAME=>'NEW_SCHEMA_NAME', STATTAB=>'STATS');

