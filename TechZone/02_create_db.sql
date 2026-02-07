MANUAL DATABASE CREATION
========================
1. create necessary directory structure
cd (to go into home directory)
mkdir -p /u01/db/arch
cd db
mkdir diag

2. create a parameter file
initdb.ora
-------------
db_name=test
instance_name=test
control_files='/u01/db/control01.ctl','/u01/db/control02.ctl'
db_block_size=8192
undo_management=auto
undo_tablespace=untotbs1
undo_retention=900
compatible=11.2.0
memory_max_target=400m
memory_target=300m
log_buffer=100
workarea_size_policy=auto
diagnostic_dest='/u01/db/diag'

3. on windows platform create an instance
oradim -new -sid db

4. export the database and startup at nomount stage
set ORACLE_SID=db
sqlplus / as sysdba
startup nomount

5. create the database creation file (save it as crdb.sql)
create database db
user sys identified by manager
user system identified by manager
logfile group 1('/u01/db/redo01.log') size 20m,
	 group 2('/u01/db/redo02.log') size 20m,
	 group 3('/u01/db/redo03.log') size 20m
maxlogfiles 5
maxlogmembers 5
maxloghistory 50
maxdatafiles 100
maxinstances 1
datafile '/u01/db/system01.dbf' size 850m autoextend on
sysaux datafile '/u01/db/sysaux01.dbf' size 850m autoextend on
default tablespace users datafile '/u01/db/users01.dbf' size 50m autoextend on
default temporary tablespace temp tempfile '/u01/db/temp01.dbf' size 50m
undo tablespace untotbs1 datafile '/u01/db/undotbs01.dbf' size 50m;

6. run the above script at database level
sqlplus / as sysdba
startup nomount
@crdb.sql 
database created.

7. create postscript (save it as postscript.sql)
@$ORACLE_HOME/rdbms/admin/catalog.sql
@$ORACLE_HOME/rdbms/admin/catproc.sql
connect system/manager
@$ORACLE_HOME/sqlplus/admin/pupbld.sql

8. run the postscript at database level
@postscript.sql


From SamAlapati Book

CREATE DATABASE prod
USER SYS IDENTIFIED BY sys_password
USER SYSTEM IDENTIFIED BY system_password
LOGFILE GROUP 1 ('/u01/prod/redo01.log') SIZE 100M,
	 GROUP 2 ('/u01/prod/redo02.log') SIZE 100M,
	 GROUP 3 ('/u01/prod/redo03.log') SIZE 100M
MAXLOGFILES 5
MAXLOGMEMBERS 5
MAXLOGHISTORY 1
MAXDATAFILES 300
CHARACTER SET US7ASCII
NATIONAL CHARACTER SET AL16UTF16
EXTENT MANAGEMENT LOCAL
DATAFILE '/u01/prod/system01.dbf' SIZE 500M REUSE
SYSAUX DATAFILE '/u01/prod/sysaux01.dbf' SIZE 325M REUSE
DEFAULT TABLESPACE users
DATAFILE '/u01/prod/users01.dbf'
SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
DEFAULT TEMPORARY TABLESPACE tempts1
TEMPFILE '/u01/prod/temp01.dbf'
SIZE 200M REUSE
UNDO TABLESPACE undotbs
DATAFILE '/u01/prod/undotbs01.dbf'
SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
