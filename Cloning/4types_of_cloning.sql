--Cloning

Creating a db from an existing db is called cloning.

Cloning is also creating a duplicate of production db.

We can perform 4 types of cloning in the database in oracle.
1. With User managed Hot backup
2. With User managed Cold backup
3. Using RMAN backup piece
4. Using Active database


1. Cloning using User Managed Hot Backup
----------------------------------------
Source database name = prod
Clone database name  = clone

At Source Database

1. Take online backup of database
export ORACLE_SID=prod
sqlplus / as sysdba
startup
alter database begin backup;
select * from v$backup;
exit;

cd /u01/prod
cp *.log /u01/hotbkp
cp *.dbf /u01/hotbkp

sqlplus / as sysdba
alter database end backup;
select * from v$backup;

2. Take trace (backup) of controlfile
alter database backup controlfile to trace as '/home/oracle/control.sql';

3. create pfile of production database
create pfile from spfile;
shut immediate;
exit;

4. vi control.sql
Remove word REUSE and make it SET
remove word NORESETLOGS and make it RESETLOGS
remove or keep the word ARCHIVELOG depending upon our requirement
change database name from "PROD" to "clone"
change folder name everywhere from 'prod' to 'clone'
:wq


At Clone Terminal

1. Create necessary directory structure for clone database.
mkdir -p clone/arch
mkdir -p /u01/app/oracle/admin/clone/adump

2. configure parameter file
cd $ORACLE_HOME/dbs
cp initprod.ora initclone.ora
vi initclone.ora
change all "prod" to "clone"
:wq

3. Restore the datafiles backup
cd bkp (as our backup is here)
cp *.log /u01/clone
cp *.dbf /u01/clone

4. Start the database in nomount state
export ORACLE_SID=clone
sqlplus / as sysdba
startup nomount;

5. Recreate controlfile
sql>@control.sql
"controlfile created"

6. Recover database
sql> recover database using backup controlfile until cancel;
here one by one apply all archivelog files
apply all 3 redo log files with full path until we get the msg that recovery is done.

Here its better to notedown the current redo log file and the pending archivelogs from production db at the time of backup. We need to apply only those archives and only one current redo log file.

When we say until cancel system will wait for our input until we supply required archives and current online redo log file like below:
/home/oracle/clone/redo01.log
/home/oracle/clone/redo02.log

Once the system receives the proper file it will come out. 

7. Open the database with resetlogs
sql> alter database open resetlogs;

8. check the db and confirm.






2. Cloning using User Managed Cold Backup
-----------------------------------------
primary database = prod
clone database = clone

To do this type of cloning we need cold backup files of a database. We only need online redo log files and datafiles.

export ORACLE_SID=prod

sqlplus / as sysdba
startup

alter database backup controlfile to trace as '/u01/control.sql';

shut immediate;

As the prod database is shutdown, copy all the redo log files and datafiles from prod to coldbkp. We dont need control files here. Control files will be created when we execute the modified trace file.

Take cold backup

cd /u01/prod
cp *.log /u01/coldbkp
cp *.dbf /u01/coldbkp

make necessary directory structure for clone db

mkdir -p clone/arch
mkdir -p /u01/app/oracle/admin/clone/adump

Now copy all the online redo log files and datafiles from the coldbkp folder to clone folder.

cd coldbkp
cp *.log /u01/clone
cp *.dbf /u01/clone

modify our trace file like below

vi control.sql

CREATE CONTROLFILE SET DATABASE "CLONE" RESETLOGS
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  GROUP 1 '/u01/clone/redo01.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 2 '/u01/clone/redo02.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 3 '/u01/clone/redo03.log'  SIZE 50M BLOCKSIZE 512
DATAFILE
  '/u01/clone/system01.dbf',
  '/u01/clone/sysaux01.dbf',
  '/u01/clone/undotbs01.dbf',
  '/u01/clone/users01.dbf'
CHARACTER SET WE8MSWIN1252
;

create the password file

orapwd file=orapwclone password=manager force=y ignorecase=y

create a pfile with one parameter

vi initclone.ora
db_name=clone
:wq

export ORACLE_SID=clone
sqlplus / as sysdba
startup nomount

@control.sql
"control file created."

alter database open resetlogs;

select name, open_mode from v$database;
CLONE     READ WRITE






3. Cloning using RMAN with backup piece (without active db)
-----------------------------------------------------------
In Oracle 10g version or earlier, while duplicating a database using RMAN, we had to connect to the Target database along with the Auxiliary Database. In oracle 11g, there is a new feature available, where in the duplication from the Target Database to the Auxiliary Database can be done using RMAN without connecting to the Target database or to the Catalog Database. Only thing what is required the full backup of the Target database. Below is the details on how to go ahead with duplicating the database without connecting to the Target Database or to the Auxiliary Database.

Steps:
-------
Create the necessary directory structure.

$mkdir -p clone/arch
$mkdir -p /u01/app/oracle/admin/clone/adump

production db name = prod

clone db name = clone

export ORACLE_SID=prod
sqlplus / as sysdba

sql> startup
sql> exit

$rman target / nocatalog
RMAN> backup database;
RMAN> backup archivelog all;
RMAN> backup current controlfile;
RMAN> backup spfile;
(here need to check all 4 are necessary or few can avoided)
RMAN> exit

sqlplus / as sysdba

sql> create pfile from spfile;

cd $ORACLE_HOME/dbs

cp initprod.ora initclone.ora

vi initclone.ora

replace all "prod" with "clone"

:%s/prod/clone/g

set these parameters

db_name='clone'
log_archive_dest_1='location=/u01/clone/arch'

These 2 are clone related parameters to shift dbf and log files to clone folder.

db_file_name_convert='/u01/prod','/u01/clone'
log_file_name_convert='/u01/prod','/u01/clone'


Create password files for both prod and clone

$orapwd file=orapwprod password=manager force=y ignorecase=y
$orapwd file=orapwclone password=manager force=y ignorecase=y


Open another terminal for clone
export ORACLE_SID=clone
sqlplus / as sysdba
startup nomount

Connect the auxiliary instance through RMAN and start the duplication.

The duplication is done by specifying the location of the backup pieces. The command to be used is DUPLICATE DATABASE TO '<auxiliary dbname>' BACKUP LOCATION '<location of the backup pieces on the auxiliary server>'

$rman auxiliary /

RMAN> duplicate database to 'clone' backup location= '/u01/prod/fra/PROD/backupset/2015_12_12'
nofilenamecheck;

Once its over connect to the clone db and check for the data. 






4. Cloning using RMAN with Active Database
------------------------------------------
Steps:
-------
production db name = prod
clone db name = clone

Create the necessary directory structure.

$mkdir -p clone/arch
$mkdir -p /u01/app/oracle/admin/clone/adump

export ORACLE_SID=prod
sqlplus / as sysdba

sql> create pfile from spfile;

cd $ORACLE_HOME/dbs

cp initprod.ora initclone.ora

vi initclone.ora

replace all "prod" with "clone"

:%s/prod/clone/g

set these parameters

db_name='clone'
log_archive_dest_1='location=/u01/clone/arch'

These 2 are clone related parameters to shift dbf and log files to clone folder

db_file_name_convert='/u01/prod','/u01/clone'
log_file_name_convert='/u01/prod','/u01/clone'

Open another terminal for clone
export ORACLE_SID=clone
sqlplus / as sysdba
startup nomount

Create password files for both prod and clone

$orapwd file=orapwprod password=manager force=y ignorecase=y
$orapwd file=orapwclone password=manager force=y ignorecase=y

using netmgr create a new listener for clone
here i gave it a name "LIST_CLONE"

Once created start the listener

$lsnrctl start list_clone

create a tns service called "toclone"

$tnsping toclone
(this we use to connect from target to clone)

keep the target db at mount stage
keep clone db at nomount stage

$rman target / nocatalog auxiliary sys/manager@toclone

RMAN> DUPLICATE TARGET DATABASE TO 'clone' FROM ACTIVE DATABASE;

Connect to the database and check.