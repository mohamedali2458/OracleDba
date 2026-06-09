--How to check users, roles and privileges in Oracle
--==================================================

--Query to check the granted roles to a user

SELECT *
FROM DBA_ROLE_PRIVS
WHERE GRANTEE = '&USER';

--Query to check privileges granted to a user

SELECT *
FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'USER';

--Privileges granted to a role which is granted to a user

SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE IN
(SELECT granted_role FROM DBA_ROLE_PRIVS WHERE GRANTEE = '&USER') order by 3;

--Query to check if user is having system privileges

SELECT *
FROM DBA_SYS_PRIVS
WHERE GRANTEE = '&USER';

--Query to check permissions granted to a role

select * from ROLE_ROLE_PRIVS where ROLE = '&ROLE_NAME';
select * from ROLE_TAB_PRIVS where ROLE = '&ROLE_NAME';
select * from ROLE_SYS_PRIVS where ROLE = '&ROLE_NAME';














--How to check high resource intensive SQL in Oracle
--==================================================
/*
Database performance is a major concern for a DBA. SQLs are the ones
which needs proper DB management in order to execute well. At times the
application team might tell you that the database is running slow. You can
run below query to get the top 5 resource intensive SQL with SQL ID and
then give it to application team to optimize them.
*/

col Rank for a4
SELECT *
FROM (SELECT RANK () OVER
(PARTITION BY "Snap Day" ORDER BY "Buffer Gets" + "Disk Reads" DESC) AS "Rank", i1.*
FROM (SELECT TO_CHAR (hs.begin_interval_time, 'MM/DD/YY' ) "Snap Day",
SUM (shs.executions_delta) "Execs",
SUM (shs.buffer_gets_delta) "Buffer Gets",
SUM (shs.disk_reads_delta) "Disk Reads",
ROUND ( (SUM (shs.buffer_gets_delta)) / SUM (shs.executions_delta), 1 ) "Gets/Exec",
ROUND ( (SUM (shs.cpu_time_delta) / 1000000) / SUM (shs.executions_delta), 1 ) "CPU/Exec(S)",
ROUND ( (SUM (shs.iowait_delta) / 1000000) / SUM (shs.executions_delta), 1 ) "IO/Exec(S)",
shs.sql_id "Sql id",
REPLACE (CAST (DBMS_LOB.SUBSTR (sht.sql_text, 50) AS VARCHAR (50) ), CHR (10), '' ) "Sql"
FROM dba_hist_sqlstat shs INNER JOIN dba_hist_sqltext sht
ON (sht.sql_id = shs.sql_id)
INNER JOIN dba_hist_snapshot hs
ON (shs.snap_id = hs.snap_id)
HAVING SUM (shs.executions_delta) > 0
GROUP BY shs.sql_id, TO_CHAR (hs.begin_interval_time, 'MM/DD/YY'),
CAST (DBMS_LOB.SUBSTR (sht.sql_text, 50) AS VARCHAR (50) )
ORDER BY "Snap Day" DESC) i1
ORDER BY "Snap Day" DESC)
WHERE "Rank" <= 5 AND "Snap Day" = TO_CHAR (SYSDATE, 'MM/DD/YY');








--How to check execution plan of a query
--======================================
/*
First get the sql ID and then you can use below command to generate
execution plan of a query in oracle*/

SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('2t3nwk8h97vph',0));

/*In case you have more IDs, use below command to supply sql id every time
you run the query*/

SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',0));











--How to backup archivelog for specific sequence RMAN
--===================================================
/*When you issue archive backup commands via RMAN, it will backup all the
archive logs. Sometimes, you might need to backup only a particular
archive log sequence. Below command will help you backup archive logs
between specific sequence*/

RMAN> BACKUP ARCHIVELOG FROM SEQUENCE 288 UNTIL SEQUENCE 388 DELETE INPUT;








--How to check last CPU applied in Oracle
--=======================================
/*
Generally if you have one single database install then checking the
database inventory will give you the latest patch details. But! if we have
multiple database in single oracle home then it might not give correct
results. There might be a chance that one DB is applied with latest patches
and others are not. In such cases, we need to check last CPU applied by
logging into the database using below query:
*/

--Query to Check Last CPU Applied on a Database:
col VERSION for a15;
col COMMENTS for a50;
col ACTION for a10;
set lines 500;
select ACTION,VERSION,COMMENTS,BUNDLE_SERIES from registry$history;

/*
What are Critical Patch Updates (CPUs)?
Critical Patch Updates are sets of patches containing fixes for security
flaws in Oracle products. The Critical Patch Update program (CPU) was
introduced in January 2005 to provide security fixes on a fixed, publicly
available schedule to help customers lower their security management
costs.
*/














--How to check biggest table in Oracle

As a DBA, you must keep an eye on the largest tables in the database.
There are many things that get impacted with the largest objects like DB
performance, growth, index rebuild etc. The below query gives you the top
10 largest tables in oracle database.

--Query to check top 10 largest tables in Oracle

SELECT * FROM
(select
SEGMENT_NAME,
SEGMENT_TYPE,
BYTES/1024/1024/1024 GB,
TABLESPACE_NAME
from
dba_segments
order by 3 desc ) WHERE
ROWNUM <= 10;














--How to check database backups via sqlplus
--=========================================

Checking Database backups are one of the main focus areas of a DBA.
Time to time, DBA needs to check database backup status and see if its
completed, failed, running etc. Also, DBA must be able to get the backup
start time, end time and even the backup size for reference purpose. The
below query gives answers to all the backup details in oracle.

--Query to check database backup status
set linesize 500
col BACKUP_SIZE for a20
SELECT
INPUT_TYPE "BACKUP_TYPE",
--NVL(INPUT_BYTES/(1024*1024),0)"INPUT_BYTES(MB)",
--NVL(OUTPUT_BYTES/(1024*1024),0) "OUTPUT_BYTES(MB)",
STATUS,
TO_CHAR(START_TIME,'MM/DD/YYYY:hh24:mi:ss') as START_TIME,
TO_CHAR(END_TIME,'MM/DD/YYYY:hh24:mi:ss') as END_TIME,
TRUNC((ELAPSED_SECONDS/60),2) "ELAPSED_TIME(Min)",
--ROUND(COMPRESSION_RATIO,3)"COMPRESSION_RATIO",
--ROUND(INPUT_BYTES_PER_SEC/(1024*1024),2) "INPUT_BYTES_PER_SEC(MB)",
--ROUND(OUTPUT_BYTES_PER_SEC/(1024*1024),2) "OUTPUT_BYTES_PER_SEC(MB)",
--INPUT_BYTES_DISPLAY "INPUT_BYTES_DISPLAY",
OUTPUT_BYTES_DISPLAY "BACKUP_SIZE",
OUTPUT_DEVICE_TYPE "OUTPUT_DEVICE"
--INPUT_BYTES_PER_SEC_DISPLAY "INPUT_BYTES_PER_SEC_DIS",
--OUTPUT_BYTES_PER_SEC_DISPLAY "OUTPUT_BYTES_PER_SEC_DIS"
FROM V$RMAN_BACKUP_JOB_DETAILS
where start_time > SYSDATE -10
and INPUT_TYPE != 'ARCHIVELOG'
ORDER BY END_TIME DESC
/

--Query to check archive Backup status
In the 3rd last line and INPUT_TYPE != 'ARCHIVELOG', just remove '!' to
get archivelog backup details










--How to display date and time in query output
By default, when you query a date column, oracle will only display dates
and not time. Below query enables Oracle to display both date and time for
a particular session
alter session set nls_date_format='dd-Mon-yyyy hh:mi:sspm';
Note – this is only session level query.