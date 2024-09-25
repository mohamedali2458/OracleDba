TABLESPACE MANAGEMENT - 1
=========================
By default each database will have five tablespacesfrom oracle 11g.
    1. System	: contains data dictionary of database
    2. Sysaux	: contains database statistics
    3. Undo	: contains pre-image data
    4. Temporary: temporary operations are performed in this tablespace if PGA is not enough
    5. Users	: default tablespace for all DB users/application schemas

select name from v$tablespace;

select tablespace_name, contents, status from dba_tablespaces order by 2;


To check tablespace information
===============================
select tablespace_name from dba_tablespaces;

select tablespace_name, contents, status from dba_tablespaces order by 2;

Creating Tablespace
===================
Create tablespace tbs1 
datafile '/u01/prod/tbs01.dbf'
size 10m
autoextend on
maxsize 100m
default storage (next 10m);

Adding a datafile to a tablespace
=================================
column tablespace_name format a20
column file_name format a30
select tablespace_name, file_name from dba_data_files order by 1;

alter tablespace tbs1
add datafile '/u01/prod/tbs02.dbf'
size 100m
autoextend on;

Deleting a datafile from a tablespace
=====================================
alter tablespace tbs1
drop datafile '/u01/prod/tbs02.dbf';

column tablespace_name format a20
column file_name format a30
select tablespace_name, file_id, file_name from dba_data_files order by 2;

alter tablespace tbs1
drop datafile 7;

Droping a tablespace
====================
drop tablespace tbs1;
(it will drop tablespace logically at database level)

drop tablespace tbs1 including contents and datafiles;
(it will drop tablespace logically(database level) and physically(o/s level))

Reusing orphan datafile
=======================
create tablespace tbs2
datafile '/u01/prod/tbs02.dbf'
reuse;

Resize a datafile
=================
select file_id, file_name, bytes/1024/1024/1024 "Size_in_Gb" 
from dba_data_files 
order by 1;

alter database datafile '/u01/prod/tbs02.dbf' resize 50m;

alter database datafile 5 resize 50m;


Making a tablespace as read only
================================
alter tablespace tbs1 read only;
select tablespace_name, status from dba_tablespaces;
alter tablespace tbs1 read write;

Making a tablespace offline
===========================
alter tablespace tbs1 offline;
(users cannot access this tablespace in this state)
alter tablespace tbs1 online;

Renaming a tablespace
=====================
alter tablespace tbs1 rename to tbs01;

Renaming a datafile in tablespace
=================================
Steps:
1. make tablespace offline
	alter tablespace tbs1 offline;
2. at OS level rename the datafile
	$cd /u01/prod
	$mv tbs01.dbf tbs02.dbf
3. Update the controlfile of this datafile
	alter database rename file '/u01/prod/tbs01.dbf' to '/u01/prod/tbs02.dbf';
4. Bring the tablespace online
	alter tablespace tbs1 online;
	select tablespace_name, file_name from dba_data_files;








Relocating a datafile in tablespace
===================================
Steps:
1. make tablespace offline
	alter tablespace tbs1 offline;
2. At OS level rename or move the datafile
	$mv /u01/prod/tbs01.dbf /u02/prod/tbs01.dbf
3. update the controlfile for this datafile
	alter database rename file '/u01/prod/tbs01.dbf' to '/u02/prod/tbs01.dbf';
4. online the tablespace
	alter tablespace tbs1 online;
	select tablespace_name, file_name from dba_data_files;

Moving table from one tablespace to another tablespace
======================================================
alter table emp move tablespace tbs1;

Moving index from one tablespace to another tablespace
======================================================
alter index emp_indx rebuild tablespace tbs1;

To check database size
======================
select sum(bytes)/1024/1024/1024 "Size in GB" from dba_data_files;

To check free space in a database
select sum(bytes)/1024/1024/1024 "free space GB" from dba_free_space;




Important Views
===============
v$tablespace

This view displays tablespace information from the control file.
Column				Datatype	Description
TS#				NUMBER		Tablespace number
NAME				VARCHAR2(30)	Tablespace name
INCLUDED_IN_DATABASE_BACKUP	VARCHAR2(3)	Indicates whether the tablespace is included in full database backups using the BACKUP DATABASE RMAN command (YES) or not (NO). NO only if the CONFIGURE EXCLUDE RMAN command was used for this tablespace.
BIGFILE				VARCHAR2(3)	Indicates whether the tablespace is a bigfile tablespace (YES) or not (NO)
FLASHBACK_ON			VARCHAR2(3)	Indicates whether the tablespace participates in FLASHBACK DATABASE operations (YES) or not (NO)
ENCRYPT_IN_BACKUP		VARCHAR2(3)	Possible values are:
						• ON - encryption is turned ON at tablespace level
						• OFF - encryption is turned OFF at tablespace level
						• NULL - encryption is neither explicitly turned on or off at tablespace level (default or when CLEARED).



dba_tablespaces
DBA_TABLESPACES describes all tablespaces in the database.
Related View
USER_TABLESPACES describes the tablespaces accessible to the current user. This view does not display the PLUGGED_IN column.
Column	Datatype	NULL	Description
TABLESPACE_NAME	VARCHAR2(30)	NOT NULL	Name of the tablespace
BLOCK_SIZE	NUMBER	NOT NULL	Tablespace block size
INITIAL_EXTENT	NUMBER	 	Default initial extent size
NEXT_EXTENT	NUMBER	 	Default incremental extent size
MIN_EXTENTS	NUMBER	NOT NULL	Default minimum number of extents
MAX_EXTENTS	NUMBER	 	Default maximum number of extents
PCT_INCREASE	NUMBER	 	Default percent increase for extent size
MIN_EXTLEN	NUMBER	 	Minimum extent size for this tablespace
STATUS	VARCHAR2(9)	 	Tablespace status:
•	ONLINE
•	OFFLINE
•	READ ONLY
CONTENTS	VARCHAR2(9)	 	Tablespace contents:
•	UNDO
•	PERMANENT
•	TEMPORARY
LOGGING	VARCHAR2(9)	 	Default logging attribute:
•	LOGGING
•	NOLOGGING
FORCE_LOGGING	VARCHAR2(3)	 	Indicates whether the tablespace is under force logging mode (YES) or not (NO)
EXTENT_MANAGEMENT	VARCHAR2(10)	 	Indicates whether the extents in the tablespace are dictionary managed (DICTIONARY) or locally managed (LOCAL)
ALLOCATION_TYPE	VARCHAR2(9)	 	Type of extent allocation in effect for the tablespace:
•	SYSTEM
•	UNIFORM
•	USER
PLUGGED_IN	VARCHAR2(3)	 	Indicates whether the tablespace is plugged in (YES) or not (NO)
SEGMENT_SPACE_MANAGEMENT	VARCHAR2(6)	 	Indicates whether the free and used segment space in the tablespace is managed using free lists (MANUAL) or bitmaps (AUTO)
DEF_TAB_COMPRESSION	VARCHAR2(8)	 	Indicates whether default table compression is enabled (ENABLED) or not (DISABLED)
Note: Enabling default table compression indicates that all tables in the tablespace will be created with table compression enabled unless otherwise specified.
RETENTION	VARCHAR2(11)	 	Undo tablespace retention:
•	GUARANTEE - Tablespace is an undo tablespace with RETENTION specified as GUARANTEE
A RETENTION value of GUARANTEE indicates that unexpired undo in all undo segments in the undo tablespace should be retained even if it means that forward going operations that need to generate undo in those segments fail.
•	NOGUARANTEE- Tablespace is an undo tablespace with RETENTION specified as NOGUARANTEE
•	NOT APPLY - Tablespace is not an undo tablespace
BIGFILE	VARCHAR2(3)	 	Indicates whether the tablespace is a bigfile tablespace (YES) or a smallfile tablespace (NO)







dba_data_files
DBA_DATA_FILES describes database files.
Column	Datatype	NULL	Description
FILE_NAME	VARCHAR2(513)	 	Name of the database file
FILE_ID	NUMBER	NOT NULL	File identifier number of the database file
TABLESPACE_NAME	VARCHAR2(30)	NOT NULL	Name of the tablespace to which the file belongs
BYTES	NUMBER	 	Size of the file in bytes
BLOCKS	NUMBER	NOT NULL	Size of the file in Oracle blocks
STATUS	VARCHAR2(9)	 	File status: AVAILABLE or INVALID (INVALID means that the file number is not in use, for example, a file in a tablespace that was dropped)
RELATIVE_FNO	NUMBER	 	Relative file number
AUTOEXTENSIBLE	VARCHAR2(3)	 	Autoextensible indicator
MAXBYTES	NUMBER	 	Maximum file size in bytes
MAXBLOCKS	NUMBER	 	Maximum file size in blocks
INCREMENT_BY	NUMBER	 	Number of tablespace blocks used as autoextension increment. Block size is contained in the BLOCK_SIZE column of the DBA_TABLESPACESview.
USER_BYTES	NUMBER	 	The size of the file available for user data. The actual size of the file minus the USER_BYTES value is used to store file related metadata.
USER_BLOCKS	NUMBER	 	Number of blocks which can be used by the data
ONLINE_STATUS	VARCHAR2(7)	 	Online status of the file:
•	SYSOFF
•	SYSTEM
•	OFFLINE
•	ONLINE
•	RECOVER



dba_extents
DBA_EXTENTS describes the extents comprising the segments in all tablespaces in the database.
Note: that if a datafile (or entire tablespace) is offline in a locally managed tablespace, you will not see any extent information. If an object has extents in an online file of the tablespace, you will see extent information about the offline datafile. However, if the object is entirely in the offline file, a query of this view will not return any records.
Related View
USER_EXTENTS describes the extents comprising the segments owned by the current user's objects. This view does not display the OWNER, FILE_ID, BLOCK_ID, or RELATIVE_FNO columns.
Column	Datatype	NULL	Description
OWNER	VARCHAR2(30)	 	Owner of the segment associated with the extent
SEGMENT_NAME	VARCHAR2(81)	 	Name of the segment associated with the extent
PARTITION_NAME	VARCHAR2(30)	 	Object Partition Name (Set to NULL for non-partitioned objects)
SEGMENT_TYPE	VARCHAR2(18)	 	Type of the segment: INDEX PARTITION, TABLE PARTITION
TABLESPACE_NAME	VARCHAR2(30)	 	Name of the tablespace containing the extent
EXTENT_ID	NUMBER	 	Extent number in the segment
FILE_ID	NUMBER	 	File identifier number of the file containing the extent
BLOCK_ID	NUMBER	 	Starting block number of the extent
BYTES	NUMBER	 	Size of the extent in bytes
BLOCKS	NUMBER	 	Size of the extent in Oracle blocks
RELATIVE_FNO	NUMBER	 	Relative file number of the first extent block






sm$ts_used
sm$ts_free
sm$ts_avail
The sm$ views are an easy way of seeing tablespace space usage. There is also ansm$ts_free view.
There 3 such views: 
desc sm$ts_avail
Desc sm$ts_used
Desc sm$ts_free
all the above with same structure
SQL>desc sm$ts_used
 Name                                      		Null?	Type
 ----------------------------------------- 	-------- 	----------------------------
 TABLESPACE_NAME                                    	VARCHAR2(30)
 BYTES                                              		NUMBER

set pages 9999
coltot_mb format 999,999
coluse_mb format 999,999
colpct_used format 999
select t.tablespace_name, t.bytes/1024/1024 tot_mb, u.bytes/1024/1024 use_mb, 100*u.bytes/t.bytes pct_used
from sys.sm$ts_avail t, sys.sm$ts_used u
where t.tablespace_name = u.tablespace_name(+)
order by 4 desc;








v$datafile
This view contains datafile information from the control file.
Column	Datatype	Description
FILE#	NUMBER	File identification number
CREATION_CHANGE#	NUMBER	Change number at which the datafile was created
CREATION_TIME	DATE	Timestamp of the datafile creation
TS#	NUMBER	Tablespace number
RFILE#	NUMBER	Tablespace relative datafile number
STATUS	VARCHAR2(7)	Type of file (system or user) and its status. Values: OFFLINE, ONLINE, SYSTEM, RECOVER, SYSOFF (an offline file from the SYSTEMtablespace)
ENABLED	VARCHAR2(10)	Describes how accessible the file is from SQL:
•	DISABLED - No SQL access allowed
•	READ ONLY - No SQL updates allowed
•	READ WRITE - Full access allowed
•	UNKNOWN - should not occur unless the control file is corrupted
CHECKPOINT_CHANGE#	NUMBER	SCN at last checkpoint
CHECKPOINT_TIME	DATE	Timestamp of the checkpoint#
UNRECOVERABLE_CHANGE#	NUMBER	Last unrecoverable change number made to this datafile. If the database is in ARCHIVELOGmode, then this column is updated when an unrecoverable operation completes. If the database is not in ARCHIVELOGmode, this column does not get updated.
UNRECOVERABLE_TIME	DATE	Timestamp of the last unrecoverable change. This column is updated only if the database is in ARCHIVELOGmode.
LAST_CHANGE#	NUMBER	Last change number made to this datafile (null if the datafile is being changed)
LAST_TIME	DATE	Timestamp of the last change
OFFLINE_CHANGE#	NUMBER	Offline change number of the last offline range. This column is updated only when the datafile is brought online.
ONLINE_CHANGE#	NUMBER	Online change number of the last offline range
ONLINE_TIME	DATE	Online timestamp of the last offline range
BYTES	NUMBER	Current datafile size (in bytes); 0 if inaccessible
BLOCKS	NUMBER	Current datafile size (in blocks); 0 if inaccessible
CREATE_BYTES	NUMBER	Size when created (in bytes)
BLOCK_SIZE	NUMBER	Block size of the datafile
NAME	VARCHAR2(513)	Name of the datafile
PLUGGED_IN	NUMBER	Describes whether the tablespace is plugged in. The value is 1 if the tablespace is plugged in and has not been made read/write, 0 if not.
BLOCK1_OFFSET	NUMBER	Offset from the beginning of the file to where the Oracle generic information begins. The exact length of the file can be computed as follows: BYTES + BLOCK1_OFFSET.
AUX_NAME	VARCHAR2(513)	Auxiliary name that has been set for this file via CONFIGURE AUXNAME
FIRST_NONLOGGED_SCN	NUMBER	First nonlogged SCN
FIRST_NONLOGGED_TIME	DATE	First nonlogged time


user_tablespaces
USER_TABLESPACES describes the tablespaces accessible to the current user. Its columns (except for PLUGGED_IN) are the same as those in DBA_TABLESPACES.










dba_segments
DBA_SEGMENTS describes the storage allocated for all segments in the database.
Related View
USER_SEGMENTS describes the storage allocated for the segments owned by the current user's objects. This view does not display the OWNER, HEADER_FILE, HEADER_BLOCK, or RELATIVE_FNO columns.
Column	Datatype	NULL	Description
OWNER	VARCHAR2(30)	 	Username of the segment owner
SEGMENT_NAME	VARCHAR2(81)	 	Name, if any, of the segment
PARTITION_NAME	VARCHAR2(30)	 	Object Partition Name (Set to NULL for non-partitioned objects)
SEGMENT_TYPE	VARCHAR2(18)	 	Type of segment: INDEX PARTITION, TABLE PARTITION, TABLE, CLUSTER, INDEX, ROLLBACK, DEFERRED ROLLBACK, TEMPORARY, CACHE, LOBSEGMENT and LOBINDEX
TABLESPACE_NAME	VARCHAR2(30)	 	Name of the tablespace containing the segment
HEADER_FILE	NUMBER	 	ID of the file containing the segment header
HEADER_BLOCK	NUMBER	 	ID of the block containing the segment header
BYTES	NUMBER	 	Size, in bytes, of the segment
BLOCKS	NUMBER	 	Size, in Oracle blocks, of the segment
EXTENTS	NUMBER	 	Number of extents allocated to the segment
INITIAL_EXTENT	NUMBER	 	Size in bytes requested for the initial extent of the segment at create time. (Oracle rounds the extent size to multiples of 5 blocks if the requested size is greater than 5 blocks.)
NEXT_EXTENT	NUMBER	 	Size in bytes of the next extent to be allocated to the segment
MIN_EXTENTS	NUMBER	 	Minimum number of extents allowed in the segment
MAX_EXTENTS	NUMBER	 	Maximum number of extents allowed in the segment
PCT_INCREASE	NUMBER	 	Percent by which to increase the size of the next extent to be allocated
FREELISTS	NUMBER	 	Number of process freelists allocated to this segment
FREELIST_GROUPS	NUMBER	 	Number of freelist groups allocated to this segment
RELATIVE_FNO	NUMBER	 	Relative file number of the segment header
BUFFER_POOL	VARCHAR2(7)	 	Default buffer pool for the object



	
TABLESPACE MANAGEMENT - 2
=========================
select tablespace_name, segment_space_management, extent_management
From dba_tablespaces
order by segment_space_management;

Creating the locally managed tablespace (LMT) with uniform extent size
create tablespace tbs1
datafile '/u01/prod/tbs01.dbf' 
size 50m
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 100k;

Tablespace with ASSM (Automatic Segment Space Management)
create tablespace tbs1
datafile '/u01/prod/tbs01.dbf' 
size 50m
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 100k
SEGMENT SPACE MANAGEMENT auto;

select tablespace_name, segment_space_management, extent_management
from dba_tablespaces
order by 2;

Creating bigfile tablespace
===========================
create bigfile tablespace bigtbs
datafile '/u01/prod/bigtbs01.dbf'
size 3g;

select tablespace_name, bigfile from dba_tablespaces;

Creating a temporary tablespace
===============================
create temporary tablespace temp2
tempfile '/u01/prod/temp02.dbf'
size 50m
autoextend on;

Creating default temporary tablespace of database
=================================================
alter database default temporary tablespace temp2;

Creating temporary tablespace group
===================================
create temporary tablespace temp1
tempfile '/u01/prod/temp01.dbf'
size 50m
TABLESPACE GROUP tempgrp;

select * from dba_tablespace_groups;

Adding/Removing tablespace from a group
=======================================
alter tablespace temp2 tablespace group tmpgrp;
alter tablespace temp3 tablespace group '';

Changing member of a tablespace group
=====================================
alter tablespace temp3 tablespace group tmpgrp2;

Assigning a tablespace group as the default temporary tablespace
================================================================
alter database default temporary tablespace tmpgrp;



Views for temporary tablespace
v$tempfile
This view displays tempfile information.
Column	Datatype	Description
FILE#	NUMBER	Absolute file number
CREATION_CHANGE#	NUMBER	Creation System Change Number (SCN)
CREATION_TIME	DATE	Creation time
TS#	NUMBER	Tablespace number
RFILE#	NUMBER	Relative file number in the tablespace
STATUS	VARCHAR2(7)	Status of the file (OFFLINE|ONLINE)
ENABLED	VARCHAR2(10)	Enabled for read and/or write
BYTES	NUMBER	Size of the file in bytes (from the file header)
BLOCKS	NUMBER	Size of the file in blocks (from the file header)
CREATE_BYTES	NUMBER	Creation size of the file (in bytes)
BLOCK_SIZE	NUMBER	Block size for the file
NAME	VARCHAR2(513)	Name of the file










dba_temp_files
DBA_TEMP_FILES describes all temporary files (tempfiles) in the database.
Column	Datatype	NULL	Description
FILE_NAME	VARCHAR2(513)	 	Name of the database temp file
FILE_ID	NUMBER	 	File identifier number of the database temp file
TABLESPACE_NAME	VARCHAR2(30)	NOT NULL	Name of the tablespace to which the file belongs
BYTES	NUMBER	 	Size of the file (in bytes)
BLOCKS	NUMBER	 	Size of the file (in Oracle blocks)
STATUS	CHAR(9)	 	File status:
•	AVAILABLE
RELATIVE_FNO	NUMBER	 	Tablespace-relative file number
AUTOEXTENSIBLE	VARCHAR2(3)	 	Indicates whether the file is autoextensible (YES) or not (NO)
MAXBYTES	NUMBER	 	maximum size of the file (in bytes)
MAXBLOCKS	NUMBER	 	Maximum size of the file (in Oracle blocks)
INCREMENT_BY	NUMBER	 	Default increment for autoextension
USER_BYTES	NUMBER	 	Size of the useful portion of the file (in bytes)
USER_BLOCKS	NUMBER	 	Size of the useful portion of the file (in Oracle blocks)


dba_tablespace_groups
DBA_TABLESPACE_GROUPS describes all tablespace groups in the database.
Column	Datatype	NULL	Description
GROUP_NAME	VARCHAR2(30)	NOT NULL	Name of the tablespace group
TABLESPACE_NAME	VARCHAR2(30)	NOT NULL	Name of the temporary tablespace





Creating UNDO Tablespaces
=========================
create undo tablespace undotbs_02 
datafile '/u01/prod/undo0201.dbf'
size 20m
autoextend on;

alter tablespace undotbs_02
add datafile '/u01/prod/undo0202.dbf'
size 10m
autoextend on;

Switching Undo Tablespaces
==========================
alter system set undo_tablespace = undotbs_02 scope = both;

Views for UNDO tablespace
v$undostat
V$UNDOSTAT displays a histogram of statistical data to show how well the system is working. The available statistics include undo space consumption, transaction concurrency, and length of queries executed in the instance. You can use this view to estimate the amount of undo space required for the current workload. Oracle uses this view to tune undo usage in the system. The view returns null values if the system is in manual undo management mode.
Each row in the view keeps statistics collected in the instance for a 10-minute interval. The rows are in descending order by the BEGIN_TIME column value. Each row belongs to the time interval marked by (BEGIN_TIME, END_TIME). Each column represents the data collected for the particular statistic in that time interval. The first row of the view contains statistics for the (partial) current time period. The view contains a total of 1008 rows, spanning a 7 day cycle.
Column	Datatype	Description
BEGIN_TIME	DATE	Identifies the beginning of the time interval
END_TIME	DATE	Identifies the end of the time interval
UNDOTSN	NUMBER	Represents the last active undo tablespace in the duration of time. The tablespace ID of the active undo tablespace is returned in this column. If more than one undo tablespace was active in that period, the active undo tablespace that was active at the end of the period is reported.
UNDOBLKS	NUMBER	Represents the total number of undo blocks consumed. You can use this column to obtain the consumption rate of undo blocks, and thereby estimate the size of the undo tablespace needed to handle the workload on your system.
TXNCOUNT	NUMBER	Identifies the total number of transactions executed within the period
MAXQUERYLEN	NUMBER	Identifies the length of the longest query (in seconds) executed in the instance during the period. You can use this statistic to estimate the proper setting of the UNDO_RETENTION initialization parameter. The length of a query is measured from the cursor open time to the last fetch/execute time of the cursor. Only the length of those cursors that have been fetched/executed during the period are reflected in the view.
MAXQUERYID	VARCHAR2(13)	SQL identifier of the longest running SQL statement in the period
MAXCONCURRENCY	NUMBER	Identifies the highest number of transactions executed concurrently within the period
UNXPSTEALCNT	NUMBER	Number of attempts to obtain undo space by stealing unexpired extents from other transactions
UNXPBLKRELCNT	NUMBER	Number of unexpired blocks removed from certain undo segments so they can be used by other transactions
UNXPBLKREUCNT	NUMBER	Number of unexpired undo blocks reused by transactions
EXPSTEALCNT	NUMBER	Number of attempts to steal expired undo blocks from other undo segments
EXPBLKRELCNT	NUMBER	Number of expired undo blocks stolen from other undo segments
EXPBLKREUCNT	NUMBER	Number of expired undo blocks reused within the same undo segments
SSOLDERRCNT	NUMBER	Identifies the number of times the error ORA-01555 occurred. You can use this statistic to decide whether or not the UNDO_RETENTION initialization parameter is set properly given the size of the undo tablespace. Increasing the value of UNDO_RETENTION can reduce the occurrence of this error.
NOSPACEERRCNT	NUMBER	Identifies the number of times space was requested in the undo tablespace and there was no free space available. That is, all of the space in the undo tablespace was in use by active transactions. The corrective action is to add more space to the undo tablespace.
ACTIVEBLKS	NUMBER	Total number of blocks in the active extents of the undo tablespace for the instance at the sampled time in the period
UNEXPIREDBLKS	NUMBER	Total number of blocks in the unexpired extents of the undo tablespace for the instance at the sampled time in the period
EXPIREDBLKS	NUMBER	Total number of blocks in the expired extents of the undo tablespace for the instance at the sampled time in the period
TUNED_UNDORETENTION	NUMBER	System tuned value indicating the period for which undo is being retained


v$rollstat
This view contains rollback segment statistics.
Column	Datatype	Description
USN	NUMBER	Rollback segment number
LATCH	NUMBER	Latch for the rollback segment
EXTENTS	NUMBER	Number of extents in the rollback segment
RSSIZE	NUMBER	Size (in bytes) of the rollback segment. This value differs by the number of bytes in one database block from the value of the BYTES column of the ALL/DBA/USER_SEGMENTS views.
See Also: Oracle Database Administrator's Guide.

WRITES	NUMBER	Number of bytes written to the rollback segment
XACTS	NUMBER	Number of active transactions
GETS	NUMBER	Number of header gets
WAITS	NUMBER	Number of header waits
OPTSIZE	NUMBER	Optimal size of the rollback segment
HWMSIZE	NUMBER	High-watermark of rollback segment size
SHRINKS	NUMBER	Number of times the size of a rollback segment decreases
WRAPS	NUMBER	Number of times rollback segment is wrapped
EXTENDS	NUMBER	Number of times rollback segment size is extended
AVESHRINK	NUMBER	Average shrink size
AVEACTIVE	NUMBER	Current size of active extents, averaged over time.
STATUS	VARCHAR2(15)	Rollback segment status:
•	ONLINE
•	PENDING OFFLINE
•	OFFLINE
•	FULL
CUREXT	NUMBER	Current extent
CURBLK	NUMBER	Current block


v$transaction
V$TRANSACTION lists the active transactions in the system.
Column	Datatype	Description
ADDR	RAW(4 | 8)	Address of the transaction state object
XIDUSN	NUMBER	Undo segment number
XIDSLOT	NUMBER	Slot number
XIDSQN	NUMBER	Sequence number
UBAFIL	NUMBER	Undo block address (UBA) filenum
UBABLK	NUMBER	UBA block number
UBASQN	NUMBER	UBA sequence number
UBAREC	NUMBER	UBA record number
STATUS	VARCHAR2(16)	Status
START_TIME	VARCHAR2(20)	Start time (wall clock)
START_SCNB	NUMBER	Start system change number (SCN) base
START_SCNW	NUMBER	Start SCN wrap
START_UEXT	NUMBER	Start extent number
START_UBAFIL	NUMBER	Start UBA file number
START_UBABLK	NUMBER	Start UBA block number
START_UBASQN	NUMBER	Start UBA sequence number
START_UBAREC	NUMBER	Start UBA record number
SES_ADDR	RAW(4 | 8)	User session object address
FLAG	NUMBER	Flag
SPACE	VARCHAR2(3)	YES if a space transaction
RECURSIVE	VARCHAR2(3)	YES if a recursive transaction
NOUNDO	VARCHAR2(3)	YES if a no undo transaction
PTX	VARCHAR 2(3)	YES if parallel transaction
NAME	VARCHAR2(256)	Name of a named transaction
PRV_XIDUSN	NUMBER	Previous transaction undo segment number
PRV_XIDSLT	NUMBER	Previous transaction slot number
PRV_XIDSQN	NUMBER	Previous transaction sequence number
PTX_XIDUSN	NUMBER	Rollback segment number of the parent XID
PTX_XIDSLT	NUMBER	Slot number of the parent XID
PTX_XIDSQN	NUMBER	Sequence number of the parent XID
DSCN-B	NUMBER	This column is obsolete and maintained for backward compatibility. The value of this column is always equal to the value in DSCN_BASE.
DSCN-W	NUMBER	This column is obsolete and maintained for backward compatibility. The value of this column is always equal to the value in DSCN_WRAP.
USED_UBLK	NUMBER	Number of undo blocks used
USED_UREC	NUMBER	Number of undo records used
LOG_IO	NUMBER	Logical I/O
PHY_IO	NUMBER	Physical I/O
CR_GET	NUMBER	Consistent gets
CR_CHANGE	NUMBER	Consistent changes
START_DATE	DATE	Start time (wall clock)
DSCN_BASE	NUMBER	Dependent SCN base
DSCN_WRAP	NUMBER	Dependent SCN wrap
START_SCN	NUMBER	Start SCN
DEPENDENT_SCN	NUMBER	Dependent SCN
XID	RAW(8)	Transaction XID
PRV_XID	RAW(8)	Previous transaction XID
PTX_XID	RAW(8)	Parent transaction XID






dba_undo_extents
DBA_UNDO_EXTENTS describes the extents comprising the segments in all undo tablespaces in the database.
Column	Datatype	NULL	Description
OWNER	CHAR(3)	 	Owner of the undo tablespace
SEGMENT_NAME	VARCHAR2(30)	NOT NULL	Name of the undo segment
TABLESPACE_NAME	VARCHAR2(30)	NOT NULL	Name of the undo tablespace
EXTENT_ID	NUMBER	 	ID of the extent
FILE_ID	NUMBER	NOT NULL	File identifier number of the file containing the extent
BLOCK_ID	NUMBER	 	Start block number of the extent
BYTES	NUMBER	 	Size of the extent (in bytes)
BLOCKS	NUMBER	 	Size of the extent (in blocks)
RELATIVE_FNO	NUMBER	 	Relative number of the file containing the segment header
COMMIT_JTIME	NUMBER	 	Commit time of the undo in the extent expressed as Julian time. This column is deprecated, but retained for backward compatibility reasons.
COMMIT_WTIME	VARCHAR2(20)	 	Commit time of the undo in the extent expressed as Wallclocktime.This column is deprecated, but retained for backward compatibility reasons
STATUS	VARCHAR2(9)	 	Transaction Status of the undo in the extent:
•	ACTIVE
•	EXPIRED
•	UNEXPIRED








View for Sysaux tablespace
==========================
v$sysaux_occupants
V$SYSAUX_OCCUPANTS displays SYSAUX tablespace occupant information.
Column			Datatype	Description
OCCUPANT_NAME		VARCHAR2(64)	Occupant name
OCCUPANT_DESC		VARCHAR2(64)	Occupant description
SCHEMA_NAME		VARCHAR2(64)	Schema name for the occupant
MOVE_PROCEDURE		VARCHAR2(64)	Name of the move procedure; null if not applicable
MOVE_PROCEDURE_DESC	VARCHAR2(64)	Description of the move procedure
SPACE_USAGE_KBYTES	NUMBER	Current space usage of the occupant (in KB)







Select tablespace_name, extent_management
from dba_tablespaces;

col tablespace_name format a20
col file_name format a50
select tablespace_name, file_name from dba_data_files;

select tablespace_name, file_name from dba_temp_files;



— database level space:
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


— generate script to add 1000m to each datafile:

set pages 9999 lines 112
select 'alter database datafile '''||file_name||''' resize '||(bytes+1000*1024*1024)/1024/1024||' m ;'
from dba_data_files where tablespace_name in ('USERS')
order by 1
/

