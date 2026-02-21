

-- Find all blocked sessions and who is blocking them
select sid,blocking_session,username,sql_id,event,machine,osuser,program,last_call_et from v$session where blocking_session > 0;

select * from dba_blockers
select * from dba_waiters

-- Find what the blocking session is doing
select sid,blocking_session,username,sql_id,event,state,machine,osuser,program,last_call_et from v$session where sid=746 ;

-- Find the blocked objects
select owner,object_name,object_type from dba_objects where object_id in (select object_id from v$locked_object where session_id=271 and locked_mode =3);


-- Friendly query for who is blocking who
-- Mostly for versions before v$session had blocking_session column
select s1.inst_id,s2.inst_id,s1.username || '@' || s1.machine
 || ' ( SID=' || s1.sid || ' )  is blocking '
 || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
  from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid and s1.inst_id=l1.inst_id and s2.inst_id=l2.inst_id
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2
order by s1.inst_id;


-- find blocking sessions that were blocking for more than 15 minutes + objects and sql
select s.SID,p.SPID,s.machine,s.username,CTIME/60 as minutes_locking, do.object_name as locked_object, q.sql_text
from v$lock l
join v$session s on l.sid=s.sid
join v$process p on p.addr = s.paddr
join v$locked_object lo on l.SID = lo.SESSION_ID
join dba_objects do on lo.OBJECT_ID = do.OBJECT_ID 
join v$sqlarea q on  s.sql_hash_value = q.hash_value and s.sql_address = q.address
where block=1 and ctime/60>15

-- Check who is blocking who in RAC
SELECT DECODE(request,0,'Holder: ','Waiter: ') || sid sess, id1, id2, lmode, request, type
FROM gv$lock
WHERE (id1, id2, type) IN (
  SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;

-- Check who is blocking who in RAC, including objects
SELECT DECODE(request,0,'Holder: ','Waiter: ') || gv$lock.sid sess, machine, do.object_name as locked_object,id1, id2, lmode, request, gv$lock.type
FROM gv$lock join gv$session on gv$lock.sid=gv$session.sid and gv$lock.inst_id=gv$session.inst_id
join gv$locked_object lo on gv$lock.SID = lo.SESSION_ID and gv$lock.inst_id=lo.inst_id
join dba_objects do on lo.OBJECT_ID = do.OBJECT_ID 
WHERE (id1, id2, gv$lock.type) IN (
  SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;




-- Who is blocking who, with some decoding
select	sn.USERNAME,
	m.SID,
	sn.SERIAL#,
	m.TYPE,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_type,
	decode(REQUEST,
		0, 'None', 
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)', 
		4, 'Share', 
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_requested,
	m.ID1,
	m.ID2,
	t.SQL_TEXT
from 	v$session sn, 
	v$lock m , 
	v$sqltext t
where 	t.ADDRESS = sn.SQL_ADDRESS 
and 	t.HASH_VALUE = sn.SQL_HASH_VALUE 
and 	((sn.SID = m.SID and m.REQUEST != 0) 
or 	(sn.SID = m.SID and m.REQUEST = 0 and LMODE != 4 and (ID1, ID2) in
        (select s.ID1, s.ID2 
         from 	v$lock S 
         where 	REQUEST != 0 
         and 	s.ID1 = m.ID1 
         and 	s.ID2 = m.ID2)))
order by sn.USERNAME, sn.SID, t.PIECE

-- Who is blocking who, with some decoding
select	OS_USER_NAME os_user,
	PROCESS os_pid,
	ORACLE_USERNAME oracle_user,
	l.SID oracle_id,
	decode(TYPE,
		'MR', 'Media Recovery',
		'RT', 'Redo Thread',
		'UN', 'User Name',
		'TX', 'Transaction',
		'TM', 'DML',
		'UL', 'PL/SQL User Lock',
		'DX', 'Distributed Xaction',
		'CF', 'Control File',
		'IS', 'Instance State',
		'FS', 'File Set',
		'IR', 'Instance Recovery',
		'ST', 'Disk Space Transaction',
		'TS', 'Temp Segment',
		'IV', 'Library Cache Invalidation',
		'LS', 'Log Start or Switch',
		'RW', 'Row Wait',
		'SQ', 'Sequence Number',
		'TE', 'Extend Table',
		'TT', 'Temp Table', type) lock_type,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', lmode) lock_held,
	decode(REQUEST,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', request) lock_requested,
	decode(BLOCK,
		0, 'Not Blocking',
		1, 'Blocking',
		2, 'Global', block) status,
	OWNER,
	OBJECT_NAME
from	v$locked_object lo,
	dba_objects do,
	v$lock l
where 	lo.OBJECT_ID = do.OBJECT_ID
AND     l.SID = lo.SESSION_ID
and block=1













tfsclock.sql
============
SET ECHO off 
REM NAME:   TFSCLOCK.SQL 
REM USAGE:"@path/tfsclock" 
REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM    SELECT on V_$LOCK, V_$SESSION, SYS.USER$, SYS.OBJ$ 
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    The following locking information script provides fully DECODED 
REM    information regarding the locks currently held in the database. 
REM    The report generated is fairly complex and difficult to read, 
REM    but has considerable detail. 
REM 
REM    The TFTS series contains scripts to provide (less detailed) lock  
REM    information in a formats which are somewhat less difficult to read: 
REM    TFSMLOCK.SQL and TFSLLOCK.SQL. 
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM    Too complex to show a representative sample here 
REM  
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only. It is NOT  
REM    supported by Oracle World Wide Technical Support. 
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially. 
REM ------------------------------------------------------------------------ 
REM 

set lines 200 
set pagesize 66 
break on Kill on sid on  username on terminal 
column Kill heading 'Kill String' format a13 
column res heading 'Resource Type' format 999 
column id1 format 9999990 
column id2 format 9999990 
column locking heading 'Lock Held/Lock Requested' format a40 
column lmode heading 'Lock Held' format a20 
column request heading 'Lock Requested' format a20 
column serial# format 99999 
column username  format a10  heading "Username" 
column terminal heading Term format a6 
column tab format a30 heading "Table Name" 
column owner format a9 
column LAddr heading "ID1 - ID2" format a18 
column Lockt heading "Lock Type" format a40 
column command format a25 
column sid format 990 

select 
nvl(S.USERNAME,'Internal') username, 
        L.SID, 
        nvl(S.TERMINAL,'None') terminal, 
        decode(command, 
0,'None',decode(l.id2,0,U1.NAME||'.'||substr(T1.NAME,1,20),'None')) tab, 
decode(command, 
0,'BACKGROUND', 
1,'Create Table', 
2,'INSERT', 
3,'SELECT', 
4,'CREATE CLUSTER', 
5,'ALTER CLUSTER', 
6,'UPDATE', 
7,'DELETE', 
8,'DROP', 
9,'CREATE INDEX', 
10,'DROP INDEX', 
11,'ALTER INDEX', 
12,'DROP TABLE', 
13,'CREATE SEQUENCE', 
14,'ALTER SEQUENCE', 
15,'ALTER TABLE', 
16,'DROP SEQUENCE', 
17,'GRANT', 
18,'REVOKE', 
19,'CREATE SYNONYM', 
20,'DROP SYNONYM', 
21,'CREATE VIEW', 
22,'DROP VIEW', 
23,'VALIDATE INDEX', 
24,'CREATE PROCEDURE', 
25,'ALTER PROCEDURE', 
26,'LOCK TABLE', 
27,'NO OPERATION', 
28,'RENAME', 
29,'COMMENT', 
30,'AUDIT', 
31,'NOAUDIT', 
32,'CREATE EXTERNAL DATABASE', 
33,'DROP EXTERNAL DATABASE', 
34,'CREATE DATABASE', 
35,'ALTER DATABASE', 
36,'CREATE ROLLBACK SEGMENT', 
37,'ALTER ROLLBACK SEGMENT', 
38,'DROP ROLLBACK SEGMENT', 
39,'CREATE TABLESPACE', 
40,'ALTER TABLESPACE', 
41,'DROP TABLESPACE', 
42,'ALTER SESSION', 
43,'ALTER USER', 
44,'COMMIT', 
45,'ROLLBACK', 
46,'SAVEPOINT', 
47,'PL/SQL EXECUTE', 
48,'SET TRANSACTION', 
49,'ALTER SYSTEM SWITCH LOG', 
50,'EXPLAIN', 
51,'CREATE USER', 
52,'CREATE ROLE', 
53,'DROP USER', 
54,'DROP ROLE', 
55,'SET ROLE', 
56,'CREATE SCHEMA', 
57,'CREATE CONTROL FILE', 
58,'ALTER TRACING', 
59,'CREATE TRIGGER', 
60,'ALTER TRIGGER', 
61,'DROP TRIGGER', 
62,'ANALYZE TABLE', 
63,'ANALYZE INDEX', 
64,'ANALYZE CLUSTER', 
65,'CREATE PROFILE', 
66,'DROP PROFILE', 
67,'ALTER PROFILE', 
68,'DROP PROCEDURE', 
69,'DROP PROCEDURE',
70,'ALTER RESOURCE COST', 
71,'CREATE SNAPSHOT LOG', 
72,'ALTER SNAPSHOT LOG', 
73,'DROP SNAPSHOT LOG', 
74,'CREATE SNAPSHOT', 
75,'ALTER SNAPSHOT', 
76,'DROP SNAPSHOT', 
79,'ALTER ROLE',
85,'TRUNCATE TABLE', 
86,'TRUNCATE CLUSTER', 
87,'-', 
88,'ALTER VIEW', 
89,'-', 
90,'-', 
91,'CREATE FUNCTION', 
92,'ALTER FUNCTION', 
93,'DROP FUNCTION', 
94,'CREATE PACKAGE', 
95,'ALTER PACKAGE', 
96,'DROP PACKAGE', 
97,'CREATE PACKAGE BODY', 
98,'ALTER PACKAGE BODY', 
99,'DROP PACKAGE BODY', 
command||' - ???') COMMAND, 
        decode(L.LMODE,1,'No Lock', 
                2,'Row Share', 
                3,'Row Exclusive', 
                4,'Share', 
                5,'Share Row Exclusive', 
                6,'Exclusive','NONE') lmode, 
        decode(L.REQUEST,1,'No Lock', 
                2,'Row Share', 
                3,'Row Exclusive', 
                4,'Share', 
                5,'Share Row Exclusive', 
                6,'Exclusive','NONE') request, 
l.id1||'-'||l.id2 Laddr, 
l.type||' - '|| 
decode(l.type, 
'BL','Buffer hash table instance lock', 
'CF',' Control file schema global enqueue lock', 
'CI','Cross-instance function invocation instance lock',
'CS','Control file schema global enqueue lock', 
'CU','Cursor bind lock',
'DF','Data file instance lock', 
'DL','Direct loader parallel index create',
'DM','Mount/startup db primary/secondary instance lock', 
'DR','Distributed recovery process lock', 
'DX','Distributed transaction entry lock', 
'FI','SGA open-file information lock', 
'FS','File set lock', 
'HW','Space management operations on a specific segment lock',
'IN','Instance number lock',
'IR','Instance recovery serialization global enqueue lock', 
'IS','Instance state lock',
'IV','Library cache invalidation instance lock', 
'JQ','Job queue lock',
'KK','Thread kick lock',
'MB','Master buffer hash table instance lock', 
'MM','Mount definition gloabal enqueue lock', 
'MR','Media recovery lock', 
'PF','Password file lock',
'PI','Parallel operation lock',
'PR','Process startup lock',
'PS','Parallel operation lock',
'RE','USE_ROW_ENQUEUE enforcement lock', 
'RT','Redo thread global enqueue lock', 
'RW','Row wait enqueue lock', 
'SC','System commit number instance lock', 
'SH','System commit number high water mark enqueue lock', 
'SM','SMON lock',
'SN','Sequence number instance lock', 
'SQ','Sequence number enqueue lock', 
'SS','Sort segment lock',
'ST','Space transaction enqueue lock', 
'SV','Sequence number value lock', 
'TA','Generic enqueue lock', 
'TD','DDL enqueue lock', 
'TE','Extend-segment enqueue lock', 
'TM','DML enqueue lock', 
'TO','Temporary Table Object Enqueue', 
'TT','Temporary table enqueue lock', 
'TX','Transaction enqueue lock', 
'UL','User supplied lock', 
'UN','User name lock', 
'US','Undo segment DDL lock',
'WL','Being-written redo log instance lock', 
'WS','Write-atomic-log-switch global enqueue lock', 
'TS',decode(l.id2,0,'Temporary segment enqueue lock (ID2=0)', 
                    'New block allocation enqueue lock (ID2=1)'), 
'LA','Library cache lock instance lock (A=namespace)', 
'LB','Library cache lock instance lock (B=namespace)', 
'LC','Library cache lock instance lock (C=namespace)', 
'LD','Library cache lock instance lock (D=namespace)', 
'LE','Library cache lock instance lock (E=namespace)', 
'LF','Library cache lock instance lock (F=namespace)', 
'LG','Library cache lock instance lock (G=namespace)', 
'LH','Library cache lock instance lock (H=namespace)', 
'LI','Library cache lock instance lock (I=namespace)', 
'LJ','Library cache lock instance lock (J=namespace)', 
'LK','Library cache lock instance lock (K=namespace)', 
'LL','Library cache lock instance lock (L=namespace)', 
'LM','Library cache lock instance lock (M=namespace)', 
'LN','Library cache lock instance lock (N=namespace)', 
'LO','Library cache lock instance lock (O=namespace)', 
'LP','Library cache lock instance lock (P=namespace)', 
'LS','Log start/log switch enqueue lock', 
'PA','Library cache pin instance lock (A=namespace)', 
'PB','Library cache pin instance lock (B=namespace)', 
'PC','Library cache pin instance lock (C=namespace)', 
'PD','Library cache pin instance lock (D=namespace)', 
'PE','Library cache pin instance lock (E=namespace)', 
'PF','Library cache pin instance lock (F=namespace)', 
'PG','Library cache pin instance lock (G=namespace)', 
'PH','Library cache pin instance lock (H=namespace)', 
'PI','Library cache pin instance lock (I=namespace)', 
'PJ','Library cache pin instance lock (J=namespace)', 
'PL','Library cache pin instance lock (K=namespace)', 
'PK','Library cache pin instance lock (L=namespace)', 
'PM','Library cache pin instance lock (M=namespace)', 
'PN','Library cache pin instance lock (N=namespace)', 
'PO','Library cache pin instance lock (O=namespace)', 
'PP','Library cache pin instance lock (P=namespace)', 
'PQ','Library cache pin instance lock (Q=namespace)', 
'PR','Library cache pin instance lock (R=namespace)', 
'PS','Library cache pin instance lock (S=namespace)', 
'PT','Library cache pin instance lock (T=namespace)', 
'PU','Library cache pin instance lock (U=namespace)', 
'PV','Library cache pin instance lock (V=namespace)', 
'PW','Library cache pin instance lock (W=namespace)', 
'PX','Library cache pin instance lock (X=namespace)', 
'PY','Library cache pin instance lock (Y=namespace)', 
'PZ','Library cache pin instance lock (Z=namespace)', 
'QA','Row cache instance lock (A=cache)', 
'QB','Row cache instance lock (B=cache)', 
'QC','Row cache instance lock (C=cache)', 
'QD','Row cache instance lock (D=cache)', 
'QE','Row cache instance lock (E=cache)', 
'QF','Row cache instance lock (F=cache)', 
'QG','Row cache instance lock (G=cache)', 
'QH','Row cache instance lock (H=cache)', 
'QI','Row cache instance lock (I=cache)', 
'QJ','Row cache instance lock (J=cache)', 
'QL','Row cache instance lock (K=cache)', 
'QK','Row cache instance lock (L=cache)', 
'QM','Row cache instance lock (M=cache)', 
'QN','Row cache instance lock (N=cache)', 
'QO','Row cache instance lock (O=cache)', 
'QP','Row cache instance lock (P=cache)', 
'QQ','Row cache instance lock (Q=cache)', 
'QR','Row cache instance lock (R=cache)', 
'QS','Row cache instance lock (S=cache)', 
'QT','Row cache instance lock (T=cache)', 
'QU','Row cache instance lock (U=cache)', 
'QV','Row cache instance lock (V=cache)', 
'QW','Row cache instance lock (W=cache)', 
'QX','Row cache instance lock (X=cache)', 
'QY','Row cache instance lock (Y=cache)', 
'QZ','Row cache instance lock (Z=cache)','????') Lockt 
from    V$LOCK L,  
        V$SESSION S, 
        SYS.USER$ U1, 
        SYS.OBJ$ T1 
where   L.SID = S.SID  
and     T1.OBJ#  = decode(L.ID2,0,L.ID1,1)  
and     U1.USER# = T1.OWNER# 
and     S.TYPE != 'BACKGROUND' 
order by 1,2,5 
/ 