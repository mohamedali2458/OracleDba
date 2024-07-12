How To Create Database Using Dbca In Silent Mode – 19C
======================================================
From oracle 19c onward, we can create a database using dbca in silent mode with help of response file.

default response file location:
export ORACLE_HOME=/oracle/app/oracle/product/19.9.0.0/dbhome_1
cd $ORACLE_HOME/assistants/dbca

By using the default response files, you can create a new response file, as per your requirement.

Below is the response file
==========================
cat /export/home/oracle/db_create.rsp



responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v12.2.0
gdbName=DBACLASS9
sid=DBACLASS9
databaseConfigType=SI
policyManaged=false
createServerPool=false
createAsContainerDatabase=false
templateName=/oracle/app/oracle/product/19.9.0.0/dbhome_1/assistants/dbca/templates/New_Database.dbt
sysPassword=oracle#123	
systemPassword=oracle#123
runCVUChecks=FALSE
dvConfiguration=false
olsConfiguration=false
datafileJarLocation=
datafileDestination=/oradata/{DB_UNIQUE_NAME}/
storageType=FS
characterSet=AL32UTF8
nationalCharacterSet=UTF8
listeners=LISTENER_B2COM
variables=ORACLE_BASE_HOME=/oracle/app/oracle/product/19.9.0.0/dbhome_1,DB_UNIQUE_NAME=DBACLASS9,ORACLE_BASE=/oracle/app/oracle,PDB_NAME=,DB_NAME=DBACLASS9,ORACLE_HOME=/oracle/app/oracle/product/19.9.0.0/dbhome_1,SID=DBACLASS9
initParams=undo_tablespace=UNDOTBS1,sga_target=10093MB,db_block_size=8192BYTES,log_archive_dest_1='LOCATION=/archive/DBACLASS9',nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=DBACLASS9XDB),diagnostic_dest={ORACLE_BASE},control_files=("/oradata/{DB_UNIQUE_NAME}/control01.ctl", "/oradata/{DB_UNIQUE_NAME}/control02.ctl"),remote_login_passwordfile=EXCLUSIVE,audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,processes=1400,pga_aggregate_target=3365MB,nls_territory=AMERICA,local_listener=LISTENER_DBACLASS9,open_cursors=300,log_archive_format=%t_%s_%r.dbf,compatible=19.0.0,db_name=DBACLASS9,audit_trail=db
sampleSchema=false
memoryPercentage=40
databaseType=MULTIPURPOSE
automaticMemoryManagement=false
totalMemory=0  

Before creating the database, make sure
=======================================
1. Oracle binary/home is already installed
2. Requirement directory structure is already created

  
Now run DBCA in silent mode:

oracle@b2bdev:~$ dbca -silent -createDatabase -responseFile /export/home/oracle/db_create.rsp
[WARNING] [DBT-06208] The 'SYS' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at 
least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06208] The 'SYSTEM' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
Prepare for db operation
5% complete
Creating and starting Oracle instance
6% complete
9% complete
Creating database files
10% complete
14% complete
Creating data dictionary views
15% complete
18% complete
19% complete
22% complete
23% complete
25% complete
27% complete
Oracle JVM
34% complete
41% complete
48% complete
50% complete
Oracle Text
51% complete
54% complete
55% complete
Oracle Multimedia
68% complete
Oracle OLAP
69% complete
70% complete
71% complete
72% complete
73% complete
Oracle Spatial
74% complete
82% complete
Completing Database Creation
85% complete
86% complete
Executing Post Configuration Actions
100% complete

Database creation complete. For details check the logfiles at:
 /oracle/app/oracle/cfgtoollogs/dbca/DBACLASS9.
Database Information:
Global Database Name:DBACLASS9
System Identifier(SID):DBACLASS9

Look at the log file "/oracle/app/oracle/cfgtoollogs/dbca/DBACLASS9/DBACLASS9.log" for further details.

DB has been created successfully
