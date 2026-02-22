Top 108 Interview Questions for Database Administrator
======================================================
1. What will happen if the database archive log destination is full 
and what will happen to the application transactions

🔴 Database Behavior
When the archive log destination runs out of space, Oracle cannot archive the online redo logs. This triggers a cascade of events:

1. Redo Log Archiving Halts
Oracle continuously writes to online redo log groups in a circular fashion.
Before Oracle can reuse/overwrite a redo log group, it must be archived.
If the archive destination is full → archiving fails → Oracle cannot switch to the next redo log.

2. Log Switch Becomes Impossible
Oracle attempts a log switch but the current log group cannot be marked as archived.
The database enters a waiting state.

3. Database Hangs / Freezes
All sessions requiring redo log space will hang
Youll see waits like:
    log file switch (archiving needed)
    log file switch (checkpoint incomplete)
    arch wait on SENDREQ

🔴 Impact on Application Transactions
Impact	                Description
New DML Freezes	      INSERT, UPDATE, DELETE statements hang and do not complete
Commits Hang	           Active transactions attempting to commit will freeze
No Rollbacks Affected     Read-only SELECT queries may still work temporarily
Connection Timeouts	      Application connection pools begin to time out
Application Errors	      Eventually users see errors like "ORA-00257: archiver error"
Business Impact	      Complete application outage for all write operations

Key Oracle Error:

ORA-00257: archiver error. Connect internal only, until freed

Immediate Resolution Steps

-- 1. Check archive log destination usage
SELECT dest_name, status, target, archiver, schedule, destination
FROM v$archive_dest
WHERE status = 'VALID';

-- 2. Check what's consuming space (OS level)
-- Then free up space by moving/deleting old archive logs

-- 3. After freeing space, force archiver to retry
ALTER SYSTEM ARCHIVE LOG ALL;

-- 4. Verify archiver is running again
SELECT * FROM v$archive_processes;

--Never delete archive logs directly from the OS if RMAN is your backup tool — always use RMAN to delete them so the catalog stays in sync.

-- Safe deletion via RMAN
RMAN> CROSSCHECK ARCHIVELOG ALL;
RMAN> DELETE EXPIRED ARCHIVELOG ALL;
RMAN> DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2'; -- keep last 2 days

--Prevention Best Practices
Practice	               Action
Monitor regularly	     Alert when archive dest > 80% full
Use FRA	               Set DB_RECOVERY_FILE_DEST_SIZE with adequate size
Regular RMAN backups	Backup and delete old archive logs on schedule
Multiplex destinations	Use multiple archive log destinations (LOG_ARCHIVE_DEST_1, _2)
Set alerts	          Use Oracle Enterprise Manager or custom scripts

-- Check Fast Recovery Area usage
SELECT space_limit/1024/1024/1024 AS limit_GB,
       space_used/1024/1024/1024  AS used_GB,
       space_reclaimable/1024/1024/1024 AS reclaimable_GB,
       number_of_files
FROM v$recovery_file_dest;

Bottom line: A full archive log destination = complete write outage for your application. Its one of the most impactful database storage issues and requires immediate attention.







2. How do you decommission a oracle database

Decommissioning an Oracle database is a structured process that requires careful planning to avoid data loss and ensure compliance. Heres a complete guide:

Phase 1: Pre-Decommission Planning
Before touching anything, complete these steps:

✅ Checklist
 Get formal sign-off from application owners and management
 Confirm no active users or applications depend on this DB
 Identify all dependent applications, jobs, and interfaces
 Determine data retention requirements (legal/compliance)
 Schedule a maintenance window


 Phase 2: Final Backup
⚠️ Always take a final backup before decommissioning — even if the data isnt needed.

--bash
--# Full RMAN backup before anything else
rman target /
RMAN> BACKUP DATABASE PLUS ARCHIVELOG;
RMAN> BACKUP CURRENT CONTROLFILE;

--Also export data if needed for archival:

--# Full Data Pump export (for archival purposes)
expdp system/password \
  FULL=Y \
  DUMPFILE=final_archive_%U.dmp \
  LOGFILE=final_archive.log \
  DIRECTORY=DATA_PUMP_DIR \
  COMPRESSION=ALL

Phase 3: Notify and Disconnect

-- Check for active sessions
SELECT username, sid, serial#, status, program, machine
FROM v$session
WHERE type = 'USER';

-- Kill active sessions if needed
ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;

-- Restrict access to prevent new connections
ALTER SYSTEM ENABLE RESTRICTED SESSION;


Phase 4: Remove Database Jobs and Links

-- Disable all DBMS scheduler jobs
BEGIN
  FOR j IN (SELECT job_name, owner FROM dba_scheduler_jobs) LOOP
    DBMS_SCHEDULER.DISABLE(j.owner || '.' || j.job_name);
  END LOOP;
END;
/

-- Drop all database links
SELECT 'DROP DATABASE LINK ' || db_link || ';'
FROM dba_db_links;

-- Remove external references (Oracle Streams, GoldenGate, etc.)


Phase 5: Unregister from Supporting Infrastructure

Component	            Action
OEM / Cloud Control	  Remove target from Enterprise Manager
Listener	            Remove service from listener.ora
tnsnames	            Remove entry from tnsnames.ora on all clients
Load Balancer	       Remove DB service from LB rules
Monitoring Tools	  Remove from Nagios/Zabbix/custom monitors
Backup Tools	       Remove from RMAN catalog / backup policies


--# Unregister from RMAN catalog (if using catalog)
rman target / catalog rmancat/password@catalog_db

RMAN> UNREGISTER DATABASE;


Phase 6: Shut Down and Delete the Database
Option A — Using DBCA (Recommended)
--bash

dbca -silent -deleteDatabase \
  -sourceDB <DB_SID> \
  -sysDBAUserName sys \
  -sysDBAPassword <password>

Option B — Manual Deletion
--sql

-- Step 1: Startup mount and drop the database
STARTUP MOUNT EXCLUSIVE RESTRICT;

-- Step 2: Drop the database (removes all datafiles, logs, controlfiles)
DROP DATABASE;

--This single command removes:

All datafiles
All redo log files
All control files
The SPFILE (if on default location)

Phase 7: OS-Level Cleanup
--bash
--# Remove Oracle files (if any remain)
rm -rf $ORACLE_BASE/oradata/<DBNAME>/
rm -rf $ORACLE_BASE/admin/<DBNAME>/
rm -rf $ORACLE_BASE/diag/rdbms/<dbname>/
rm -rf $ORACLE_BASE/fast_recovery_area/<DBNAME>/

--# Remove init/password files
rm $ORACLE_HOME/dbs/init<SID>.ora
rm $ORACLE_HOME/dbs/orapw<SID>
rm $ORACLE_HOME/dbs/spfile<SID>.ora


--Update OS Configuration Files

--# Remove from /etc/oratab (Linux)
vi /etc/oratab
--# Delete the line: DBNAME:/oracle/product/19c:Y

--# Remove from srvctl (if RAC or Oracle Restart)
srvctl remove database -db <DBNAME>


Phase 8: Final Verification & Documentation

--# Confirm no Oracle processes remain for this SID
ps -ef | grep <SID>

--# Confirm listener no longer shows the service
lsnrctl status


--Document the decommission:
 Date of decommission
 Who approved it
 Where the final backup/export is stored
 Retention period for the backup
 Ticket/change request number


--Summary Flow
Plan & Approval
     ↓
Final Backup (RMAN + Data Pump)
     ↓
Notify Users & Kill Sessions
     ↓
Remove Jobs, Links, Schedules
     ↓
Unregister from OEM, Listeners, Monitoring
     ↓
DROP DATABASE (DBCA or Manual)
     ↓
OS Cleanup (/etc/oratab, files, dirs)
     ↓
Document Everything
💡 Tip: For RAC databases, you must also remove the database from the cluster registry using srvctl and handle ASM diskgroups separately before dropping.









3. What is psu, cpu and ru patches difference

Oracle has evolved its patching terminology over the years. Here's a clear breakdown:

Quick Comparison Table

Feature	               CPU	                         PSU	               RU
Full Name	               Critical Patch Update	     Patch Set Update	Release Update
Era	                    Pre-2017	                    Pre-2017	          2017–Present
Contains Security Fixes	✅ Yes	                  ✅ Yes	            ✅ Yes
Contains Bug Fixes	     ❌ No	                       ✅ Yes	            ✅ Yes
Release Frequency	     Quarterly	                    Quarterly	          Quarterly
Current Status	          ❌ Retired	                  ❌ Retired	       ✅ Active

Detailed Explanation
🔵 CPU — Critical Patch Update (Retired)
Released quarterly by Oracle (Jan, Apr, Jul, Oct)
Contained only security fixes — nothing else
Very minimal footprint — low risk to apply
Did not fix functional bugs or performance issues
Retired with Oracle 12.2 and earlier patch strategies

🟡 PSU — Patch Set Update (Retired)
Also released quarterly
A superset of CPU — included all security fixes plus important bug fixes
Larger in size than CPU
Recommended over CPU because it was more comprehensive
Could be applied on top of a base release (e.g., 12.1.0.2)
Retired when Oracle moved to the new RU model in 2017
📌 If you were on PSU, you couldn't directly apply CPU — they had different patch lineages

🟢 RU — Release Update (Current Standard)
Introduced with Oracle 18c and backported to 12.2
Replaces both CPU and PSU
Released quarterly — same Oracle patch cycle
Contains:
Security fixes (what CPU had)
Bug fixes (what PSU added)
Additional stability and functional improvements
Companion patch: RUR (Release Update Revision) for critical fixes between RU cycles

Oracle Patching Timeline
Before 2017:          CPU → Security only
                      PSU → Security + Bugs
                      
2017 Onwards:         RU  → Security + Bugs + Improvements  ✅ (Current)
                      RUR → Critical fixes between RU cycles ✅ (Current)


Current Patch Structure (12.2 onwards)
Base Release (e.g., 19.3.0)
        ↓
   RU 19.X.0.0.0  ← Quarterly, contains security + bug fixes
        ↓
   RUR 19.X.X.X   ← Between-quarter critical fixes (optional)
        ↓
   One-off Patch   ← Specific single bug fix


Related Patches You Should Know
Patch	                    Description
OJVM RU	                    Separate RU specifically for Oracle JVM component
GI RU	                    Grid Infrastructure Release Update (for RAC/Exadata)
RUR	                        Release Update Revision — smaller fix between quarters
One-off Patch	            Single bug fix, applied on top of RU
Combo Patch	                Bundled DB RU + OJVM RU together for convenience

Practical Tip
💡 If someone mentions "applying a PSU" today, they likely mean RU — just different terminology from the old days. Always apply the latest RU for your Oracle version to stay current on security and stability.


# Check current patch level applied on your DB
SELECT patch_id, patch_uid, version, action, status, description, action_time
FROM sys.dba_registry_sqlpatch
ORDER BY action_time;










4. What are the steps for upgrades from 11g to 12c and 12c to 19c










5. What to do if my query or batch job is taking time

Troubleshooting Slow Queries & Batch Jobs in Oracle
Heres a systematic approach to diagnose and fix performance issues:

Step 1: Identify the Problem Session

-- Find currently running slow sessions
SELECT s.sid, s.serial#, s.username, s.status, s.program,
       s.sql_id, s.event, s.wait_class,
       s.seconds_in_wait, s.last_call_et AS elapsed_secs
FROM v$session s
WHERE s.status = 'ACTIVE'
  AND s.username IS NOT NULL
ORDER BY s.last_call_et DESC;


Step 2: Get the SQL Being Executed
--sql

-- Get the actual SQL text of the slow query
SELECT sql_id, sql_text, executions, elapsed_time/1000000 AS elapsed_secs,
       cpu_time/1000000 AS cpu_secs,
       disk_reads, buffer_gets, rows_processed
FROM v$sql
WHERE sql_id = '&sql_id';

-- Or get SQL from the session directly
SELECT sq.sql_text
FROM v$session s, v$sql sq
WHERE s.sql_id = sq.sql_id
  AND s.sid = &sid;


Step 3: Check the Execution Plan

-- Check the current/actual execution plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', NULL, 'ALLSTATS LAST'));

-- Or explain plan for your query
EXPLAIN PLAN FOR
<your query here>;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


🔴 Warning Signs in Execution Plans
Bad Sign	                         Meaning
FULL TABLE SCAN on large table	Missing index
High Rows estimate vs Actual	     Stale statistics
NESTED LOOPS on millions of rows	Bad join method
CARTESIAN JOIN	                    Missing join condition
Buffer Gets very high	          Inefficient access path
Temp space usage	               Sort/hash spilling to disk


Step 4: Check Wait Events

-- What is the session waiting for?
SELECT sid, event, wait_class, state, seconds_in_wait, p1, p2, p3
FROM v$session_wait
WHERE sid = &sid;

Common Wait Events & Meaning
Wait Event	                        What It Means
db file sequential read	            Single block I/O — index reads
db file scattered read	            Multi-block I/O — full table scan
log file sync	                    Waiting for LGWR — commit bottleneck
enq: TX - row lock contention	     Row-level locking — blocked by another session
library cache lock	                Hard parsing — missing bind variables
direct path read temp	            Sorting to TEMP — insufficient PGA/sort area
CPU	                                High CPU — possibly bad execution plan


Step 5: Gather AWR / ASH Report (Best for Batch Jobs)

-- ASH report for a specific time window (last 30 mins)
SELECT sql_id, event, COUNT(*) AS sample_count
FROM v$active_session_history
WHERE sample_time > SYSDATE - 30/1440
  AND session_type = 'FOREGROUND'
GROUP BY sql_id, event
ORDER BY sample_count DESC;

# Generate full AWR report (HTML)
@$ORACLE_HOME/rdbms/admin/awrrpt.sql


Step 6: Common Fixes
🔧 Fix 1 — Gather Fresh Statistics

-- Stale stats cause bad execution plans
EXEC DBMS_STATS.GATHER_TABLE_STATS('SCHEMA_NAME', 'TABLE_NAME', CASCADE => TRUE);
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SCHEMA_NAME');

Fix 2 — Create or Rebuild Index

-- Create a new index
CREATE INDEX idx_name ON table_name(column_name);

-- Rebuild fragmented index
ALTER INDEX idx_name REBUILD;

-- Check index usage
SELECT * FROM v$object_usage WHERE index_name = 'IDX_NAME';


Fix 3 — Use SQL Hints (Temporary)

-- Force index usage
SELECT /*+ INDEX(t idx_name) */ * FROM table_name t WHERE ...;

-- Force full table scan
SELECT /*+ FULL(t) */ * FROM table_name t WHERE ...;

-- Force parallel execution
SELECT /*+ PARALLEL(t, 4) */ * FROM table_name t WHERE ...;

Fix 4 — Use SQL Plan Baseline (Pin a Good Plan)

-- Capture a good plan and pin it
DECLARE
  l_plans NUMBER;
BEGIN
  l_plans := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id => '&sql_id');
END;
/


Fix 5 — Check for Locking/Blocking

-- Find blocked sessions
SELECT l.sid, l.type, l.block, l.request,
       s.username, s.program, s.sql_id
FROM v$lock l
JOIN v$session s ON l.sid = s.sid
WHERE l.block > 0 OR l.request > 0
ORDER BY l.block DESC;


Step 7: For Batch Jobs Specifically

-- Check if parallel query is being used
SELECT degree FROM dba_tables WHERE table_name = 'YOUR_TABLE';

-- Enable parallel for a session
ALTER SESSION ENABLE PARALLEL DML;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;

-- Check TEMP tablespace usage (batch jobs often sort)
SELECT tablespace_name, total_blocks, used_blocks, free_blocks
FROM v$sort_segment;

-- Increase PGA for sort operations
ALTER SYSTEM SET PGA_AGGREGATE_TARGET = 2G;


Diagnostic Flow Summary

Slow Query/Batch Job
       ↓
Identify Session (v$session)
       ↓
Get SQL Text (v$sql)
       ↓
Check Execution Plan → Bad Plan? → Fix Stats / Add Index / Hint
       ↓
Check Wait Events → I/O Wait? → Index | Lock? → Kill Blocker | Temp? → PGA
       ↓
AWR/ASH Report (for historical analysis)
       ↓
Apply Fix → Monitor → Baseline Good Plan


 Golden Rule: Always check the execution plan first — 80% of Oracle performance issues are caused by a bad execution plan due to stale statistics or missing indexes.













6. What is database character set what is the difference between al32utf8 
and other character set

7. Checklist before installing a oracle database and creating databases

8. How to make the expdp and impdp to run faster? lets say there is 5tb 
of db, how to make it faster? what are the various parameters?

9. Yesterday the query is taking 5 mins and today its taking 30 mins. why and what are the steps?

10. You have completed patching on dev, test and pre-prod 
and now think you were doing patching on production environment 
and its taking much time so how can you handle this?

11. You were doing upgrades from 11g to 19c and you were found 
invalid objects during upgrade and how can you fix those things?

12. Have you done cross platform migrations? and migration from on-premises to cloud?

13. Top things you will be checking in awr report?

14. Do you have any Golden gate exposure?

15. What are the parameters to check while creating container database 
and pluggable database max, how many containers databases we can create

16. What is acfs, cachefusion, shared pool, scan ip, virtual ip, logical standby, physical standby db

17. How many ip's we need to configure for 2node rac

18. Can you please tell the steps to upgrade 2 node rac

19. Steps to apply a patch on dataguard environment and command to start a mrp process

20. what are the high level steps to apply a patch and how can you rollback a patch

21. What if my pfile and spfile is lost and how we start the database 
and what is the default location of pfile

22. What if control file is lost and how can we recover with rman

23. How the select, update, delete statement works in oracle database

24. How to recover if redo log member is lost and how to add a redo member to a group?

25. How to recover if datafile is lost?

26. A datafile was wrongly added on file system instead of ASM disk group. 
How to move it to the ASM disk group again?

27. How to apply a patch on 2node rac with standby database?

28. How to configure fast start failover?

29. What is ocr, olr, crsd, cssd and voting disk

30. What is cache fusion, cache coherence

31. What is vip, scanip how the nodes communicates each other

32. What is difference between rman and expdp

33. How to resolve block corruption with rman and will it resolve thru expdp

34. What is the role of pga during update statement

35. What is sql profile and db profile and how it works 
and how can you change the Plug a better plan hash value

36. I have a backup taken at 12.10 AM and 12.30 AM 
and how to restore the backup taken at 12.10 only?

37. What is normal change and expedite change

38. I have a 4 node rac and if node is evicted then how to resolve it 
and how to relocate the services from one node to another node 
command to check the services

39. What is latch and how does it will occur and how to resolve it

40. My application is hanging and how do you trouble shoot it quickly

41. Suddenly the database performance is low after adding a disk to asm

42. What is backup piece?

43. How to backup control file with rman

44. What is catalogue command in rman

45. Can we backup a online redo log file

46. What are the high level patching steps on oracle rac database

47. What is asm_power_limit what is the default value in higher versions

48. What is split brain syndrome

49. What if my ocr is corrupted and what are the steps and how to take 
a backup of ocr and voting disk

50. What if one of my voting disk is corrupted out of 5 voting disk

51. One of my table is dropped how to recover that table alone in oracle 12c

52. Junior dba removed oracle home with rm -rf command. 
what will happen to the db can we recover the db ?

53. Junior dba removed the restore point from my primary database. 
how to recover to the last restore point? 
and is it possible to restore to the last restore point?

54. You have upgraded the database from 11g to 12c or 19c 
after some days the application team wants to restore to the older version

55. How to restore if my compatible parameter is not set 
or if you have set the compatible parameter then can we restore to older version?

56. How to configure a 4 node rac what are the high level steps

57. How to upgrade the rac database/primary db with standby with lesser downtime

58. Orainventory is corrupted and how to recreate it

59. How to convert from noncdb to cdb

60. How to convert from nonasm to asm

61. Do you have any basic knowledge in sqlservers

62. Do you have a basic knowledge in goldengate

63. How to covert from physical standby to logical standby? 
and physical to snapshot standby database?

64. What Happened to Database, Suddenly Listener Got Down. 
and how can you troubleshoot listener issues

65. What is oracle fine grained auditing?

66. What will you do if you see the cpu usage is 90 or 100%

67. What is in-memory, sga and pga and is sga and pga are 
dynamic parameters and how to increase memory the sga and pga 
and what prechecks you will do

68. How can you findout that there is a shortage of memory 
in the server and how will you increase it

69. What is crsctl disable/enable crs

70. What are the different types of rman backups available in 
rman and how to speed up the rman backup

71. What is cumulative and differential and what is full backup and level0 backup

72. What is block change tracking in rman

73. How many ip's do we need to configure for 2 node rac and 5 node rac 
and which ip's are to be in same subnet

74. What is public, private, scan ip and vip

75. What is Addm, Ash, and Awr and what are the things you will check in these reports

76. How can you find out if there are any vulnerabilities in oracle database

77. What are the things you will run after db creation how many ways you can create the db

78. What are the v$views, baseviews, dictionary views how to update these views

79. What are ways you can do for oracle database migration, 
what are the things you will check before migration

80. Which migration method did you used in your earlier project

81. What are the new features in oracle 19c, 21c and which feature have you used in your recent project

82. How can you read the dumpfile if the logfile are not there

83. How many redundancy available in asm and what are those by default 
if we add a disk what is the redundancy

84. What is password file in oracle database

85. What is character set and how many types of character set in oracle

86. What is proactive and reactive tunning

87. What is pctfree and pctused

88. What are the waitevents in oracle rac and how to resolve it

89. What is haip in oracle rac

90. What if the private connection fails in oracle rac what are the steps to take inorder to avoid it

91. What is dB sequential and db scaterred wait events and how to resolve

92. What is fragmentation how to resolve it

93. What to do if there heavy bulk inserts and updates on the db level

94. What is automatic and manual memory management

95. What to do if there are heavy sorts in oracle database 
    what need to check at the pga and temporary tablespace level

96. What are hints and name some of the hints that we used

97. How to avoid the swiping and memory issues at the Linux os level

98. How can we run the rman backup job from a particular node in 
oracle rac, how can we configure the services to run on 
a particular node in oracle rac

99. What is MGMT database in Oracle 12c?

100. How to log all the dml activity of user on a table

101. If we apply a patch on 12c pdb and cdb will it apply to all or only to cdb

102. What does the AWR DB time represent?

103. I have taken export of A,B,C and D schemas and while 
importing if i mention remap_schema = A:B and

104. what will happen if i don't mention remap_schema=C:D and how it works

105. What is the difference between data guard and physical standby database

106. What are the mandatory background process for a oracle database, a rac and grid

107. Db is dropped but no space is released from asm disk ?

108. What is the difference between crosscheck, validate, obsolete and expired