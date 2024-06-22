--Troubleshooting Flow For Long Running Queries

2. Logon to Database

select name,open_mode from v$database;

3. Find Long Running Sessions

/*************************************************************************
Check the ALL Active/Inactive session
**************************************************************************/

set linesize 750 pages 9999
column box format a30
column spid format a10
column username format a30 
column program format a30
column os_user format a20
col LOGON_TIME for a20  

select b.inst_id,b.sid,b.serial#,a.spid, substr(b.machine,1,30) box,to_char (b.logon_time, 'dd-mon-yyyy hh24:mi:ss') logon_time,
 substr(b.username,1,30) username,
 substr(b.osuser,1,20) os_user,
 substr(b.program,1,30) program,status,b.last_call_et AS last_call_et_secs,b.sql_id 
 from gv$session b,gv$process a 
 where b.paddr = a.addr 
 and a.inst_id = b.inst_id  
 and type='USER'
 order by logon_time;

/*************************************************************************
Check the all Active session
**************************************************************************/

set linesize 750 pages 9999
column box format a30
column spid format a10
column username format a30 
column program format a30
column os_user format a20
col LOGON_TIME for a20  

select b.inst_id,b.sid,b.serial#,a.spid, substr(b.machine,1,30) box,to_char (b.logon_time, 'dd-mon-yyyy hh24:mi:ss') logon_time,
 substr(b.username,1,30) username,
 substr(b.osuser,1,20) os_user,
 substr(b.program,1,30) program,status,b.last_call_et AS last_call_et_secs,b.sql_id 
 from gv$session b,gv$process a 
 where b.paddr = a.addr 
 and a.inst_id = b.inst_id  
 and type='USER' and b.status='ACTIVE'
 order by logon_time;


/*************************************************************************
Check the ALL Active/Inactive sessions by SID
**************************************************************************/

set linesize 750 pages 9999
column box format a30
column spid format a10
column username format a30 
column program format a30
column os_user format a20
col LOGON_TIME for a20  

select b.inst_id,b.sid,b.serial#,a.spid, substr(b.machine,1,30) box,to_char (b.logon_time, 'dd-mon-yyyy hh24:mi:ss') logon_time,
 substr(b.username,1,30) username,
 substr(b.osuser,1,20) os_user,
 substr(b.program,1,30) program,status,b.last_call_et AS last_call_et_secs,b.sql_id 
 from gv$session b,gv$process a 
 where b.paddr = a.addr 
 and a.inst_id = b.inst_id  
 and type='USER' and b.SID='&SID'
-- and b.status='ACTIVE'
-- and b.status='INACTIVE'
 order by logon_time;

/*************************************************************************
Check the ALL Active/Inactive sessions by Username
**************************************************************************/

set linesize 750 pages 9999
column box format a30
column spid format a10
column username format a30 
column program format a30
column os_user format a20
col LOGON_TIME for a20  

select b.inst_id,b.sid,b.serial#,a.spid, substr(b.machine,1,30) box,to_char (b.logon_time, 'dd-mon-yyyy hh24:mi:ss') logon_time,
 substr(b.username,1,30) username,
 substr(b.osuser,1,20) os_user,
 substr(b.program,1,30) program,status,b.last_call_et AS last_call_et_secs,b.sql_id 
 from gv$session b,gv$process a 
 where b.paddr = a.addr 
 and a.inst_id = b.inst_id  
 and type='USER' and b.username='&username'
-- and b.status='ACTIVE'
-- and b.status='INACTIVE'
 order by logon_time;


/*************************************************************************
SQL Monitor
**************************************************************************/
set lines 1000 pages 9999 
column sid format 9999 
column serial for 999999
column status format a15
column username format a10 
column sql_text format a80
column module format a30
col program for a30
col SQL_EXEC_START for a20

SELECT * FROM
       (SELECT status,inst_id,sid,SESSION_SERIAL# as Serial,username,sql_id,SQL_PLAN_HASH_VALUE,
     MODULE,program,
         TO_CHAR(sql_exec_start,'dd-mon-yyyy hh24:mi:ss') AS sql_exec_start,
         ROUND(elapsed_time/1000000)                      AS "Elapsed (s)",
         ROUND(cpu_time    /1000000)                      AS "CPU (s)",
         substr(sql_text,1,30) sql_text
       FROM gv$sql_monitor where status='EXECUTING' and module not like '%emagent%' 
       ORDER BY sql_exec_start  desc
       );

/*************************************************************************
---- Sql-Monitor report for a sql_id         ( Like OEM report)
**************************************************************************/
column text_line format a254
set lines 750 pages 9999
set long 20000 longchunksize 20000
select 
 dbms_sqltune.report_sql_monitor_list() text_line 
from dual;

select 
 dbms_sqltune.report_sql_monitor() text_line 
from dual;


4. Blocking sessions

**** To find Blocking GOOD query 

set lines 750 pages 9999
col blocking_status for a100 
 select s1.inst_id,s2.inst_id,s1.username || '@' || s1.machine
 || ' ( SID=' || s1.sid || ' )  is blocking '
 || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
  from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid and s1.inst_id=l1.inst_id and s2.inst_id=l2.inst_id
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2
order by s1.inst_id;

**** Check who is blocking who in RAC, including objects

SELECT DECODE(request,0,'Holder: ','Waiter: ') || gv$lock.sid sess, machine, do.object_name as locked_object,id1, id2, lmode, request, gv$lock.type
FROM gv$lock join gv$session on gv$lock.sid=gv$session.sid and gv$lock.inst_id=gv$session.inst_id
join gv$locked_object lo on gv$lock.SID = lo.SESSION_ID and gv$lock.inst_id=lo.inst_id
join dba_objects do on lo.OBJECT_ID = do.OBJECT_ID 
WHERE (id1, id2, gv$lock.type) IN (
  SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;


5. Kill Sessions

select 'alter system kill session ' || '''' || sid || ',' || serial# ||',@'|| inst_id || '''' || ' immediate;' from gv$session where sid='&sid';


6. SQL History

set lines 1000 pages 9999
COL instance_number FOR 9999 HEA 'Inst';
COL end_time HEA 'End Time';
COL plan_hash_value HEA 'Plan|Hash Value';
COL executions_total FOR 999,999 HEA 'Execs|Total';
COL rows_per_exec HEA 'Rows Per Exec';
COL et_secs_per_exec HEA 'Elap Secs|Per Exec';
COL cpu_secs_per_exec HEA 'CPU Secs|Per Exec';
COL io_secs_per_exec HEA 'IO Secs|Per Exec';
COL cl_secs_per_exec HEA 'Clus Secs|Per Exec';
COL ap_secs_per_exec HEA 'App Secs|Per Exec';
COL cc_secs_per_exec HEA 'Conc Secs|Per Exec';
COL pl_secs_per_exec HEA 'PLSQL Secs|Per Exec';
COL ja_secs_per_exec HEA 'Java Secs|Per Exec';
SELECT 'gv$dba_hist_sqlstat' source,h.instance_number,
       TO_CHAR(CAST(s.begin_interval_time AS DATE), 'DD-MM-YYYY HH24:MI') snap_time,
       TO_CHAR(CAST(s.end_interval_time AS DATE), 'DD-MM-YYYY HH24:MI') end_time,
       h.sql_id,
       h.plan_hash_value, 
       h.executions_total,
       TO_CHAR(ROUND(h.rows_processed_total / h.executions_total), '999,999,999,999') rows_per_exec,
       TO_CHAR(ROUND(h.elapsed_time_total / h.executions_total / 1e6, 3), '999,990.000') et_secs_per_exec,
       TO_CHAR(ROUND(h.cpu_time_total / h.executions_total / 1e6, 3), '999,990.000') cpu_secs_per_exec,
       TO_CHAR(ROUND(h.iowait_total / h.executions_total / 1e6, 3), '999,990.000') io_secs_per_exec,
       TO_CHAR(ROUND(h.clwait_total / h.executions_total / 1e6, 3), '999,990.000') cl_secs_per_exec,
       TO_CHAR(ROUND(h.apwait_total / h.executions_total / 1e6, 3), '999,990.000') ap_secs_per_exec,
       TO_CHAR(ROUND(h.ccwait_total / h.executions_total / 1e6, 3), '999,990.000') cc_secs_per_exec,
       TO_CHAR(ROUND(h.plsexec_time_total / h.executions_total / 1e6, 3), '999,990.000') pl_secs_per_exec,
       TO_CHAR(ROUND(h.javexec_time_total / h.executions_total / 1e6, 3), '999,990.000') ja_secs_per_exec
  FROM dba_hist_sqlstat h, 
       dba_hist_snapshot s
 WHERE h.sql_id = '&sql_id'
   AND h.executions_total > 0 
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
UNION ALL  
SELECT 'gv$sqlarea_plan_hash' source,h.inst_id, 
       TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI') snap_time,
       TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI') end_time,
       h.sql_id,
       h.plan_hash_value, 
       h.executions,
       TO_CHAR(ROUND(h.rows_processed / h.executions), '999,999,999,999') rows_per_exec,
       TO_CHAR(ROUND(h.elapsed_time / h.executions / 1e6, 3), '999,990.000') et_secs_per_exec,
       TO_CHAR(ROUND(h.cpu_time / h.executions / 1e6, 3), '999,990.000') cpu_secs_per_exec,
       TO_CHAR(ROUND(h.USER_IO_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') io_secs_per_exec,
       TO_CHAR(ROUND(h.CLUSTER_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') cl_secs_per_exec,
       TO_CHAR(ROUND(h.APPLICATION_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') ap_secs_per_exec,
       TO_CHAR(ROUND(h.CLUSTER_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') cc_secs_per_exec,
       TO_CHAR(ROUND(h.PLSQL_EXEC_TIME / h.executions / 1e6, 3), '999,990.000') pl_secs_per_exec,
       TO_CHAR(ROUND(h.JAVA_EXEC_TIME / h.executions / 1e6, 3), '999,990.000') ja_secs_per_exec
  FROM gv$sqlarea_plan_hash h 
 WHERE h.sql_id = '&sql_id'
   AND h.executions > 0 
order by source ;


7. Find Force Matching Signature

col exact_matching_signature for 99999999999999999999999999
col sql_text for a50
set long 20000
set  lines 750 pages 9999
select sql_id, exact_matching_signature, force_matching_signature, SQL_TEXT from v$sqlarea where sql_id='&sql_id';
UNION ALL
select sql_id,force_matching_signature,SQL_TEXT from dba_hist_sqltext where sql_id='&sql_id'
/

-- If you want to find Bind variable for SQL_ID

col VALUE_STRING for a50  
SELECT NAME,POSITION,DATATYPE_STRING,VALUE_STRING FROM gv$sql_bind_capture WHERE sql_id='&sql_id';


8. SQL Tuning Advisor

http://www.br8dba.com/sql-tuning-advisor-manually/


9. SQLT

http://www.br8dba.com/sqlt/


10. SQL Health Check

SQL Tuning Health-Check Script (SQLHC) (Doc ID 1366133.1)


11. SQL Plan Flip

set lines 1000 pages 9999
COL instance_number FOR 9999 HEA 'Inst';
COL end_time HEA 'End Time';
COL plan_hash_value HEA 'Plan|Hash Value';
COL executions_total FOR 999,999 HEA 'Execs|Total';
COL rows_per_exec HEA 'Rows Per Exec';
COL et_secs_per_exec HEA 'Elap Secs|Per Exec';
COL cpu_secs_per_exec HEA 'CPU Secs|Per Exec';
COL io_secs_per_exec HEA 'IO Secs|Per Exec';
COL cl_secs_per_exec HEA 'Clus Secs|Per Exec';
COL ap_secs_per_exec HEA 'App Secs|Per Exec';
COL cc_secs_per_exec HEA 'Conc Secs|Per Exec';
COL pl_secs_per_exec HEA 'PLSQL Secs|Per Exec';
COL ja_secs_per_exec HEA 'Java Secs|Per Exec';
SELECT 'gv$dba_hist_sqlstat' source,h.instance_number,
       TO_CHAR(CAST(s.begin_interval_time AS DATE), 'DD-MM-YYYY HH24:MI') snap_time,
       TO_CHAR(CAST(s.end_interval_time AS DATE), 'DD-MM-YYYY HH24:MI') end_time,
       h.sql_id,
       h.plan_hash_value, 
       h.executions_total,
       TO_CHAR(ROUND(h.rows_processed_total / h.executions_total), '999,999,999,999') rows_per_exec,
       TO_CHAR(ROUND(h.elapsed_time_total / h.executions_total / 1e6, 3), '999,990.000') et_secs_per_exec,
       TO_CHAR(ROUND(h.cpu_time_total / h.executions_total / 1e6, 3), '999,990.000') cpu_secs_per_exec,
       TO_CHAR(ROUND(h.iowait_total / h.executions_total / 1e6, 3), '999,990.000') io_secs_per_exec,
       TO_CHAR(ROUND(h.clwait_total / h.executions_total / 1e6, 3), '999,990.000') cl_secs_per_exec,
       TO_CHAR(ROUND(h.apwait_total / h.executions_total / 1e6, 3), '999,990.000') ap_secs_per_exec,
       TO_CHAR(ROUND(h.ccwait_total / h.executions_total / 1e6, 3), '999,990.000') cc_secs_per_exec,
       TO_CHAR(ROUND(h.plsexec_time_total / h.executions_total / 1e6, 3), '999,990.000') pl_secs_per_exec,
       TO_CHAR(ROUND(h.javexec_time_total / h.executions_total / 1e6, 3), '999,990.000') ja_secs_per_exec
  FROM dba_hist_sqlstat h, 
       dba_hist_snapshot s
 WHERE h.sql_id = '&sql_id'
   AND h.executions_total > 0 
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
UNION ALL  
SELECT 'gv$sqlarea_plan_hash' source,h.inst_id, 
       TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI') snap_time,
       TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI') end_time,
       h.sql_id,
       h.plan_hash_value, 
       h.executions,
       TO_CHAR(ROUND(h.rows_processed / h.executions), '999,999,999,999') rows_per_exec,
       TO_CHAR(ROUND(h.elapsed_time / h.executions / 1e6, 3), '999,990.000') et_secs_per_exec,
       TO_CHAR(ROUND(h.cpu_time / h.executions / 1e6, 3), '999,990.000') cpu_secs_per_exec,
       TO_CHAR(ROUND(h.USER_IO_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') io_secs_per_exec,
       TO_CHAR(ROUND(h.CLUSTER_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') cl_secs_per_exec,
       TO_CHAR(ROUND(h.APPLICATION_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') ap_secs_per_exec,
       TO_CHAR(ROUND(h.CLUSTER_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') cc_secs_per_exec,
       TO_CHAR(ROUND(h.PLSQL_EXEC_TIME / h.executions / 1e6, 3), '999,990.000') pl_secs_per_exec,
       TO_CHAR(ROUND(h.JAVA_EXEC_TIME / h.executions / 1e6, 3), '999,990.000') ja_secs_per_exec
  FROM gv$sqlarea_plan_hash h 
 WHERE h.sql_id = '&sql_id'
   AND h.executions > 0 
order by source ;


12. Find Stale Stats

http://www.br8dba.com/statistics/

exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;
select OWNER,TABLE_NAME,LAST_ANALYZED,STALE_STATS from DBA_TAB_STATISTICS where STALE_STATS='YES' and OWNER='&owner;

*** statistics of objects of a specific sql id 

set lines 300 set pages 300
col table_name for a40
col owner for a30 
select distinct owner, table_name, STALE_STATS, last_analyzed, stattype_locked
  from dba_tab_statistics
  where (owner, table_name) in
  (select distinct owner, table_name
          from dba_tables
          where ( table_name)
          in ( select object_name
                  from gv$sql_plan
                  where upper(sql_id) = upper('&sql_id') and object_name is not null))
  --and STALE_STATS='YES'
/


13. Gather Stats

http://www.br8dba.com/statistics/
http://www.br8dba.com/oracle-histograms/


14. PIN Optimal Plan

-- Run below script, you can download this script from SQLT
-- Reference: http://www.br8dba.com/how-to-create-custom-sql-profile/
@coe_xfr_sql_monitor.sql <sql_id> <plan_hash_value> -- to create SQL profile
The coe_xfr_sql_profile.sql script would create another sql file, which should be run to create manual sql profile for the sql 
The new sql file created.


ls -ltr coe_xfr_sql_profile_<sql_id>_<plan_hash_value>.sql
cat coe_xfr_sql_profile_<sql_id>_<plan_hash_value>.sql

@coe_xfr_sql_profile_<sql_id>_<plan_hash_value>.sql


15. Find Fragmentation

*** Table Fragmentation

select 
   table_name,round((blocks*8),2) "size (kb)" , 
   round((num_rows*avg_row_len/1024),2) "actual_data (kb)",
   (round((blocks*8),2) - round((num_rows*avg_row_len/1024),2)) "wasted_space (kb)"
from 
   dba_tables
where  owner='&OWNER' and table_name='&TABLE_NAME' and 
   (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 4 desc;


16. De-Fragmentation

*** There are many methods.

Option 1: Shrink command

alter table  enable row movement;
/*
Using the enable row movement clause can reduce the clustering_factor for a primary access index, causing excessive I/O.  Oracle introduced the sorted gash cluster as a way to keep an index in-order with the table rows, a technique that greatly reduces I/O for common queries. 
Beware that using "enable row movement" can cause Oracle to move rows to discontinuous data blocks, causing a performance problem.  Remember, the physical placement of rows on data blocks can still make a huge difference in query performance. 
*/
alter table  shrink space compact;
alter table  shrink space cascade;

http://www.dba-oracle.com/t_enable_row_movement.htm

Option 2: Table move

Alter table move - The alter table xxx move command moves rows down into un-used space and adjusts the HWM but does not adjust the segments extents, and the table size remains the same.  The alter table move syntax also preserves the index and constraint definitions.

ALTER TABLE <table_name>  MOVE;

Option 3: EXPORT / IMPORT

** EXPORT
** DROP ALL RESPECTIVE OBJECTS
** IMPORT FROM EXPORT BACKUP


Option 4: EXPORT / IMPORT WITH TABLE_EXISTS_ACTION=REPLACE

** EXPORT
** IMPORT USING TABLE_EXISTS_ACTION=REPLACE

Option 5: Other methods
