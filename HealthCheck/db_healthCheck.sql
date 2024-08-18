DBs:
====
ps -ef | grep smon
ps -ef | grep pmon


ASM/Cluster:
============
su - grid
. oraenv
+ASM1

ps -ef | grep d.bin
crsctl check crs    --- From all nodes 
crsctl stat res t -init  -- From all nodes
crsctl stat res -t 


Listener:
=========
ps -ef | grep listener
ps -ef | grep tns 

lsnrctl status --- for default listener
lsnrctl status LISTNERE_NAME 


Service name connection:
========================
tnsping [servicename]
sqlplus mallik/mallik@DB12C


Mount point(Standalone):
========================
df -h
--- /u01
--- /
--- /oradata 
--- /oraarch
--- /oraredo 


ASM diskgroup:
==============
. oraenv 
+ASM1
asmcmd -p 
lsdg 
--- +DATA 
--- +RECO


DB Check:
=========
export ORACLE_SID=[service_name]
sqlplus / as sysdba
select instance_name, status from v$instance;
select name, open_mode from v$database;
select max(sequence#) from v$archived_log;
Select instance_name, status, to_char(startup_time,' DD-MON-YY HH24:MI') "Startup Time" from v$instance;

--- INVALID object list
column owner format a15
column object_name format a40
column object_type format a20
select owner, object_name, object_type from dba_objects where status='INVALID' order by object_type,owner,object_name;

--- dba_registry component status
column comp_name format a40
column version format a12
column status format a15
select comp_name,version,status from dba_registry;

--- Unusable Index
set lines 160 pages 200
SELECT owner, index_name, status,tablespace_name
FROM   dba_indexes
WHERE  status = 'UNUSABLE';

--- DB size / growth 
select
( select sum(bytes)/1024/1024/1024 data_size from dba_data_files ) +
( select nvl(sum(bytes),0)/1024/1024/1024 temp_size from dba_temp_files ) +
( select sum(bytes)/1024/1024/1024 redo_size from sys.v_$log ) +
( select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 controlfile_size from v$controlfile) "Size in GB"
from dual;

--- Tablespace size / growth / free space 
select count(*) from dba_tablespaces;
free.sql

--- datafiles
select count(*) from dba_data_files;

Alter and Trace:
================
show parameter dump 
adrci

--- Check for alert log and look for ORA error


Check for RMAN backup status:
=============================
Level 0 
level 1 
--- backup should be succesfull, In case of falure you need to look for rman log and find cause for backup
failure 


DR Sync status:
===============
select instance_name, status from v$instance;
select max(sequence#) from v$log;
select max(sequence#) from v$archived_log;
select * from v$archive_gap;
select sequence#,applied,status from v$archived_log where applied='NO';
select current_scn from v$database; 
