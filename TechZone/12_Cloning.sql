Cloning
=======
User Managed Backup Cloning
---------------------------
Steps:
	At source database site
	1. Take online backup of datafiles database.
	2. Take trace of controlfile
		sql> alter database backup controlfile to trace;
	3. Go to udump directory of the source database.
		$cd prod/udump
		$ls -ltr
	4. copy the last trace file with another name to another location and edit it
		$cp prod_ora_22305.trc ~/bkpctrl.sql
		$vi bkpctrl.sql
		Change
		Reuse	=> set and change the name of database also
		Noresetlogs=> resetlogs
		:wq!  //close the file
	At clone database site
	1. Create necessary directory structure.
		$mkdir -p clone/{data,control,log}
	2. Configure parameter file
	3. Restore the datafiles backup
	4. start the database in nomount state
		sql> startup nomount
	5. Recreate controlfile (run edited trace file)
	     sql> @bkpctrl.sql   //imagine bkpctrl.sql as a script for creating new controlfile
	6. Recover database and open with resetlogs.
	     	sql> recover database using backup controlfile until cancel;
		//apply all archives and specify all redo log files if required.
		sql> alter database open resetlogs;
RMAN Cloning From Active Database
Steps:
	Both side create password file with same password.




Cloning
=======
Creating a db from an existing db is called cloning.
Cloning is also creating a duplicate of production db.

1. Cloning using User Managed Hot Backup
========================================
Source database name 		= prod
Clone database name   		= clone

At Source Database
1. Take online backup of database
export ORACLE_SID=prod
sqlplus / as sysdba
startup
alter database begin backup;
select * from v$backup;
exit;

At Clone Terminal
1. Create necessary directory structure for clone database.
mkdir -p /u01/clone/arch
mkdir -p /u01/app/oracle/admin/clone/adump

cd /u01/prod
cp -v *.log /u01/clone
cp -v *.dbf /u01/clone

sqlplus / as sysdba
alter database end backup;
select * from v$backup;

2. Take trace (backup) of controlfile
alter database backup controlfile to trace as '/u01/control.sql';

3. create pfile of production database
create pfile from spfile;
shut immediate;
exit;

4. vi control.sql
Remove word REUSE and make it SET
change database name from "PROD" to "clone"
remove word NORESETLOGS and make it RESETLOGS
remove or keep the word ARCHIVELOG depending upon our requirement
change folder name everywhere from 'prod' to 'clone'
:wq

5. configure parameter file
cd $ORACLE_HOME/dbs
cp initprod.ora initclone.ora
vi initclone.ora
change all "prod" to "clone"
:wq

6. Start the clone database in nomount state
export ORACLE_SID=clone
sqlplus / as sysdba
startup nomount;

7. Recreate controlfile
sql>@control.sql
"controlfile created"

8. Recover database
sql> recover database using backup controlfile until cancel;
here one by one apply all archivelog files
apply all 3 redo log files with full path until we get the msg that recovery is done.

Here its better to notedown the current redo log file and the pending archivelogs from 
production db at the time of backup. We need to apply only those archives and only one current redo log file.

When we say until cancel system will wait for our input until we supply required archives and current online redo log file like below:
/u01/clone/redo01.log
/u01/clone/redo02.log

Once the system receives the proper file it will come out. 

9. Open the database with resetlogs
sql> alter database open resetlogs;

10. check the db and confirm.



2. Cloning using User Managed Cold Backup
=========================================
primary database 	= prod
clone database 	= clone

To do this type of cloning we need cold backup files of a database. We only need online redo log files and datafiles. Controlfiles will be created when we execute control.sql file.
export ORACLE_SID=prod
sqlplus / as sysdba
startup
alter database backup controlfile to trace as '/u01/control1.sql';
shut immediate;

As the prod database is shutdown, copy all the redo log files and datafiles from prod to coldbkp. 

make necessary directory structure for clone db
cd /u01
mkdir -p /u01/clone/arch
mkdir -p /u01/app/oracle/admin/clone/adump
Take cold backup
cd /u01/prod
cp -v *.log /u01/clone
cp -v *.dbf /u01/clone

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
  '/ u01/clone/sysaux01.dbf',
  '/ u01/clone/undotbs01.dbf',
  '/ u01/clone/users01.dbf'
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
select name,open_mode from v$database;
CLONE READ WRITE

3. Cloning using RMAN with backup piece (without active db)
In Oracle 10g version or earlier, while duplicating a database using RMAN, we had to connect to the Target database along with the Auxiliary Database. In oracle 11g, there is a new feature available; where in the duplication from the Target Database to the Auxiliary Database can be done using RMAN without connecting to the Target database or to the Catalog Database. Only thing what is required the full backup of the Target database. Below are the details on how to go ahead with duplicating the database without connecting to the Target Database or to the Auxiliary Database.
Steps:
-------
Create the necessary directory structure.
cd /u01
$mkdir -p /u01/clone/arch
$mkdir -p /u01/app/oracle/admin/clone/adump

production db name 	= prod
clone db name 		= clone

export ORACLE_SID=prod
sqlplus / as sysdba
sql> startup	
sql> exit

make a folder in /u01 to backup all the database
mkdir -p /u01/bkp
mkdir /u01/prod/arch
make sure the database in archivelog mode so that we can take backup pieces.
sqlplus / as sysdba
archive log list;
alter system set log_archive_dest_1='location=/u01/prod/arch' scope=spfile;
shut immediate;
startup mount;
alter database archivelog;
alter database open;

$rman target / nocatalog
run{
allocate channel c1 device type disk format '/u01/bkp/rmanbackup%U.bkp';
backup database;
backup archivelog all;
backup current controlfile;
backup spfile;}
(here need to check all 4 are necessary or few can avoided)
RMAN> exit

sqlplus / as sysdba
sql> create pfile from spfile;
exit
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

Create password files for both prod and clone
$orapwd file=orapwprod password=manager force=y ignorecase=y
$orapwd file=orapwclone password=manager force=y ignorecase=y

Open another terminal for clone
export ORACLE_SID=clone
sqlplus / as sysdba
startup nomount
exit

Connect the auxiliary instance through RMAN and start the duplication.
The duplication is done by specifying the location of the backup pieces. The command to be used is DUPLICATE DATABASE TO ‘<auxiliary dbname>’ BACKUP LOCATION ‘<location of the backup pieces on the auxiliary server>’
$rman auxiliary /
duplicate database to 'clone' backup location='/u01/bkp' nofilenamecheck;

Once it’s over connect to the clone db and check for the data. 









4. Cloning using RMAN with Active Database
Steps:
-------
production db name 	= prod
clone db name 		= clone

Create the necessary directory structure.
cd /u01
$mkdir -p /u01/clone/arch
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

At prod side
$rman target / nocatalog auxiliary sys/manager@toclone
RMAN> DUPLICATE TARGET DATABASE TO 'clone' FROM ACTIVE DATABASE;

Connect to the database and check.
