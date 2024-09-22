RAC Patching (Rolling Vs Non-Rolling)
=====================================
Oracle Release Quarterly Patches, In a year 4 times Oracle will releases patches.
Patches: Quarterly 
JAN - (17 to 21)
APR - (17 to 21)
JUL - (17 to 21)
OCT - (17 to 21)

What are the different times of Patching Methods in Oracle RAC?
- Rolling and Non-Rolling

RAC Patching Methods:
Rolling Patching:
Patching one node at a time = Node1 - Node2 - Node3 - Node4
- No downtime needed 
- Patching duration is longer 

Non-Rolling Patching 
Patching all nodes at a time = Node1 & Node2 & Node3 & Node4
- Complete downtime 
- Patching duration is smaller  

oraclelab1: +ASM1 & DEVDB1
oraclelab2: +ASM2 & DEVDB2

Rolling Patching Steps:
=======================
Steps 1: Node1 Patching   
1. Patch GI Home - OPatch   
2. Patch DB Home - OPatch   

Steps Node2 Patching    
1. Patch GI Home - OPatch  
2. Patch DB Home - OPatch

Step 3: Patch databases - DEVDB - datapatch  (Perform from any of Node1 or Node2 database instance)

Here we are using 2 tools: OPatch, datapatch

Non-Rolling Patching Steps:
===========================
Steps 1: Node1 & Node2 Patching together
   
Node1:    Node2:
1. Patch GI Home - OPatch 1. Patch GI Home - OPatch
2. Patch DB Home - OPatch 2. Patch DB Home - OPatch

Step 2: Patch databases - DEVDB - datapatch (Perform from any of Node1 or Node2 database instance)

Tools used for patching:
1. Patch GI Home Patching using - Opatch   
2. Patch DB Home Patching using - Opatch 
3. Patch databases using - datapatch  

GI Software & Oracle Software - Base software - Downloaded freely from oracle.edelivery.com 
- Install GI Home & Oracle Home 

Patches - are downloaded in support.oracle.com 
- You need a license 

Patches - we will apply on top of base software (GI Home & Oracle Home)
- BUG fixes 
- New enhancements 
- Security fixes
- Vulnerability fixes
- New features 

How many times customer needs to apply the patches?
- It depends on the customer and it best practice to apply the 4 times all 4 quarterly patches 
1. All 4 times in a years 
2. 2 times in a years 
3. 1 times in a year 

When Oracle release patches on quarterly? 
Patches: Quarterly 
JAN - (17 to 21)
APR - (17 to 21)
JUL - (17 to 21)
OCT - (17 to 21)

What is base release or RU?
- GI and Oracle Home software whatever releases by Oracle in the base software. 
- Whatever the quarterly patches oracle releases are called RU – release updates.
GI Home - /u01/app/19.0.0.0/grid
DB Home - /u01/app/oracle/product/19.0.0.0/dbhome_1

GI and OH home: 
GI Home - /u01/app/19.0.0.0/grid
DB Home - /u01/app/oracle/product/19.0.0.0/dbhome_1

We installed 19c GI Home - Base Software (19.3)
We installed 19c DB home - Base Software (19.3)

RU-Release Updates:
19c - Quarterly Patches called as RU - Release updates 
JAN - (17 to 21)
APR - (17 to 21)
JUL - (17 to 21)
OCT - (17 to 21)

Apr - 2019 - 19.3 
Jul - 2019 - 19.4
Oct - 2019 - 19.5 

Jan - 2020 - 19.6
Apr - 2020 - 19.7
Jul - 2020 - 19.8
Oct - 2020 - 19.9

Jan - 2021 - 19.10
Apr - 2021 - 19.11
Jul - 2021 - 19.12
Oct - 2021 - 19.13

Jan - 2022 - 19.14
Apr - 2022 - 19.15
Jul - 2022 - 19.16
Oct - 2022 - 19.17

Jan - 2023 - 19.18
Apr - 2023 - 19.19
Jul - 2023 - 19.20
Oct - 2023 - 19.21

Jan - 2024 - 19.22
Apr - 2024 - 19.23
Jul - 2024 - 19.24 
Oct - 2024 - 

Node1 GI and OH Patches:
[oracle@hostnode1 ~]$ /u01/app/19.0.0.0/grid/OPatch/opatch lspatches
29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
29517247;ACFS RELEASE UPDATE 19.3.0.0.0 (29517247)
29517242;Database Release Update : 19.3.0.0.190416 (29517242)
29401763;TOMCAT RELEASE UPDATE 19.0.0.0.0 (29401763)

Note: 19.3.0.0.190416 (last 6 digits means: 16th april 2019)

[oracle@hostnode1 ~]$ /u01/app/oracle/product/19.0.0.0/dbhome_1/OPatch/opatch lspatches
29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
29517242;Database Release Update : 19.3.0.0.190416 (29517242)

Node2 GI and OH Patches:
[oracle@hostnode2 ~]$ /u01/app/19.0.0.0/grid/OPatch/opatch lspatches
29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
29517247;ACFS RELEASE UPDATE 19.3.0.0.0 (29517247)
29517242;Database Release Update : 19.3.0.0.190416 (29517242)
29401763;TOMCAT RELEASE UPDATE 19.0.0.0.0 (29401763)

[oracle@hostnode2 ~]$ /u01/app/oracle/product/19.0.0.0/dbhome_1/OPatch/opatch lspatches

From base release 19.3 we can go to any patch version, no need step by step.
if we patch to july 2024 it will take to 19.24

RU = Release Update

29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
29517242;Database Release Update : 19.3.0.0.190416 (29517242)

Note:
$GRID_HOME/OPatch/opatch lspatches
$ORACLE_HOME/OPatch/opatch lspatches
