db health checkup
  
set ORACLE_HOME=E:\app\baan\product\12.1.0\dbhome_1
set ORACLE_SID=BAANENG
set PATH=E:\app\baan\product\12.1.0\dbhome_1\bin

sqlplus
user_name= sys as sysdba
password= baan,sys,oracle

=====================================
###### db status ###########

set pages 1000 lines 600
col startup_time for a22
col HOST_NAME for a15
col instance_status for a15
col DB_UNIQUE_NAME for a15
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
select d.dbid,i.instance_number,d.DB_UNIQUE_NAME,i.instance_name,i.HOST_NAME,i.startup_time,
i.status instance_status,d.DATABASE_ROLE,d.name db_name,d.open_mode,d.log_mode,d.switchover_status 
from gv$database d, gv$instance i
where i.INST_ID=d.INST_ID order by 2;

=================================================
####### Checking Tablespace ####

SELECT /* + RULE */  df.tablespace_name "Tablespace",
df.bytes / (1024 * 1024) "Size (MB)", SUM(fs.bytes) / (1024 * 1024) "Free (MB)",
Nvl(Round(SUM(fs.bytes) * 100 / df.bytes),1) "% Free",
Round((df.bytes - SUM(fs.bytes)) * 100 / df.bytes) "% Used"
FROM dba_free_space fs,
(SELECT tablespace_name,SUM(bytes) bytes
FROM dba_data_files
GROUP BY tablespace_name) df
WHERE fs.tablespace_name (+)  = df.tablespace_name
GROUP BY df.tablespace_name,df.bytes
UNION ALL
SELECT /* + RULE */ df.tablespace_name tspace,
fs.bytes / (1024 * 1024), SUM(df.bytes_free) / (1024 * 1024),
Nvl(Round((SUM(fs.bytes) - df.bytes_used) * 100 / fs.bytes), 1),
Round((SUM(fs.bytes) - df.bytes_free) * 100 / fs.bytes)
FROM dba_temp_files fs,
(SELECT tablespace_name,bytes_free,bytes_used
 FROM v$temp_space_header
GROUP BY tablespace_name,bytes_free,bytes_used) df
 WHERE fs.tablespace_name (+)  = df.tablespace_name
 GROUP BY df.tablespace_name,fs.bytes,df.bytes_free,df.bytes_used
 ORDER BY 1,4 DESC
/


====================================================
### checking locking- blocking session ###################

select sid, sql_id,event,PROGRAM,state,count(1),BLOCKING_SESSION
from Gv$session
where status='ACTIVE' AND type!='BACKGROUND' and BLOCKING_SESSION is NOT NULL
group by sid,sql_id,event,PROGRAM,state,BLOCKING_SESSION
order by 5 desc;


==============================================================
## Check active sessions ##############

set pagesize 29
set linesize 200
column sid format 9999
column serial# format 999999
column username format A15
column spid format a6
column username format A15
column LogonDate format a12
column schemaname format A8
column osuser format a15
column machine format a25
column terminal format a10
col program for a18
select a.INST_ID,a.sid, a.serial#, b.spid,a.username,a.sql_id,substr(a.program,1,10) Program,to_char(a.logon_time,'DD-MM:HH24:MI') LogonDate, a.osuser, a.machine, a.status
from gv$session a,gv$process b where a.paddr = b.addr and a.status='ACTIVE' AND A.USERNAME IS NOT NULL
order by 6,osuser
/

================================================
######## Temp tablespace utilisation ###########

SELECT A.tablespace_name tablespace, D.mb_total,
SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
D.mb_total-SUM(A.used_blocks * D.block_size) / 1024 / 1024 mb_free, ((SUM(A.used_blocks * D.block_size)/1024/1024)/D.mb_total)*100 Percent_used
FROM gv$sort_segment A,
(SELECT B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
FROM v$tablespace B, v$tempfile C
WHERE B.ts#= C.ts#
GROUP BY B.name, C.block_size) D
WHERE A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

===============================================================
########### FRA usage #############

SELECT NAME,TO_CHAR(SPACE_LIMIT, '999,999,999,999') AS SPACE_LIMIT,
TO_CHAR(SPACE_LIMIT - SPACE_USED + SPACE_RECLAIMABLE,
'999,999,999,999') AS SPACE_AVAILABLE,
ROUND((SPACE_USED - SPACE_RECLAIMABLE)/SPACE_LIMIT * 100, 1)
AS PERCENT_FULL FROM V$RECOVERY_FILE_DEST;

===============================================================

FOR DC :
 
select thread#, max(sequence#) "Last Primary Seq Generated"
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;
 
---------------------------------------------------------------------------------
FOR DR :
 
select thread#, max(sequence#) "Last Standby Seq Received"
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;
 
select thread#, max(sequence#) "Last Standby Seq Applied"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
and val.applied in ('YES','IN-MEMORY')
group by thread# order by 1;

===============================================================
alter system kill session 'SID,Serial#' immediate;
================================================================
