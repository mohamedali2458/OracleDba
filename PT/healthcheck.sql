The below-mentioned query can help you to fetch the AWR report:-
SQL> @$ORACLE_HOME/rdbms/admin/awrrpt.sql

Mainly for doing basic health checks, we’ll be performing the below-mentioned steps which applicable for both RAC and standalone database. 

DB uptime
CPU utilization, memory utilization, etc.
Listener status of the database
FRA utilization
Tablespaces utilization
Database status
Blocking sessions.
Longrunning session.

https://dbsguru.com/how-to-perform-a-health-check-of-an-oracle-database/#google_vignette

1. Check the up-time of the server:-
uptime

2. Validate overall CPU, memory, etc. utilization using commands sar & top:
sar 5 5
top

3. Check the listener status:-
ps -eaf | grep tns | egrep -v grep

4. FRA/DISKGROUP utilization if it’s ASM storage:-

SQL> SET LINES 200
COLUMN GROUP_NAME             FORMAT A25           HEAD 'DISK GROUP|NAME'
COLUMN SECTOR_SIZE            FORMAT 99,999        HEAD 'SECTOR|SIZE'
COLUMN BLOCK_SIZE             FORMAT 99,999        HEAD 'BLOCK|SIZE'
COLUMN ALLOCATION_UNIT_SIZE   FORMAT 999,999,999   HEAD 'ALLOCATION|UNIT SIZE'
COLUMN STATE                  FORMAT A11           HEAD 'STATE'
COLUMN TYPE                   FORMAT A6            HEAD 'TYPE'
COLUMN TOTAL_MB               FORMAT 999,999,999   HEAD 'TOTAL SIZE (MB)'
COLUMN USED_MB                FORMAT 999,999,999   HEAD 'USED SIZE (MB)'
COLUMN PCT_USED               FORMAT 999.99        HEAD 'PCT. USED'
 
BREAK ON REPORT ON DISK_GROUP_NAME SKIP 1
 
COMPUTE SUM LABEL "GRAND TOTAL: " OF TOTAL_MB USED_MB ON REPORT
 
SELECT
    NAME                                     GROUP_NAME
  , SECTOR_SIZE                              SECTOR_SIZE
  , BLOCK_SIZE                               BLOCK_SIZE
  , ALLOCATION_UNIT_SIZE                     ALLOCATION_UNIT_SIZE
  , STATE                                    STATE
  , TYPE                                     TYPE
  , TOTAL_MB                                 TOTAL_MB
  , (TOTAL_MB - FREE_MB)                     USED_MB
  , ROUND((1- (FREE_MB / TOTAL_MB))*100, 2)  PCT_USED
FROM  V$ASM_DISKGROUP
WHERE  TOTAL_MB != 0
ORDER BY NAME
/ 

prompt$$$$$$$**Welcome to DBsGuru!**Share Learn Grow**$$$$$$$

5. Check the tablespace utilizations are under threshold or not:-

SQL> SET LINESIZE 200 PAGESIZE 1000
COLUMN TOTAL_BYTES FORMAT 999999999999
COLUMN FREE_BYTES FORMAT 999999999999
SELECT A.TABLESPACE_NAME AS "TABLESPACE",
100-ROUND(DECODE(A.AUTEXT,'YES',(A.MBYTES-A.ABYTES+B.FBYTES)/A.MBYTES*100,
'NO',B.FBYTES/A.ABYTES*100),0) AS "PCT_USED" FROM
(SELECT TABLESPACE_NAME , COUNT(DISTINCT FILE_ID) NUM_FILES,
MAX(AUTOEXTENSIBLE) AUTEXT ,SUM(DECODE(SIGN(MAXBYTES-BYTES), -1, BYTES, MAXBYTES)) MBYTES, SUM(BYTES) ABYTES
FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) A,
(SELECT TABLESPACE_NAME, SUM(BYTES) FBYTES
FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME) B
WHERE A.TABLESPACE_NAME=B.TABLESPACE_NAME(+)
AND 100-ROUND(DECODE(A.AUTEXT,'YES',(A.MBYTES-A.ABYTES+B.FBYTES)/A.MBYTES*100,
'NO',B.FBYTES/A.ABYTES*100),0) >= 1
ORDER BY "PCT_USED" DESC;
prompt$$$$$$$**Welcome to DBsGuru!**Share Learn Grow**$$$$$$$

6. Check the  database status:-

SQL> SELECT NAME, OPEN_MODE, DATABASE_ROLE FROM V$DATABASE;
prompt$$$$$$$**Welcome to DBsGuru!**Share Learn Grow**$$$$$$$
 
For RAC databases
 
SQL> SELECT INST_ID, NAME, OPEN_MODE, DATABASE_ROLE FROM GV$DATABASE;
prompt$$$$$$$**Welcome to DBsGuru!**Share Learn Grow**$$$$$$$

7. Check blocking session if there is any:-
SQL> SELECT BLOCKING_SESSION, SID, SERIAL#, WAIT_CLASS, SECONDS_IN_WAIT FROM V$SESSION
WHERE BLOCKING_SESSION IS NOT NULL ORDER BY BLOCKING_SESSION;
prompt$$$$$$$**Welcome to DBsGuru!**Share Learn Grow**$$$$$$$
 
For RAC databases
 
SQL> SELECT INST_ID, BLOCKING_SESSION, SID, SERIAL#, WAIT_CLASS, SECONDS_IN_WAIT FROM GV$SESSION
WHERE BLOCKING_SESSION IS NOT NULL ORDER BY BLOCKING_SESSION;
prompt$$$$$$$**Welcome to DBsGuru!**Share Learn Grow**$$$$$$$

8. Check Long running session if there is any:-
SELECT SID, SERIAL#,OPNAME, CONTEXT, SOFAR, TOTALWORK,ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE" FROM V$SESSION_LONGOPS WHERE OPNAME NOT LIKE '%aggregate%' AND TOTALWORK != 0 AND SOFAR <> TOTALWORK;
 
For RAC databases
 
SELECT INST_ID,SID, SERIAL#,OPNAME, CONTEXT, SOFAR, TOTALWORK,ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE" FROM GV$SESSION_LONGOPS WHERE OPNAME NOT LIKE '%aggregate%' AND TOTALWORK != 0 AND SOFAR <> TOTALWORK;

