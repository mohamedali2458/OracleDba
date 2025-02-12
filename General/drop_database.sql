--RAC database
==============
sqlplus / as sysdba
select name, open_mode from gv$database;
select instance_name, status from gv$instance;

$ORACLE_HOME/bin/srvctl status database -d <dbname>
$ORACLE_HOME/bin/srvctl stop database -d <dbname>
$ORACLE_HOME/bin/srvctl config database -d <dbname>
--here in this result type=RAC or type=SINGLE 
sqlplus / as sysdba
startup nomount;
show parameter cluster_database;
alter system set cluster_database=false scope=spfile;
shudown;
startup mount exclusive restrict;
drop database;

--standalone database
=====================
sqlplus / as sysdba
select name, open_mode from v$database;
select instance_name, status from v$instance;
shutdown immediate;
startup nomount; --unable to drop db
startup mount exclusive; -- unable to drop db
startup mount restrict; --able to drop the database
startup mount exclusive restrict;
drop database;
