About Oracle Statistics
=======================
1. Introduction
2. About *_TAB_MODIFICATIONS
3. Identify STALE STATS
4. Gather STATS
       4.1 DATABASE Level
       4.2 SCHEMA Level
       4.3 TABLE Level
       4.4 INDEX Level
5. SYSTEM STATISTICS
6. How lock/unlock statistics on table


Introduction

What are statistics?

Ans: Input to the Cost-Based Optimizer, Provide information on User Objects
	Table, Partition, Subpartition
	Columns
	Index, Index Partition, Index Subpartition
System
Dictionary
Memory structure (X$)

Statistics on a table are considered stale when more than STALE_PERCENT (default 10%) 
of the rows are changed (total number of inserts, deletes, updates) in the table. 

Oracle monitors the DML activity for all tables and records it in the SGA.
  
The monitoring information is periodically flushed to disk, and is exposed in the *_TAB_MODIFICATIONS view.

Why do we care about statistics?
Poor statistics usually lead to poor plans.
Collecting good quality stats is not straightforward.
Collecting good quality stats may be time consuming.
Improving statistics quality improves the chance to find an optimal plan (usually).
The higher the sample, the higher the accuracy.
The higher the sample, the longer it takes to collect.
The longer it takes, the less frequent we can collect fresh stats!.

If your data changes frequently, then

If you have plenty of resources:
Gather statistics often and with a very large sample size

If your resources are limited: 
Use AUTO_SAMPLE_SIZE (11g)
Use a smaller sample size (try to avoid this)

If your data doesn’t change frequently: 
Gather statistics less often and with a very large sample size


Recommended syntax

/*
Assuming we want Oracle to determine where to put histograms (instead of specifying the list manually):

In 10g avoid AUTO_SAMPLE_SIZE

exec dbms_stats.gather_table_stats('owner', 'table_name', estimate_percent => NNN,granularity => “it depends”);

In 11g use AUTO_SAMPLE_SIZE but keep an eye open. 
exec dbms_stats.gather_table_stats('owner', 'table_name');
*/

About *_TAB_MODIFICATIONS

When querying *_TAB_MODIFICATIONS view you should ensure that you run DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO 
before doing so in order to obtain accurate results.

Before

--  exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO; -- 

SQL> select table_name, inserts, updates, deletes from dba_tab_modifications where table_name='TEST';

no rows selected

SQL>


After 

SQL> exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;

PL/SQL procedure successfully completed.

SQL> select table_name, inserts, updates, deletes from dba_tab_modifications where table_name='BIG_TABLE';

TABLE_NAME                        INSERTS    UPDATES    DELETES
------------------------------ ---------- ---------- ----------
BIG_TABLE                             100          0          0

SQL>

  
Identify STALE STATS:

col TABLE_NAME for a30
col PARTITION_NAME for a20
col SUBPARTITION_NAME for a20
select OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, NUM_ROWS, LAST_ANALYZED 
from DBA_TAB_STATISTICS where STALE_STATS='YES';

OR

select OWNER, TABLE_NAME, LAST_ANALYZED, STALE_STATS 
from DBA_TAB_STATISTICS 
where OWNER='&OWNER' AND STALE_STATS='YES';


Gather STATS

CASCADE => TRUE : Gather statistics on the indexes as well. If not used Oracle will determine whether to collect it or not.
DEGREE => 4: Degree of parallelism.
ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE : (DEFAULT) Auto set the sample size % for skew(distinct) values (accurate and faster than setting a manual sample size).
METHOD_OPT=> : For gathering Histograms:
FOR COLUMNS SIZE AUTO : You can specify one column between “” instead of all columns.
FOR ALL COLUMNS SIZE REPEAT : Prevent deletion of histograms and collect it only for columns already have histograms.
FOR ALL COLUMNS : Collect histograms on all columns.
FOR ALL COLUMNS SIZE SKEWONLY : Collect histograms for columns have skewed value should test skewness first
FOR ALL INDEXED COLUMNS : Collect histograms for columns have indexes only.


DATABASE Level
Gathering statistics for all objects in database, cascade will include indexes

exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;
select OWNER,TABLE_NAME,LAST_ANALYZED,STALE_STATS from DBA_TAB_STATISTICS where STALE_STATS='YES';

exec dbms_stats.gather_database_stats(cascade=>TRUE, method_opt => 'FOR ALL COLUMNS SIZE AUTO');
OR
-- For faster execution
EXEC DBMS_STATS.GATHER_DATABASE_STATS(ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE,degree=>6);
OR
EXEC DBMS_STATS.GATHER_DATABASE_STATS(ESTIMATE_PERCENT=>dbms_stats.auto_sample_size,CASCADE => TRUE,degree => 4);


SCHEMA level
Gathering statistics for all objects in a schema, cascade will include indexes. If not used Oracle will determine whether to collect it or not.

exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;
select OWNER,TABLE_NAME,LAST_ANALYZED,STALE_STATS from DBA_TAB_STATISTICS where STALE_STATS='YES' and OWNER='&owner';

set timing on
exec dbms_stats.gather_schema_stats(ownname=>'&schema_name', CASCADE=>TRUE,ESTIMATE_PERCENT=>dbms_stats.auto_sample_size,degree =>4);
OR
exec dbms_stats.gather_schema_stats(ownname=>'&schema_name',ESTIMATE_PERCENT=>dbms_stats.auto_sample_size,degree =>4);
-- CASCADE is not included here. Let Oracle will determine whether to collect statatics on indexes or not.
OR
EXEC DBMS_STATS.GATHER_SCHEMA_STATS ('&schema_name'); Will gather stats on 100% of schema tables.

  
TABLE Level

-- The CASCADE parameter determines whether or not statistics are gathered for the indexes on a table.

exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;
SELECT OWNER,TABLE_NAME,LAST_ANALYZED,STALE_STATS from DBA_TAB_STATISTICS WHERE TABLE_NAME='&TNAME';

exec dbms_stats.gather_table_stats(ownname=>'&Schema_name',tabname=>'&Table_name',estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE,cascade=>TRUE,degree =>4);
OR
-- Gather statistics on the table with histograms being automatically created
exec dbms_stats.gather_table_stats('&SCHEMA_NAME','&Table_name');

  
Index Statistics

exec DBMS_STATS.GATHER_INDEX_STATS(ownname => '&OWNER',indname =>'&INDEX_NAME',estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE);


SYSTEM STATISTICS

What is system statistics:

System statistics are statistics about CPU speed and IO performance, it enables the CBO to
effectively cost each operation in an execution plan. Introduced in Oracle 9i.

Why gathering system statistics:

Oracle highly recommends gathering system statistics during a representative workload,
ideally at peak workload time, in order to provide more accurate CPU/IO cost estimates to the optimizer.
You only have to gather system statistics once.

There are two types of system statistics (NOWORKLOAD statistics & WORKLOAD statistics):

NOWORKLOAD statistics:

This will simulates a workload -not the real one but a simulation- and will not collect full statistics, 
it's less accurate than "WORKLOAD statistics" but if you can't capture the statistics during a typical 
workload you can use noworkload statistics.

To gather noworkload statistics:
SQL> execute dbms_stats.gather_system_stats(); 

WORKLOAD statistics:

This will gather statistics during the current workload [which supposed to be representative of actual system I/O and CPU workload on the DB].
To gather WORKLOAD statistics:
SQL> execute dbms_stats.gather_system_stats('start');
Once the workload window ends after 1,2,3.. hours or whatever, stop the system statistics gathering:
SQL> execute dbms_stats.gather_system_stats('stop');
You can use time interval (minutes) instead of issuing start/stop command manually:
SQL> execute dbms_stats.gather_system_stats('interval',60); 

Check the system values collected:

col pname format a20
col pval2 format a40
select * from sys.aux_stats$; 

cpuspeedNW:  Shows the noworkload CPU speed, (average number of CPU cycles per second).
ioseektim:   The sum of seek time, latency time, and OS overhead time.
iotfrspeed:  I/O transfer speed, tells optimizer how fast the DB can read data in a single read request.
cpuspeed:    Stands for CPU speed during a workload statistics collection.
maxthr:      The maximum I/O throughput.
slavethr:    Average parallel slave I/O throughput.
sreadtim:    The Single Block Read Time statistic shows the average time for a random single block read.
mreadtim:    The average time (seconds) for a sequential multiblock read.
mbrc:        The average multiblock read count in blocks.

Notes:
-When gathering NOWORKLOAD statistics it will gather (cpuspeedNW, ioseektim, iotfrspeed) system statistics only.
-Above values can be modified manually using DBMS_STATS.SET_SYSTEM_STATS procedure.
-According to Oracle, collecting workload statistics doesnt impose an additional overhead on your system.

  
Delete system statistics:

SQL> execute dbms_stats.delete_system_stats();

How lock/unlock statistics on table

1. Create table and verify 

SQL> create table raj ( x number );
Table created.

SQL> SELECT stattype_locked FROM dba_tab_statistics WHERE table_name='RAJ' and owner='SH';

STATT
-----
	 <---- Output NULL. Hence table unlocked. It will allow to gather stats on this table


2. Lock stats

SQL> exec dbms_stats.lock_table_stats('SH', 'RAJ');
PL/SQL procedure successfully completed.

 
3. Verify

SQL> SELECT stattype_locked FROM dba_tab_statistics WHERE table_name='RAJ' and owner='SH';

STATT
-----
ALL <---- Hence table locked. It will not allow to gather stats on this table


Tryied to gather stats, but fails

SQL> exec dbms_stats.gather_table_stats('sh', 'raj');
BEGIN dbms_stats.gather_table_stats('sh', 'raj'); END;

*
ERROR at line 1:
ORA-20005: object statistics are locked (stattype = ALL)  <-- LOCKED

4. Unlock

SQL> exec dbms_stats.unlock_table_stats('SH', 'RAJ');
PL/SQL procedure successfully completed.

SQL> SELECT stattype_locked FROM dba_tab_statistics WHERE table_name='RAJ' and owner='SH';

STATT
-----
	<----its unlocked, It will allow to gather stats on this table

SQL> exec dbms_stats.gather_table_stats('sh', 'raj');
PL/SQL procedure successfully completed.

SQL>

Locked: ALL
Unlocked: NULL
Other:

select status from dba_autotask_client where client_name = ‘auto optimizer stats collection’;

DBA_TAB_MODIFICATIONS Refreshed Only Once a Day from 10g (Doc ID 1476052.1)
