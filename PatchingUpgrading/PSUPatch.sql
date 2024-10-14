Step by step apply Rolling PSU Patch in Oracle Database 19c RAC environment :
===========================================================================
  
Patch Information:- Patch 30087906 – Database Release Update Revision 19.3.2.0.191015 


Step:-1 Environment Details 

export ORACLE_HOME=/u01/app/19c/grid 
export PATH=/u01/app/19c/grid/bin:$PATH 

[oracle@rac1 ~]$ srvctl config database -verbose 
oradbwr /u01/app/oracle/product/19c/dbhome_1 19.0.0.0.0 

[oracle@rac1 ~]$ crsctl query crs softwareversion -all 
Oracle Clusterware version on node [rac1] is [19.0.0.0.0] 
Oracle Clusterware version on node [rac2] is [19.0.0.0.0] 

[oracle@rac1 ~]$ cat /etc/redhat-release 
Red Hat Enterprise Linux Server release 7.7 (Maipo) 

[oracle@rac1 ~]$ uname -sr 
Linux 4.1.12-124.34.1.el7uek.x86_64 


Step:2 Prerequisites 
Our OPatch utility version 12.2.0.1.17 or later to apply this patch. 
Oracle recommends that you use the latest released OPatch version for 19c 

[oracle@rac1 ~]$ $ORACLE_HOME/OPatch/opatch version 
OPatch Version: 12.2.0.1.17 
OPatch succeeded. 

Note:- No Need to upgrade the OPatch utility. 


Step:-3 Validation of Oracle Inventory 
. .grid.env 

$ORACLE_HOME/OPatch/opatch lsinventory -detail -oh $GRID_HOME 

SQL> select PATCH_ID,ACTION,STATUS from dba_registry_sqlpatch;
PATCH_ID ACTION STATUS
———- ————— ————————-
29517242 APPLY SUCCESS


Step:-4 Download and Unzip the Patch
Download the Patch 30087906 – Database Release Update Revision
19.3.2.0.191015 from Oracle support and move to server

[root@rac1 u01]# unzip p30135696_190000_Linux-x86-64.zip
[root@rac1 u01]# chmod 775 p30135696_190000_Linux-x86-64.zip

Step:-5 Run OPatch Conflict Check
$ORACLE_HOME/OPatch/opatch prereq
CheckConflictAgainstOHWithDetail -phBaseDir /u01/30135696/30087906
$ORACLE_HOME/OPatch/opatch prereq
CheckConflictAgainstOHWithDetail -phBaseDir /u01/30135696/29585399
$ORACLE_HOME/OPatch/opatch prereq
CheckConflictAgainstOHWithDetail -phBaseDir /u01/30135696/29517247
$ORACLE_HOME/OPatch/opatch prereq
CheckConflictAgainstOHWithDetail -phBaseDir /u01/30135696/
$ORACLE_HOME/OPatch/opatch prereq
CheckConflictAgainstOHWithDetail -phBaseDir /u01/30135696/29401763

Sample:-
[oracle@rac1 ~]$ $ORACLE_HOME/OPatch/opatch prereq
CheckConflictAgainstOHWithDetail -phBaseDir /u01/30135696/29401763
Oracle Interim Patch Installer version 12.2.0.1.17
Copyright (c) 2019, Oracle Corporation. All rights reserved.
PREREQ session
Oracle Home : /u01/app/19c/grid
Central Inventory : /u01/app/oraInventory
from : /u01/app/19c/grid/oraInst.loc
OPatch version : 12.2.0.1.17
OUI version : 12.2.0.7.0
Log file location : /u01/app/19c/grid/cfgtoollogs/opatch/opatch2019-12-27_23-58-19PM_1.log


Invoking prereq “checkconflictagainstohwithdetail” 
Prereq “checkConflictAgainstOHWithDetail” passed. 


Step:-6 Run OPatch SystemSpace Check 
Check if enough free space is available on the ORACLE_HOME filesystem for the patches to be applied 
NODE 1 


Step:-7 Using opatchauto applying 
The Opatch utility has automated the patch application for the Oracle Grid Infrastructure (GI) home and 
the Oracle RAC database homes. It operates by querying existing configurations and automating the steps 
required for patching each Oracle RAC database home of same version and the GI home. 

Note:- Below Command is applying patch both the homes Grid and Oracle for 1st node. 
[root@rac1 ~]# export PATH=$PATH:/u01/app/19c/grid/OPatch 
[root@rac1 ~]# opatchauto apply /u01/30135696 
OPatchauto session is initiated at Sat Dec 28 00:04:53 2019 
System initialization log file is /u01/app/19c/grid/cfgtoollogs/opatchautodb/systemconfig2019-12-28_12-05-10AM.log. 
Session log file is /u01/app/19c/grid/cfgtoollogs/opatchauto/opatchauto2019-12-28_12-12-57AM.log 

The id for this session is BQ6L 

Executing OPatch prereq operations to verify patch applicability on home /u01/app/19c/grid 

Executing OPatch prereq operations to verify patch applicability on home /u01/app/oracle/product/19c/dbhome_1 

Patch applicability verified successfully on home /u01/app/19c/grid 

Patch applicability verified successfully on home /u01/app/oracle/product/19c/dbhome_1 

Verifying SQL patch applicability on home /u01/app/oracle/product/19c/dbhome_1

SQL patch applicability verified successfully on home /u01/app/oracle/product/19c/dbhome_1 

Preparing to bring down database service on home /u01/app/oracle/product/19c/dbhome_1 

Successfully prepared home /u01/app/oracle/product/19c/dbhome_1 to bring down database service 

Bringing down CRS service on home /u01/app/19c/grid 

CRS service brought down successfully on home /u01/app/19c/grid 

Performing prepatch operation on home /u01/app/oracle/product/19c/dbhome_1 

Perpatch operation completed successfully on home /u01/app/oracle/product/19c/dbhome_1 

Start applying binary patch on home /u01/app/oracle/product/19c/dbhome_1 

Binary patch applied successfully on home /u01/app/oracle/product/19c/dbhome_1 

Performing postpatch operation on home /u01/app/oracle/product/19c/dbhome_1 

Postpatch operation completed successfully on home /u01/app/oracle/product/19c/dbhome_1 

Start applying binary patch on home /u01/app/19c/grid 

Binary patch applied successfully on home /u01/app/19c/grid 

Starting CRS service on home /u01/app/19c/grid 

CRS service started successfully on home /u01/app/19c/grid 

Preparing home /u01/app/oracle/product/19c/dbhome_1 after database service restarted 
No step execution required……… 
Trying to apply SQL patch on home /u01/app/oracle/product/19c/dbhome_1 
SQL patch applied successfully on home /u01/app/oracle/product/19c/dbhome_1 
OPatchAuto successful. 

——————————–Summary——————————– 
Patching is completed successfully. Please find the summary as follows: 

Host:rac1 
RAC Home:/u01/app/oracle/product/19c/dbhome_1
Version:19.0.0.0.0 

Summary: 
==Following patches were SKIPPED: 
Patch: /u01/30135696/29517247 
Reason: This patch is not applicable to this specified target type – “rac_database” 

Patch: /u01/30135696/29401763 
Reason: This patch is not applicable to this specified target type – “rac_database” 

Patch: /u01/30135696/29585399 
Reason: This patch is already been applied, so not going to apply again. 

==Following patches were SUCCESSFULLY applied: 
Patch: /u01/30135696/30087906 
Log: /u01/app/oracle/product/19c/dbhome_1/cfgtoollogs/opatchauto/core/opatch/opatch2019-12-28_00-22-26AM_1.log 

OPatchauto session completed at Sat Dec 28 00:48:56 2019 
Time taken to complete the session 44 minutes, 3 seconds


Monitoring the log 
tail -f /u01/app/19c/grid/cfgtoollogs/opatchautodb/systemconfig2019-12-28_12-05-10AM.log 


Step:-8 Copy the patch folder from 1st node to 2nd node 

[root@rac1 u01]# scp -rp 30135696 root@rac2:/u01 
[root@rac2 u01]# chown -R oracle:oinstall 30135696/ 
[root@rac2 u01]# chown 775 30135696



NODE 2 

Step:-9 Start applying on 2nd node [root@rac2 30135696]# export PATH=$PATH:/u01/app/19c/grid/OPatch [root@rac2 30135696]# opatchauto apply /u01/30135696 OPatchauto session is initiated at Sat Dec 28 01:33:26 2019 System initialization log file is /u01/app/19c/grid/cfgtoollogs/opatchautodb/systemconfig2019-12-28_01-33-35AM.log. Session log file is /u01/app/19c/grid/cfgtoollogs/opatchauto/opatchauto2019-12-28_01-42-11AM.log The id for this session is PXNA Executing OPatch prereq operations to verify patch applicability on home /u01/app/19c/grid Executing OPatch prereq operations to verify patch applicability on home /u01/app/oracle/product/19c/dbhome_1 Patch applicability verified successfully on home /u01/app/19c/grid Patch applicability verified successfully on home /u01/app/oracle/product/19c/dbhome_1 Verifying SQL patch applicability on home /u01/app/oracle/product/19c/dbhome_1 SQL patch applicability verified successfully on home /u01/app/oracle/product/19c/dbhome_1 Preparing to bring down database service on home /u01/app/oracle/product/19c/dbhome_1 Successfully prepared home /u01/app/oracle/product/19c/dbhome_1 to
