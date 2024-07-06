DBA Scripts

Oracle DBA scripts - All in one pdf
  
More than 30 real-time scripts used by
DBAs everyday
  
Must have guide to perform your daily DBA tasks

Index
How to check users, roles and privileges in Oracle
How to check high resource intensive SQL in Oracle
How to check execution plan of a query
How to backup archivelog for specific sequence RMAN
How to check last CPU applied in Oracle
How to check biggest table in Oracle
How to check database backups via sqlplus
How to display date and time in query output
How to check scheduler jobs in Oracle
How to check datapump export progress
How to drop all schema objects in Oracle
How to find memory used by Oracle
How to check last user login Oracle
How to check CPU cores in Linux
How to delete files older than X days in Linux
How to analyze wait events in Oracle
How to set DISPLAY variable in Linux
Crontab error - Permission Denied
How to check FRA location utilization in Oracle
How to check last modified table in Oracle
How to check single table size in oracle
How to check database PITR after refresh
How to check archive generation in Oracle
How to disable firewall in Linux 7
How to check database lock conflict in Oracle
How to check database size in Oracle
How to configure yum server in linux
How to check query plan change in oracle
How to force users change password on first login Linux
How to check datafile utilization in Oracle
How to estimate flashback destination space
How to check temp tablespace utilization



How to check users, roles and privileges in Oracle
==================================================

Query to check the granted roles to a user

SELECT *
FROM DBA_ROLE_PRIVS
WHERE GRANTEE = '&USER';

Query to check privileges granted to a user

SELECT *
FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'USER';

Privileges granted to a role which is granted to a user

SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE IN
(SELECT granted_role FROM DBA_ROLE_PRIVS WHERE GRANTEE = '&USER') order by 3;

Query to check if user is having system privileges

SELECT *
FROM DBA_SYS_PRIVS
WHERE GRANTEE = '&USER';

Query to check permissions granted to a role

select * from ROLE_ROLE_PRIVS where ROLE = '&ROLE_NAME';
select * from ROLE_TAB_PRIVS where ROLE = '&ROLE_NAME';
select * from ROLE_SYS_PRIVS where ROLE = '&ROLE_NAME';


How to check high resource intensive SQL in Oracle
==================================================

Database performance is a major concern for a DBA. SQLs are the ones
which needs proper DB management in order to execute well. At times the
application team might tell you that the database is running slow. You can
run below query to get the top 5 resource intensive SQL with SQL ID and
then give it to application team to optimize them.

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


How to check execution plan of a query
======================================
First get the sql ID and then you can use below command to generate
execution plan of a query in oracle

SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('2t3nwk8h97vph',0));

In case you have more IDs, use below command to supply sql id every time
you run the query

SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',0));

How to backup archivelog for specific sequence RMAN
===================================================
When you issue archive backup commands via RAMN, it will backup all the
archive logs. Sometimes, you might need to backup only a particular
archive log sequence. Below command will help you backup archive logs
between specific sequence

RMAN> BACKUP ARCHIVELOG FROM SEQUENCE 288 UNTIL SEQUENCE 388 DELETE INPUT;

The above command will backup archive logs from 288 to 388 sequence number.


How to check last CPU applied in Oracle
=======================================
Generally if you have one single database install then checking the
database inventory will give you the latest patch details. But! if we have
multiple database in single oracle home then it might not give correct
results. There might be a chance that one DB is applied with latest patches
and others are not. In such cases, we need to check last CPU applied by
logging into the database using below query:

Query to Check Last CPU Applied on a Database:

col VERSION for a15;
col COMMENTS for a50;
col ACTION for a10;
set lines 500;
select ACTION,VERSION,COMMENTS,BUNDLE_SERIES from registry$history;

What are Critical Patch Updates (CPUs)?
Critical Patch Updates are sets of patches containing fixes for security
flaws in Oracle products. The Critical Patch Update program (CPU) was
introduced in January 2005 to provide security fixes on a fixed, publicly
available schedule to help customers lower their security management
costs.

How to check biggest table in Oracle
====================================
As a DBA, you must keep an eye on the largest tables in the database.
There are many things that get impacted with the largest objects like DB
performance, growth, index rebuild etc. The below query gives you the top
10 largest tables in oracle database.

Query to check top 10 largest tables in Oracle

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


How to check database backups via sqlplus
=========================================
Checking Database backups are one of the main focus areas of a DBA.
Time to time, DBA needs to check database backup status and see if its
completed, failed, running etc. Also, DBA must be able to get the backup
start time, end time and even the backup size for reference purpose. The
below query gives answers to all the backup details in oracle.

Query to check database backup status

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
Query to check archive Backup status
In the 3rd last line and INPUT_TYPE != 'ARCHIVELOG', just remove '!' to
get archivelog backup details
DBA Genesis | How to check database backups via sqlplus
How to display date and time in query output
By default, when you query a date column, oracle will only display dates
and not time. Below query enables Oracle to display both date and time for
a particular session
alter session set nls_date_format='dd-Mon-yyyy hh:mi:sspm';
Note – this is only session level query.
DBA Genesis | How to display date and time in query output
How to check scheduler jobs in Oracle
Below command will help you check Scheduler jobs which are con􀁓gured
inside database
SELECT JOB_NAME, STATE FROM DBA_SCHEDULER_JOBS where job_name='RMAN_BACKUP';
Query to check currently running scheduler jobs
SELECT * FROM ALL_SCHEDULER_RUNNING_JOBS;
All the DBA Scheduler jobs create logs. You can query below and check the
details of job logs
select log_id, log_date, owner, job_name
from ALL_SCHEDULER_JOB_LOG
where job_name like 'RMAN_B%' and log_date > sysdate-2;
select log_id,log_date, owner, job_name, status, ADDITIONAL_INFO
from ALL_SCHEDULER_JOB_LOG
where log_id=113708;
DBA Genesis | How to check scheduler jobs in Oracle
How to check datapump export progress
Sometimes when you run datapump export, it might take a lot of time.
Meanwhile client might ask you for the % of export completed. Use below
query to get the details of how much % export is done.
SELECT SID, SERIAL#, USERNAME, CONTEXT, SOFAR, TOTALWORK,
ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM V$SESSION_LONGOPS WHERE TOTALWORK != 0 AND SOFAR <> TOTALWORK;
DBA Genesis | How to check datapump export progress
How to drop all schema objects in Oracle
The below script will drop all the objects owned by a schema. This will not
delete the user but only deletes the objects
SET SERVEROUTPUT ON SIZE 1000000
set verify off
BEGIN
FOR c1 IN (SELECT OWNER,table_name, constraint_name FROM dba_constraints
WHERE constraint_type = 'R' and owner=upper('&shema_name')) LOOP
EXECUTE IMMEDIATE
'ALTER TABLE '||' "'||c1.owner||'"."'||c1.table_name||'" DROP CONSTRAINT ' || c1.constraint_name;
END LOOP;
FOR c1 IN (SELECT owner,object_name,object_type FROM dba_objects
where owner=upper('&shema_name')) LOOP
BEGIN
IF c1.object_type = 'TYPE' THEN
EXECUTE IMMEDIATE 'DROP '||c1.object_type||' "'||c1.owner||'"."'||c1.object_name||'" FORCE';
END IF;
IF c1.object_type != 'DATABASE LINK' THEN
EXECUTE IMMEDIATE 'DROP '||c1.object_type||' "'||c1.owner||'"."'||c1.object_name||'"';
END IF;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END LOOP;
EXECUTE IMMEDIATE('purge dba_recyclebin');
END;
/
DBA Genesis | How to drop all schema objects in Oracle
How to find memory used by Oracle
select decode( grouping(nm), 1, 'total', nm ) nm, round(sum(val/1024/1024)) mb
from
(
select 'sga' nm, sum(value) val
from v$sga
union all
select 'pga', sum(a.value)
from v$sesstat a, v$statname b
where b.name = 'session pga memory'
and a.statistic# = b.statistic#
)
group by rollup(nm);
DBA Genesis | How to find memory used by Oracle
How to check last user login Oracle
While performing database audits, you might need to check who logged in
last into the database. The query will help you find out last user who logged
in to database
select username, timestamp, action_name from dba_audit_session
where action_name='LOGON' and
rownum<10 and username not in ('SYS','DBSNMP','DUMMY','SYSTEM','RMAN');
DBA Genesis | How to check last user login Oracle
How to check CPU cores in Linux
Command to check CPU info on Linux
cat /proc/cpuinfo|grep processor|wc -l
OR
nproc --all
OR
getconf _NPROCESSORS_ONLN
Command to check CPU info on Solaris
psrinfo -v|grep "Status of processor"|wc -l
Command to check CPU info on AIX
lsdev -C|grep Process|wc -l
Command to check CPU info on HP/UX
ioscan -C processor | grep processor | wc -l
DBA Genesis | How to check CPU cores in Linux
How to delete files older than X days in Linux
Find 􀁓les older than X days and save ouput into a
file
The below Linux command will help you to 􀁓nd 􀁓les older than 35 days in a
specific directory path and save the ouput in backupfiles.log
Here the directory we are searching is /backup/logs and -mtime speci􀁓es
the modi􀁓ed time of a 􀁓le. We are saving the list of all the 􀁓les which are
older than 35 days in backupfiles.log
find /backup/logs -type f -mtime +35 -print > backupfiles.log &
Find 􀁓les older than 7 days and print output on
screen
If you want to print 􀁓les older than 7 days on screen and do not want to
save it into a file, use below command
find /backup/logs -type f -mtime +7 -print
Find 􀁓les in current directory older than 28 days
and remove them
Below linux command will 􀁓nd all the 􀁓les under current location (as we
have speci􀁓ed . dot), search 􀁓le name starting with arc h and ending with
log. check file create time with -ctime older than 28 days and then remove
those files using rm -f
find . -name arch\*log -ctime +28 -exec rm -f {} \;
DBA Genesis | How to delete files older than X days in Linux
How to analyze wait events in Oracle
User below query to get the top wait classes in Oracle database
Select wait_class, sum(time_waited), sum(time_waited)/sum(total_waits)
Sum_Waits
From v$system_wait_class
Group by wait_class
Order by 3 desc;
From the above query, supply each wait class into below query to get the
top wait events in database with respect to particular wait class
Select a.event, a.total_waits, a.time_waited, a.average_wait
From v$system_event a, v$event_name b, v$system_wait_class c
Where a.event_id=b.event_id
And b.wait_class#=c.wait_class#
And c.wait_class = '&Enter_Wait_Class'
order by average_wait desc;
DBA Genesis | How to analyze wait events in Oracle
How to set DISPLAY variable in Linux
Whenever you want to invoke graphical interface in Linux, You must know
how to set DISPLAY variable in order to open the GUI. Linux by default does
not allow you to open any GUI (Linux Oracle Installer) until you enable the
GUI display.
Use below command to enable Linux GUI interface at command prompt as
root user:
# xhost +
Sometimes, even after issuing above command, you wont be able to
invoke GUI because of “DISPLAY not set” error. In such case, you must
export the display environmental variable:
# echo $DISPLAY
# export DISPLAY=:0.0;
Now you can invoke any Linux GUI interface by directly running the
installer!
DBA Genesis | How to set DISPLAY variable in Linux
Crontab error - Permission Denied
When you try to schedule backups under corntab as Oracle user, you
might encounter crontab permission error
[oracle@plcdbprod ~]$ crontab -l
cron/oracle: Permission denied
The error is because of permission issues on /usr/bin/crontab 􀁓le. Login as
root user and find the crontab permissions on /usr/bin/crontab
[root@plcdbprod ~]# ls -l /usr/bin/crontab
-rwxr-xr-x 1 root root 315432 Jul 15 2008 /usr/bin/crontab
Give the below permissions to /usr/bin/crontab file
[root@plcdbprod ~]# chmod 4755 /usr/bin/crontab
[root@plcdbprod ~]# ls -l /usr/bin/crontab
-rwsr-xr-x 1 root root 315432 Jul 15 2008 /usr/bin/crontab
Login as oracle user and check your crontab -e.
Happy Learning!!!
DBA Genesis | Crontab error
How to check FRA location utilization in
Oracle
Flash Recovery Area must be monitored regularly. Sometimes FRA runs our
of space and a DBA must be able to gather FRA space utilization. It is very
important to monitor space usage in the fast recovery area to ensure that
it is large enough to contain backups and other recovery-related files.
Below script gives you Flash Recovery Area utilization details:
set linesize 500
col NAME for a50
select name, ROUND(SPACE_LIMIT/1024/1024/1024,2) "Allocated Space(GB)",
round(SPACE_USED/1024/1024/1024,2) "Used Space(GB)",
round(SPACE_RECLAIMABLE/1024/1024/1024,2) "SPACE_RECLAIMABLE (GB)" ,
(select round(ESTIMATED_FLASHBACK_SIZE/1024/1024/1024,2)
from V$FLASHBACK_DATABASE_LOG) "Estimated Space (GB)"
from V$RECOVERY_FILE_DEST;
DBA Genesis | How to check FRA location utilization in Oracle
How to check last modified table in Oracle
As a DBA, application team sometimes might ask you to provide details of
last modi􀁓ed table in oracle. The table modi􀁓cation can be insert, update
or delete. Below queries get details of last or latest modi􀁓ed table in oracle
database. Run the queries depending upon the database version.
Last modified table in oracle 10g and Above
set linesize 500;
select TABLE_OWNER, TABLE_NAME, INSERTS, UPDATES, DELETES,
to_char(TIMESTAMP,'YYYY-MON-DD HH24:MI:SS')
from all_tab_modifications
where table_owner<>'SYS' and
EXTRACT(YEAR FROM TO_DATE(TIMESTAMP, 'DD-MON-RR')) > 2010
order by 6;
In 9i, table monitoring has to be enabled manually or else the
all_tab_modifcations wont keep record of changes. 10g onwards, oracle by
default records the modifications
Last modified table in oracle for 9i db
col object for a20;
col object_name for a20;
SELECT OWNER, OBJECT_NAME, OBJECT_TYPE,
to_char(LAST_DDL_TIME,'YYYY-MON-DD HH24:MI:SS')
from dba_objects where LAST_DDL_TIME=(select max(LAST_DDL_TIME)
from dba_objects WHERE object_type='TABLE');
DBA Genesis | How to check last modified table in Oracle
How to check single table size in oracle
Once you run the query, it will ask your table name. Enter the table name in
the format of owner.tablename. Eg - scott.emp
select segment_name,segment_type, sum(bytes/1024/1024/1024) GB
from dba_segments
where segment_name='&Your_Table_Name'
group by segment_name,segment_type;
DBA Genesis | How to check single table size in oracle
How to check database PITR after refresh
Database refresh is common task for a DBA. But after every database
refresh, you must check the PITR date and time. This should be checked
before you issue OPEN RESETLOGS command.
Query to Check PITR – Issue it before OPEN
RESETLOGS
select distinct to_char(checkpoint_time,'dd/mm/yyyy hh24:mi:ss') checkpoint_time
from v$datafile_header ;
DBA Genesis | How to check database PITR after refresh
How to check archive generation in Oracle
The below query gives results of archive generation in oracle database. Use
below query to 􀁓nd the archive space requirements and you can use it to
estimate the archive destination size perfectly well.
SELECT A.*,
Round(A.Count#*B.AVG#/1024/1024/1024) Daily_Avg_gb
FROM
(SELECT
To_Char(First_Time,'YYYY-MM-DD') DAY,
Count(1) Count#,
Min(RECID) Min#,
Max(RECID) Max#
FROM v$log_history
GROUP
BY To_Char(First_Time,'YYYY-MM-DD')
ORDER
BY 1 DESC
) A,
(SELECT
Avg(BYTES) AVG#,
Count(1) Count#,
Max(BYTES) Max_Bytes,
Min(BYTES) Min_Bytes
FROM
v$log ) B;
DBA Genesis | How ot check archive generation in Oracle
How to disable firewall in Linux 7
Disabling 􀁓rewall in Linux 5/7 versions is little bit di􀁣erent than Linux 7.
Sometimes you need to disable 􀁓rewall in Linux 7 version as part of
Database installation pre-requisites. This article will help you to 􀁓nd the
status of firewall and then enable / disable it.
Firewall Status
The below command will show you the current status “Active” in case
firewall is running:
# systemctl status firewalld
Firewall stop / start
You can start/stop Linux firewall with below commands:
# service firewalld stop
# service firewalld start
Firewall Disable / Enable
You can enable/disable 􀁓rewall completely on Linux with below
commands:
# systemctl disable firewalld
# systemctl enable firewalld
DBA Genesis | How to disable firewall in Linux 7
How to check database lock conflict in Oracle
Database lock con􀁔icts are one of the issues which DBA needs to deal
with. The database locks can keep users waiting for very long and we much
know how to check database locks. Users reporting that their query is
taking too long to execute, then you must also check if there are any locks
on the objects being accessed (unless its a select query). Use below
queries to check the database locks:
Checking Lock Conflicts in 10g and Above:
select a.SID "Blocking Session", b.SID "Blocked Session"
from v$lock a, v$lock b
where a.SID != b.SID and a.ID1 = b.ID1 and a.ID2 = b.ID2 and
b.request > 0 and a.block = 1;
Checking Lock Conflicts in 9i Systems:
select s1.username || '@' || s1.machine
|| ' ( SID=' || s1.sid || ' ) is blocking '
|| s2.username || '@' || s2.machine
|| ' ( SID=' || s2.sid || ' ) ' AS blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid
and l1.BLOCK=1 and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2 ;
Query to Check Lock is Table Level or Row Level
col session_id head 'Sid' form 9999
col object_name head "Table|Locked" form a30
col oracle_username head "Oracle|Username" form a10 truncate
col os_user_name head "OS|Username" form a10 truncate
col process head "Client|Process|ID" form 99999999
col owner head "Table|Owner" form a10
col mode_held form a15
select lo.session_id,lo.oracle_username,lo.os_user_name,
lo.process,do.object_name,do.owner,
decode(lo.locked_mode,0, 'None',1, 'Null',2, 'Row Share (SS)',
3, 'Row Excl (SX)',4, 'Share',5, 'Share Row Excl (SSX)',6, 'Exclusive',
to_char(lo.locked_mode)) mode_held
from gv$locked_object lo, dba_objects do
where lo.object_id = do.object_id
order by 5
/
DBA Genesis | How to check database lock conflict in Oracle
How to check database size in Oracle
A DBA works on many aspects of database like cloning, backup,
performance tuning etc. In every aspect of database administration, most
of the times resolution depends upon the size of database. For example,
DBA can implement DB FULL backup strategy on a very small database
when compared to DB INCREMENTAL strategy on a very large database.
Use below script to check db size along with Used space and free space in
database:
col "Database Size" format a20
col "Free space" format a20
col "Used space" format a20
select round(sum(used.bytes) / 1024 / 1024 / 1024 ) || ' GB' "Database Size"
, round(sum(used.bytes) / 1024 / 1024 / 1024 ) -
round(free.p / 1024 / 1024 / 1024) || ' GB' "Used space"
, round(free.p / 1024 / 1024 / 1024) || ' GB' "Free space"
from (select bytes
from v$datafile
union all
select bytes
from v$tempfile
union all
select bytes
from v$log) used
, (select sum(bytes) as p
from dba_free_space) free
group by free.p
/
DBA Genesis | How to check database size in Oracle
How to configure yum server in linux
In this article, we will learn how to con􀁓gure yum server in di􀁣erent Oracle
Linux versions. YUM repository is a software package manager which
allows you to easily install, update or delete RPMs. Most of the required
RPM packages come along with the Linux installer CD. But! if you have
internet connection, you can con􀁓gure YUM repository on Linux and this
will remove installer CD or iso file dependency.
Most of the times when you want to install packages (RPMs) for Oracle
products, it really becomes tough to identify and install each package.
Good news is! you can connect to Yum server and get the packages at one
shot!
Download and configure yum server
Download and copy the appropriate yum con􀁓guration 􀁓le in place, by
running the following commands as root:
cd /etc/yum.repos.d
For Oracle Linux 7
# wget http://public-yum.oracle.com/public-yum-ol7.repo
For Oracle Linux 6
# wget http://public-yum.oracle.com/public-yum-ol6.repo
For Oracle Linux 5
# wget http://public-yum.oracle.com/public-yum-el5.repo
Download and install Oracle Linux
Download and install Oracle Linux and make sure your are able to connect
to internet. Start using yum server with below commands:
# yum list --> to list all the contents of yum repository
# yum install oracle-validated --> to install oracle-valudated package
# yum install libaio-devel* --> to install libaio-devel rpm
The oracle-validated package will install all the packages required to install
Oracle Database and RAC on OEL 5.
DBA Genesis | How to configure yum server in linux
How to check query plan change in oracle
If you would like to 􀁓nd out change in SQL plan of a query, below script will
help you 􀁓nd the SQL plan ID for previous executions and check if there is
any change in SQL plan ID.
set pagesize 1000
set linesize 200
column begin_interval_time format a20
column milliseconds_per_execution format 999999990.999
column rows_per_execution format 999999990.9
column buffer_gets_per_execution format 999999990.9
column disk_reads_per_execution format 999999990.9
break on begin_interval_time skip 1
SELECT
to_char(s.begin_interval_time,'mm/dd hh24:mi')
AS begin_interval_time,
ss.plan_hash_value,
ss.executions_delta,
CASE
WHEN ss.executions_delta > 0
THEN ss.elapsed_time_delta/ss.executions_delta/1000
ELSE ss.elapsed_time_delta
END AS milliseconds_per_execution,
CASE
WHEN ss.executions_delta > 0
THEN ss.rows_processed_delta/ss.executions_delta
ELSE ss.rows_processed_delta
END AS rows_per_execution,
CASE
WHEN ss.executions_delta > 0
THEN ss.buffer_gets_delta/ss.executions_delta
ELSE ss.buffer_gets_delta
END AS buffer_gets_per_execution,
CASE
WHEN ss.executions_delta > 0
THEN ss.disk_reads_delta/ss.executions_delta
ELSE ss.disk_reads_delta
END AS disk_reads_per_execution
FROM wrh$_sqlstat ss
INNER JOIN wrm$_snapshot s ON s.snap_id = ss.snap_id
WHERE ss.sql_id = '&sql_id'
AND ss.buffer_gets_delta > 0
ORDER BY s.snap_id, ss.plan_hash_value;
DBA Genesis | How to check query plan change in oracle
How to force users change password on first
login Linux
How to force users change their passwords upon 􀁓rst login in Linux? How
to make sure user changes password at next login time in Linux?
You can force a user to change their password upon 􀁓rst time login to
Linux server. You can even force existing users to change their passwords
on next login. This is done using c hage command in Linux. The chage
command will change the user password expiry information.
The below chage command will make user password expired. Hence, this
will force user to provide a new password. Here we are forcing oracle user
to change password on next login
# chage -d 0 oracle
The option -d 0 will mark the password expired and hence, user will be
forced to change password.
DBA Genesis | How to force users change password on first login Linux
How to check datafile utilization in Oracle
When you want to shrink a data􀁓le, you must always check the single
data􀁓le utilization. In case if you shrink data􀁓le more than the used size, it
will fail. Below query gives the data􀁓le utilization and depending upon the
datafile free space, you can shrink it
col file_name for a60;
set pagesize 500;
set linesize 500;
SELECT SUBSTR (df.NAME, 1, 40) file_name, df.bytes / 1024 / 1024 allocated_mb,
((df.bytes / 1024 / 1024) - NVL (SUM (dfs.bytes) / 1024 / 1024, 0))
used_mb,
NVL (SUM (dfs.bytes) / 1024 / 1024, 0) free_space_mb
FROM v$datafile df, dba_free_space dfs
WHERE df.file# = dfs.file_id(+)
GROUP BY dfs.file_id, df.NAME, df.file#, df.bytes
ORDER BY file_name;
DBA Genesis | How to check datafile utilization in Oracle
How to estimate flashback destination space
Sometimes application team will ask DBA to enable 􀁔ashback for x
number of days. In such case, a DBA needs to estimate the 􀁔ashback
space required for x number of days in order to store the 􀁔ashback logs.
The flashback log size is same as archive log size generated in a database.
Check the archive generation size via below query
Take the average per day size of archives generated
Multiply the average archive size with x number of days
Ask storage team to add the required space for flashback file system
Check archive generation size via below query:
select to_char(COMPLETION_TIME,'DD-MON-YYYY') Arch_Date,count(*) No#_Logs,
sum((BLOCKS*512)/1024/1024/1024) Arch_LogSize_GB
from v$archived_log
where to_char(COMPLETION_TIME,'DD-MON-YYYY')>=trunc(sysdate-7) and DEST_ID=1
group by to_char(COMPLETION_TIME,'DD-MON-YYYY')
order by to_char(COMPLETION_TIME,'DD-MON-YYYY');
Note: Take average size * 30 days to get 1 month flashback space size.
DBA Genesis | How to estimate flashback destination space
How to check temp tablespace utilization
set lines 200
select TABLESPACE_NAME, sum(BYTES_USED/1024/1024),sum(BYTES_FREE/1024/1024)
from V$TEMP_SPACE_HEADER group by TABLESPACE_NAME;
SELECT A.tablespace_name tablespace, D.GB_total,
SUM (A.used_blocks * D.block_size) / 1024 / 1024 /1024 GB_used,
D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 / 1024 GB_free
FROM v$sort_segment A,
(
SELECT B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 /1024 GB_total
FROM v$tablespace B, v$tempfile C
WHERE B.ts#= C.ts#
GROUP BY B.name, C.block_size
) D
WHERE A.tablespace_name = D.name
GROUP by A.tablespace_name, D.GB_total;
DBA Genesis | How to check temp tablespace utilization
Welcome to DBA Genesis!
Fastest & most engaging learning platforms for DBA
DBA Genesis gives you everything you need to easily practice, learn
and prepare for Database Administration. Enroll into your 􀁓rst
course now!
Enroll now
