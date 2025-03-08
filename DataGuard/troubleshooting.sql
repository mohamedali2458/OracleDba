Troubleshooting Oracle Data Guard

How to check your Data Guard setup?

. oraenv <<< DBTEST
dgmgrl / "show configuration lag;"

DGMGRL for Linux: Release 19.0.0.0.0 - Production on Wed Feb 19 15:06:17 2025
Version 19.20.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Welcome to DGMGRL, type "help" for information.
Connected to "DBTEST_IN"
Connected as SYSDG.

Configuration - dtg

  Protection Mode: MaxAvailability
  Members:
  dbtest_in - Primary database
    dbtest_cr - Physical standby database
                Transport Lag:      0 seconds (computed 1 second ago)
                Apply Lag:          0 seconds (computed 1 second ago)

Fast-Start Failover:  Disabled

Configuration Status:
SUCCESS   (status updated 26 seconds ago)


This is an example of a Data Guard configuration not working correctly:

Configuration - dtg

  Protection Mode: MaxAvailability
  Members:
  dbtest_in - Primary database
    Error: ORA-16810: multiple errors or warnings detected for the member

    dbtest_cr - Physical standby database
      Warning: ORA-16854: apply lag could not be determined

Fast-Start Failover:  Disabled

Configuration Status:
ERROR   (status updated 56 seconds ago)


Check the Fast Recovery Area on your standby database

A common problem you may have on a standby database is the Fast Recovery Area (FRA) being full. You probably know that a standby database will apply the changes from the primary without waiting for the archivelog to be shipped, but the archivelog is shipped anyway to the standby. This is because there is no guarantee that the standby database is always up and running, so archivelogs must be transported to the other site for later apply if needed. Another thing is that you probably enabled Flashback Database on both databases, and archivelogs are required for a Flashback Database operation. These shipped archivelogs will naturally land in the FRA, and unless you configured a deletion policy, they will never be deleted. As you probably don’t do backups on the standby database, nothing could flag these archivelogs as reclaimable (meaning that they are now useless and can be deleted). If your FRA is quite big, you may discover this problem several weeks or months after the initial setup.

Check the FRA usage on your standby with this query:

select  sum(PERCENT_SPACE_USED-PERCENT_SPACE_RECLAIMABLE) "Real FRA usage %" from v$flash_recovery_area_usage;
Real FRA usage %
----------------
           32.86

If the FRA is almost full, you can remove older archivelogs, for example those older than 2 days if your standby has a 1-day lag:

rman target /
delete force noprompt archivelog all completed before 'sysdate-2';
exit;


Then check again the FRA and the lag of your Data Guard setup.

2.
Check standby_file_management parameter

Another thing that can break your sync is the standby_file_management parameter having an incorrect value. In most cases, it must be set to AUTOMATIC: it means that any file created on the primary will be created on the standby. It’s the way it is supposed to work:

show parameter standby_file_management
NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
standby_file_management 	     string	 AUTO
If standby_file_management is set to MANUAL, your standby will not be in sync anymore as soon as a new datafile is created on the primary. You will need to manually create the file on the standby to continue the sync. Not very convenient.

The MANUAL mode exists because some older configurations had different filesystems on primary and on standby and didn’t use OMF, meaning that standby database cannot guess where to put the new file.

Both primary and standby databases must have this parameter set to AUTO nowadays.


3.
Cross test connexions
Your Data Guard setup can only work if your databases are able to communicate together. If you are not so sure if something changed on your network, for example a new firewall rule, check your connexions from both servers using the SYS account.

From your primary:

sqlplus sys@DBTEST_CR as sysdba
sqlplus sys@DBTEST_IN as sysdba
From your standby:

sqlplus sys@DBTEST_CR as sysdba
sqlplus sys@DBTEST_IN as sysdba


4.
Check password file
When your standby database is MOUNTED, the only way to authenticate the SYS user is by using the password file. If you changed the SYS password on the primary, it will be changed inside the database (and replicated) as well as in the local password file, but the password file on the standby site won’t be updated. You must then copy the password file from the primary database to the standby database. Copy is done with a scp command, for example from my primary server:


srvctl config database -db DBTEST_IN | grep Password
Password file: /u01/app/odaorahome/oracle/product/19.0.0.0/dbhome_4/dbs/orapwDBTEST

scp `srvctl config database -db OP1 | grep Password | awk '{print $3;}'` oracle@oda-x11-cr:`srvctl config database -db OP1 | grep Password | awk '{print $3;}'`
A restart of the standby database may be needed.


5.
Check alert_DBTEST.log and drcDBTEST.log on both servers

Never miss an error reported in the alert_DBTEST.log on both sides. I would recommend disabling the 
Data Guard configuration, doing a tail -f on both alert_DBTEST.log files, and enabling back the configuration:

. oraenv <<< DBTEST
dgmgrl / "disable configuration;"
sleep 60
dgmgrl / "enable configuration;"

There are also dedicated trace files for Data Guard, at the same place as alert_DBTEST.log: drcDBTEST.log. 
You may find additional information for troubleshooting your configuration in these files.


6.
Remove and recreate the configuration

Data Guard configuration is just a couple of parameters stored in a file on both sides. It’s easy to drop 
and create again this configuration without actually rebuilding the standby database. If you want to make 
sure that nothing survives from your old configuration, just remove the broker files before creating the 
configuration again.

From the primary:

dgmgrl sys
edit configuration set protection mode as maxperformance;
remove configuration;
exit;

sqlplus / as sysdba
sho parameter dg_broker_config_file

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
dg_broker_config_file1		     string	 /u01/app/odaorahome/oracle/pro
						 duct/19.0.0.0/dbhome_4/dbs/dr1
						 DBTEST_IN.dat
dg_broker_config_file2		     string	 /u01/app/odaorahome/oracle/pro
						 duct/19.0.0.0/dbhome_4/dbs/dr2
						 DBTEST_IN.dat

alter system set dg_broker_start=FALSE;

host rm /u01/app/odaorahome/oracle/product/19.0.0.0/dbhome_4/dbs/dr1DBTEST_IN.dat
host rm /u01/app/odaorahome/oracle/product/19.0.0.0/dbhome_4/dbs/dr2DBTEST_IN.dat

exit


From the standby:

sqlplus / as sysdba
sho parameter dg_broker_config_file

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
dg_broker_config_file1		     string	 /u01/app/odaorahome/oracle/pro
						 duct/19.0.0.0/dbhome_4/dbs/dr1
						 DBTEST_CR.dat
dg_broker_config_file2		     string	 /u01/app/odaorahome/oracle/pro
						 duct/19.0.0.0/dbhome_4/dbs/dr2
						 DBTEST_CR.dat
alter system set dg_broker_start=FALSE;

host rm /u01/app/odaorahome/oracle/product/19.0.0.0/dbhome_4/dbs/dr1DBTEST_CR.dat
host rm /u01/app/odaorahome/oracle/product/19.0.0.0/dbhome_4/dbs/dr2DBTEST_CR.dat

alter system set dg_broker_start=TRUE;
exit


From the primary:

sqlplus / as sysdba
alter system set dg_broker_start=TRUE;
exit;

dgmgrl sys
create configuration DTG as primary database is 'DBTEST_IN' connect identifier is 'DBTEST_IN';
add database 'DBTEST_CR' as connect identifier is 'DBTEST_CR';
enable configuration;
edit database 'DBTEST_CR' set property LogXptMode='SYNC';
edit database 'DBTEST_IN' set property LogXptMode='SYNC';
edit database 'DBTEST_CR' set property StandbyFileManagement='AUTO';
edit database 'DBTEST_IN' set property StandbyFileManagement='AUTO';
EDIT DATABASE 'DBTEST_CR' SET PROPERTY 'ArchiveLagTarget'=1200;
EDIT DATABASE 'DBTEST_IN' SET PROPERTY 'ArchiveLagTarget'=1200;
Edit database 'DBTEST_CR' set property StaticConnectIdentifier='(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oda-x11-cr)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=DBTEST_CR)(INSTANCE_NAME=DBTEST)(SERVER=DEDICATED)))';
Edit database 'DBTEST_IN' set property StaticConnectIdentifier='(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oda-x11-in)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=DBTEST_IN)(INSTANCE_NAME=DBTEST)(SERVER=DEDICATED)))';
edit configuration set protection mode as maxavailability;
show configuration lag;
exit;
Note that the StaticConnectIdentifier property is only mandatory when using a port different than 1521.


7.
Recover standby database from service

If you still struggle to get your standby back in sync, because too many archivelogs are missing or because 
the archivelogs are not on the primary site anymore, you can use this nice RMAN command on your standby:

sqlplus / as sysdba
alter system set dg_broker_start=false;
exit;

srvctl stop database -db DBTEST_CR
sleep 10
srvctl start database -db DBTEST_CR -o mount

rman target /
recover database from service 'DBTEST_IN';
exit;

sqlplus / as sysdba
alter system set dg_broker_start=true;
exit;

This RECOVER DATABASE FROM SERVICE will do an incremental backup on the primary to recover the standby 
without needing the missing archivelogs. It’s convenient and much faster than rebuilding the standby 
from scratch.


8.
Check SCN

In the good old days of Data Guard on Oracle 9i, the broker didn’t exist and you had to configure everything 
yourself. At this time, I used to have a look at the SCN on both databases for monitoring the lag. Nothing 
changed regarding the SCN: on a primary, you will never see the same SCN each time you query its value. 
This is because the query itself will increase the SCN by 1, as well as other background queries are running:

select current_scn from v$database;
CURRENT_SCN
-----------
  271650667

select current_scn from v$database;
CURRENT_SCN
-----------
  271650674

select current_scn from v$database;
CURRENT_SCN
-----------
  271650675

select current_scn from v$database;
CURRENT_SCN
-----------
  271650678


On a standby database, the SCN can only increase if changes are pushed by a primary. And for sure, the SCN 
will always be lower than the one on the primary. If your standby database is not opened, meaning that you 
don’t have the Active Data Guard option, you will query the same SCN for a couple of minutes, and you will 
see big jumps in figures from time to time:

select current_scn from v$database;
CURRENT_SCN
-----------
  271650664

select current_scn from v$database;
CURRENT_SCN
-----------
  271650664

select current_scn from v$database;
CURRENT_SCN
-----------
  271651042

select current_scn from v$database;
CURRENT_SCN
-----------
  271651042

