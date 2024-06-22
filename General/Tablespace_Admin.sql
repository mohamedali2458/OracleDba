Tablespace Administration

Find Tablespace Utilization

Use below query to find % used space for each tablespace inside database

set colsep |
set linesize 100 pages 100 trimspool on numwidth 14 
col name format a25
col owner format a15 
col "Used (GB)" format a15
col "Free (GB)" format a15 
col "(Used) %" format a15 
col "Size (M)" format a15 
SELECT d.status "Status", d.tablespace_name "Name", 
 TO_CHAR(NVL(a.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Size (GB)", 
 TO_CHAR(NVL(a.bytes - NVL(f.bytes, 0), 0)/1024/1024 /1024,'99999999.99') "Used (GB)", 
 TO_CHAR(NVL(f.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Free (GB)", 
 TO_CHAR(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0), '990.00') "(Used) %"
 FROM sys.dba_tablespaces d, 
 (select tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) a, 
 (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) f WHERE 
 d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+) AND NOT 
 (d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY') 
UNION ALL 
SELECT d.status 
 "Status", d.tablespace_name "Name", 
 TO_CHAR(NVL(a.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Size (GB)", 
 TO_CHAR(NVL(t.bytes,0)/1024/1024 /1024,'99999999.99') "Used (GB)",
 TO_CHAR(NVL((a.bytes -NVL(t.bytes, 0)) / 1024 / 1024 /1024, 0),'99,999,990.90') "Free (GB)", 
 TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "(Used) %" 
 FROM sys.dba_tablespaces d, 
 (select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a, 
 (select tablespace_name, sum(bytes_cached) bytes from v$temp_extent_pool group by tablespace_name) t 
 WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+) AND 
 d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY';


Find Datafiles Associated with Tablespaces

To find datafiles associated with tablespaces

SQL> select tablespace_name, file_name, bytes/1024/1024 
from dba_data_files where tablespace_name='&tablespace_name';

To find temp files associated with a temp tablespace
SQL> select file_name, bytes/1024/1024 from dba_temp_files;


Create Tablespace

To create new tablespace inside database

SQL> Create tablespace test_tbs datafile '/u01/test_tbs_01.dbf' size 50m;

Where
test_tbs is the name of new tablespace
/u01/test_tbs_01.dbf is the location of the datafile
50m is the size of the datafile


Add Space to Tablespace

There are two ways to add space to a tablespace:
Resize existing datafile
Add new datafile

Make sure you have space at OS level before resizing or adding new datafile

Use below command to resize a datafile

SQL> Alter database datafile '/u01/test_tbs_01.dbf' resize 100m;

Use below command to add new datafile to tablespace

SQL> Alter tablespace test_tbs add datafile '/u01/test_tbs_02.dbf' size 50m;


Drop Tablespace

Below command will drop tablespace including all its contents and associated datafiles
SQL> drop tablespace test_tbs including contents and datafiles;


Tablespace Coalesce

Tablespace Coalesce combines all contiguous free extents into larger contiguous extents inside all datafiles
It takes any free extents that are right next to some other free extent and make one bigger free extent
SMON will perform this coalescing in the background but if you need it to happen right now, coalesce will do it

SQL> ALTER TABLESPACE USERS COALESCE;
