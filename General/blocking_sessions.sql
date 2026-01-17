How to resolve the Blocking Session issue in Oracle

How to identify the blocking and waiting sessions

set lines 200 pages 200
col blocking_status for a130
SELECT DISTINCT S1.USERNAME || '@' || S1.MACHINE
|| ' ( INST=' || S1.INST_ID || ' SID=' || S1.SID || ' ) IS BLOCKING '
|| S2.USERNAME || '@' || S2.MACHINE || ' ( INST=' || S1.INST_ID || ' SID=' || S2.SID || ' ) ' AS BLOCKING_STATUS
FROM GV$LOCK L1, GV$SESSION S1, GV$LOCK L2, GV$SESSION S2
WHERE S1.SID=L1.SID AND S2.SID=L2.SID
AND S1.INST_ID=L1.INST_ID AND S2.INST_ID=L2.INST_ID
AND L1.BLOCK > 0 AND L2.REQUEST > 0
AND L1.ID1 = L2.ID1 AND L1.ID2 = L2.ID2;


We can observed from above output

SID 259 – Blocking session

SID 25 – Waiting (blocked) session

This confirms that SID 259 is holding a lock required by SID 25.




Checking Blocking Session Details
  
SET LINES 300 PAGES 200
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
select sysdate from dual;

col status for a10
col machine for a20
col username for a20
COL PROGRAM FOR A25
COL OSUSER FOR A15
col EVENT for a30
SELECT sid, prev_sql_id, serial#, STATUS, osuser, MACHINE, username, event, sql_id, last_call_et, inst_id, logon_time, program 
FROM gv$session 
WHERE SID IN ('&SID') 
order by logon_time;

Output of SID 259

Output of SID 25

Note : – We have found from above outputs that SID 25 is ACTIVE and Waiting event: 
enq: TX – row lock contention whereas SID 259 is INACTIVE, but still holding the lock.


Finding the SQL Causing the Block
  
set long 99999
select sql_id,sql_fulltext from gv$sql where sql_id IN ('&SQL_ID');

Output of SID 259

Output of SID 25


Checking Table-Level Locks
  
set lines 999 pages 999
column oracle_username format a15;
column os_user_name format a15;
column object_name format a37;
column object_type format a37;
column OBJECT_OWNER format a20;
select a.session_id,a.oracle_username, a.os_user_name, b.owner "OBJECT_OWNER", b.object_name,b.object_type,a.locked_mode from 
(select object_id, SESSION_ID, ORACLE_USERNAME, OS_USER_NAME, LOCKED_MODE from v$locked_object) a, 
(select object_id, owner, object_name,object_type from dba_objects) b
where a.object_id=b.object_id;


How to Resolve the Blocking Session
We have total 3 Options to resolve it which we can share with the application team.

1) Commit (Application Action).

2) Rollback (Application Action).

3) Kill blocking session (DBA Action).

If application team want to kill the session so you can use below command to kill it.

alter system kill session 'SID, SERIAL#' immediate;

