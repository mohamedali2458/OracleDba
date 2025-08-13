--TABLESPACE MANAGEMENT - 1
set linesize 300
col name for a30
select ts#, name, bigfile, flashback_on, con_id from v$tablespace order by con_id,ts#;

select tablespace_name, contents, status from dba_tablespaces order by 2;

--To check tablespace information
select tablespace_name from dba_tablespaces;

select tablespace_name, contents, status from dba_tablespaces order by 2;

--Creating Tablespace
create tablespace tbs1 
datafile '/u01/prod/tbs01.dbf'
size 10m
autoextend on
maxsize 100m
default storage (next 10m);

--Adding a datafile to a tablespace
column tablespace_name format a20
column file_name format a90
select tablespace_name, file_name from dba_data_files order by 1;

alter tablespace tbs1
add datafile '/u01/prod/tbs02.dbf'
size 100m
autoextend on;

--Deleting a datafile from a tablespace
alter tablespace tbs1
drop datafile '/u01/prod/tbs02.dbf';

column tablespace_name format a20
column file_name format a90
select tablespace_name, file_id, file_name from dba_data_files order by 2;

alter tablespace tbs1
drop datafile 7;

--Droping a tablespace
drop tablespace tbs1;
(it will drop tablespace logically at database level)

drop tablespace tbs1 including contents and datafiles;
(it will drop tablespace logically(database level) and physically(o/s level))

--Reusing orphan datafile
create tablespace tbs2
datafile '/u01/prod/tbs02.dbf'
reuse;

--Resize a datafile
select file_id, file_name, bytes/1024/1024 mb 
from dba_data_files order by 1;

alter database datafile '/u01/prod/tbs02.dbf' resize 50m;

alter database datafile 5 resize 50m;

--Making a tablespace read only
alter tablespace tbs1 read only;

select tablespace_name, status from dba_tablespaces;

alter tablespace tbs1 read write;

--Making a tablespace offline
alter tablespace tbs1 offline;
(users cannot access this tablespace in this state)

alter tablespace tbs1 online;

--Renaming a tablespace
alter tablespace tbs1 rename to tbs01;

--Renaming a datafile in tablespace
Steps:
1. make tablespace offline
	alter tablespace tbs1 offline;
2. at OS level rename the datafile
	$cd /u01/prod
	$mv tbs01.dbf tbs02.dbf
3. Update the controlfile for this datafile
alter database rename file '/u01/prod/tbs01.dbf' to'/u01/prod/tbs02.dbf';
4. Online the tablespace
	alter tablespace tbs1 online;

	select tablespace_name, file_name from dba_data_files;






--Relocating a datafile in tablespace
Steps:
1. make tablespace offline
	alter tablespace tbs1 offline;
2. At os level rename or move the datafile
	$mv /u01/prod/tbs01.dbf /u02/prod/tbs01.dbf
3. update the controlfile for this datafile
	alter database rename file '/u01/prod/tbs01.dbf' to
	'/u02/prod/tbs01.dbf';
4. online the tablespace
	alter tablespace tbs1 online;
	
	select tablespace_name, file_name from dba_data_files;

--Moving table from one tablespace to another tablespace
alter table emp move tablespace tbs1;

--Moving index from one tablespace to another tablespace
alter index emp_indx rebuild tablespace tbs1;

--To check database size
select sum(bytes)/1024/1024 "Size in MB" from dba_data_files;

--To check free space in a database
select sum(bytes)/1024/1024 "free space" from dba_free_space;




--Important Views
v$tablespace : This view displays tablespace information from the control file.

dba_tablespaces : describes all tablespaces in the database.

USER_TABLESPACES : describes the tablespaces accessible to the current user. This view does not display the PLUGGED_IN column.

dba_data_files : describes database files.

dba_extents : describes the extents comprising the segments in all tablespaces in the database.
Note: that if a datafile (or entire tablespace) is offline in a locally managed tablespace, you will not see any extent information. If an object has extents in an online file of the tablespace, you will see extent information about the offline datafile. However, if the object is entirely in the offline file, a query of this view will not return any records.

USER_EXTENTS : describes the extents comprising the segments owned by the current user's objects. This view does not display the OWNER, FILE_ID, BLOCK_ID, or RELATIVE_FNO columns.


sm$ts_used
sm$ts_free
sm$ts_avail
The sm$ views are an easy way of seeing tablespace space usage. There is also ansm$ts_free view.
There 3 such views: 
desc sm$ts_avail
Desc sm$ts_used
Desc sm$ts_free
all the above with same structure

set pages 9999
coltot_mb format 999,999
coluse_mb format 999,999
colpct_used format 999
select t.tablespace_name, t.bytes/1024/1024 tot_mb, u.bytes/1024/1024 use_mb, 100*u.bytes/t.bytes pct_used
from sys.sm$ts_avail t, sys.sm$ts_used u
where t.tablespace_name = u.tablespace_name(+)
order by 4 desc;

v$datafile : This view contains datafile information from the control file.

user_tablespaces : describes the tablespaces accessible to the current user. Its columns (except for PLUGGED_IN) are the same as those in DBA_TABLESPACES.


dba_segments : describes the storage allocated for all segments in the database.

USER_SEGMENTS : describes the storage allocated for the segments owned by the current user's objects. This view does not display the OWNER, HEADER_FILE, HEADER_BLOCK, or RELATIVE_FNO columns.




--TABLESPACE MANAGEMENT - 2
select tablespace_name, segment_space_management, extent_management
From dba_tablespaces
order by segment_space_management;

--Creating the locally managed tablespace (LMT) with uniform extent size
create tablespace tbs1
datafile '/u01/prod/tbs01.dbf' 
size 50m
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 100k;

--Tablespace with ASSM (Automatic Segment Space Management)
create tablespace tbs1
datafile '/u01/prod/tbs01.dbf' 
size 50m
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 100k
SEGMENT SPACE MANAGEMENT auto;

select tablespace_name, segment_space_management, extent_management
from dba_tablespaces
order by 2;

--creating bigfile tablespace
create bigfile tablespace bigtbs
datafile '/u01/prod/bigtbs01.dbf'
size 3g;

select tablespace_name, bigfile from dba_tablespaces;

--Creating a temporary tablespace
create temporary tablespace temp2
tempfile '/u01/prod/temp02.dbf'
size 50m
autoextend on;

--Creating default temporary tablespace of database
alter database default temporary tablespace temp2;

--Creating temporary tablespace group
create temporary tablespace temp1
tempfile '/u01/prod/temp01.dbf'
size 50m
TABLESPACE GROUP tempgrp;

select * from dba_tablespace_groups;

--Adding/Removing tablespace from a group
alter tablespace temp2 tablespace group tmpgrp;

alter tablespace temp3 tablespace group '';

--Changing member of a tablespace group
alter tablespace temp3 tablespace group tmpgrp2;

--Assigning a tablespace group as the default temporary tablespace
alter database default temporary tablespace tmpgrp;



--Views for temporary tablespace
v$tempfile : This view displays tempfile information.

dba_temp_files : describes all temporary files (tempfiles) in the database.

dba_tablespace_groups : describes all tablespace groups in the database.

--Creating UNDO Tablespaces
create undo tablespace undotbs_02 
datafile '/u01/prod/undo0201.dbf'
size 20m
autoextend on;

alter tablespace undotbs_02
add datafile '/u01/prod/undo0202.dbf'
size 10m
autoextend on;

--Switching Undo Tablespaces
alter system set undo_tablespace = undotbs_02 scope=both;

--Views for UNDO tablespace
v$undostat : displays a histogram of statistical data to show how well the system is working. The available statistics include undo space consumption, transaction concurrency, and length of queries executed in the instance. You can use this view to estimate the amount of undo space required for the current workload. Oracle uses this view to tune undo usage in the system. The view returns null values if the system is in manual undo management mode.
Each row in the view keeps statistics collected in the instance for a 10-minute interval. The rows are in descending order by the BEGIN_TIME column value. Each row belongs to the time interval marked by (BEGIN_TIME, END_TIME). Each column represents the data collected for the particular statistic in that time interval. The first row of the view contains statistics for the (partial) current time period. The view contains a total of 1008 rows, spanning a 7 day cycle.

v$rollstat : This view contains rollback segment statistics.

v$transaction : lists the active transactions in the system.

dba_undo_extents : describes the extents comprising the segments in all undo tablespaces in the database.

--View for Sysaux tablespace
v$sysaux_occupants : displays SYSAUX tablespace occupant information.


select tablespace_name, extent_management
from dba_tablespaces;

col tablespace_name format a20
col file_name format a90
select tablespace_name, file_name from dba_data_files;

select tablespace_name, file_name from dba_temp_files;



-- database level space:
select sum(bytes)/1024/1024/1024 allocated_gb
from (
select sum(bytes) bytes from dba_data_files
union all
select sum(bytes) bytes from dba_temp_files
union all
select sum(l.bytes) bytes from v$log l, v$logfile f where l.group# = f.group#)
/

select sum(bytes)/1024/1024/1024 used_gb
from sys.sm$ts_used
/


-- generate script to add 1000m to each datafile:

set pages 9999 lines 112
select 'alter database datafile '''||file_name||''' resize '||(bytes+1000*1024*1024)/1024/1024||' m ;'
from dba_data_files where tablespace_name in ('USERS')
order by 1
/

