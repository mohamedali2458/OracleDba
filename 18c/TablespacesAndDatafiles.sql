Creating Tablespaces
====================
create tablespace tools
datafile '/u01/dbfile/o18c/tools01.dbf'
size 100m
extent management local
uniform size 128k
segment space management auto;

create tablespace tools
datafile '/u01/dbfile/o18c/tools01.dbf'
size 100m
autoextend on maxsize 1000m
extent management local
uniform size 128k
segment space management auto;

create tablespace HRDATA encryption using 'AES256' default
storage(encrypt);


define tbsp_large=5G
define tbsp_med=500M
--
create tablespace reg_data
datafile '/u01/dbfile/o18c/reg_data01.dbf'
size &&tbsp_large
extent management local
uniform size 128k
segment space management auto;
--
create tablespace reg_index
datafile '/u01/dbfile/o18c/reg_index01.dbf'
size &&tbsp_med
extent management local
uniform size 128k
segment space management auto;


define tbsp_large=&1
define tbsp_med=&2
--
create tablespace reg_data
datafile '/u01/dbfile/o12c/reg_data01.dbf'
size &&tbsp_large
extent management local
uniform size 128k
segment space management auto;
--
create tablespace reg_index
datafile '/u01/dbfile/o12c/reg_index01.dbf'
size &&tbsp_med
extent management local
uniform size 128k
segment space management auto;


SQL> @cretbsp 5G 500M


Automatic Storage Management (ASM) also simplifies the creation of the tablespace
because it will take the defaults of the DiskGroup and parameters that are set to use
ASM.

SQL> create tablespace HRDATA;


If you ever need to verify the SQL required to re-create an existing tablespace, you
can do so with the DBMS_METADATA package.

SQL> set long 1000000

select dbms_metadata.get_ddl('TABLESPACE',tablespace_name)
from dba_tablespaces;


Renaming a Tablespace
=====================
SQL> alter tablespace tools rename to tools_dev;

When you rename a tablespace, Oracle updates the name of the tablespace in
the data dictionary, control files, and data file headers. Keep in mind that renaming
a tablespace doesn’t rename any associated data files.


Changing a Tablespace’s Write Mode
==================================
SQL> alter tablespace inv_mgmt_rep read only;
SQL> alter tablespace inv_mgmt_rep read write;

SQL> alter table my_tab read only;
SQL> alter table my_tab read write;


Dropping a Tablespace
=====================
SQL> alter tablespace inv_data offline;

SQL> drop tablespace inv_data including contents and datafiles;

You can drop a tablespace whether it is online or offline. The exception to
this is the SYSTEM and SYSAUX tablespaces, which cannot be dropped. It’s always
a good idea to take a tablespace offline before you drop it. By doing so, you can
better determine if an application is using any objects in the tablespace.


If you attempt to drop a tablespace that contains a primary key that is referenced by a
foreign key associated with a table in a tablespace different from the one you are trying to
drop, you receive this error:
ORA-02449: unique/primary keys in table referenced by foreign keys

select p.owner,
p.table_name,
p.constraint_name,
f.table_name referencing_table,
f.constraint_name foreign_key_name,
f.status fk_status
from dba_constraints p,
dba_constraints f,
dba_tables t
where p.constraint_name = f.r_constraint_name
and f.constraint_type = 'R'
and p.table_name = t.table_name
and t.tablespace_name = UPPER('&tablespace_name')
order by 1,2,3,4,5;

SQL> drop tablespace inv_data including contents and data files cascade constraints;

select owner, segment_name,
segment_type
from dba_segments
where
tablespace_name=upper('&&tbsp_name');


Using Oracle Managed Files
==========================
  • DB_CREATE_FILE_DEST
  • DB_CREATE_ONLINE_LOG_DEST_N
  • DB_RECOVERY_FILE_DEST

SQL> alter system set db_create_file_dest='/u01';
SQL> create tablespace inv1;

This statement creates a tablespace named INV1, with a default data file size of
100MB. Keep in mind that you can override the default size of 100MB by specifying a size:

SQL> create tablespace inv2 datafile size 20m;

SQL> select name from v$datafile where name like '%inv%';

One limitation of OMF is that you’re limited to one directory for the placement of
data files. If you want to add data files to a different directory, you can alter the location
dynamically:
SQL> alter system set db_create_file_dest='/u02';

Creating a Bigfile Tablespace
=============================
create bigfile tablespace inv_big_data
datafile '/u01/dbfile/o18c/inv_big_data01.dbf'
size 10g
extent management local
uniform size 128k
segment space management auto;

You can make the bigfile tablespace the default type of tablespace for a database,
using the ALTER DATABASE SET DEFAULT BIGFILE TABLESPACE statement.


Displaying Tablespace Size
==========================
SET PAGESIZE 100 LINES 132 ECHO OFF VERIFY OFF FEEDB OFF SPACE 1 TRIMSP ON
COMPUTE SUM OF a_byt t_byt f_byt ON REPORT
BREAK ON REPORT ON tablespace_name ON pf
COL tablespace_name FOR A17 TRU HEAD 'Tablespace|Name'
COL file_name FOR A40 TRU HEAD 'Filename'
COL a_byt FOR 9,990.999 HEAD 'Allocated|GB'
COL t_byt FOR 9,990.999 HEAD 'Current|Used GB'
COL f_byt FOR 9,990.999 HEAD 'Current|Free GB'
COL pct_free FOR 990.0 HEAD 'File %|Free'
COL pf FOR 990.0 HEAD 'Tbsp %|Free'
COL seq NOPRINT
DEFINE b_div=1073741824
--
SELECT 1 seq, b.tablespace_name, nvl(x.fs,0)/y.ap*100 pf, b.file_name
file_name,
b.bytes/&&b_div a_byt, NVL((b.bytes-SUM(f.bytes))/&&b_div,b.bytes/&&b_div)
t_byt,
NVL(SUM(f.bytes)/&&b_div,0) f_byt, NVL(SUM(f.bytes)/b.bytes*100,0) pct_free
FROM dba_free_space f, dba_data_files b
,(SELECT y.tablespace_name, SUM(y.bytes) fs
FROM dba_free_space y GROUP BY y.tablespace_name) x
,(SELECT x.tablespace_name, SUM(x.bytes) ap
FROM dba_data_files x GROUP BY x.tablespace_name) y
WHERE f.file_id(+) = b.file_id
AND x.tablespace_name(+) = y.tablespace_name
and y.tablespace_name = b.tablespace_name
AND f.tablespace_name(+) = b.tablespace_name
GROUP BY b.tablespace_name, nvl(x.fs,0)/y.ap*100, b.file_name, b.bytes
UNION
SELECT 2 seq, tablespace_name,
j.bf/k.bb*100 pf, b.name file_name, b.bytes/&&b_div a_byt,
a.bytes_used/&&b_div t_byt, a.bytes_free/&&b_div f_byt,
a.bytes_free/b.bytes*100 pct_free
FROM v$temp_space_header a, v$tempfile b
,(SELECT SUM(bytes_free) bf FROM v$temp_space_header) j
,(SELECT SUM(bytes) bb FROM v$tempfile) k
WHERE a.file_id = b.file#
ORDER BY 1,2,4,3;


Altering Tablespace Size
========================
$ df -h | sort

SQL> alter database datafile '/u01/dbfile/o18c/users01.dbf' resize 1g;

SQL> alter tablespace users add datafile '/u02/dbfile/o18c/users02.dbf' size 100m;

SQL> alter tablespace inv_big_data resize 1P;

To add space to a temporary tablespace, first query the V $TEMPFILE view to verify
the current size and location of temporary data files:
SQL> select name, bytes from v$tempfile;

SQL> alter database tempfile '/u01/dbfile/o18c/temp01.dbf' resize 500m;

SQL> alter tablespace temp add tempfile '/u01/dbfile/o18c/temp02.dbf' size 5000m;


Toggling Data Files Offline and Online
======================================
SQL> alter tablespace users offline;

You cannot use the ALTER TABLESPACE statement to place tablespaces offline when
the database is in mount mode.

SQL> alter database datafile 4 offline for drop;

SQL> alter database datafile 4 online;

When you use the OFFLINE FOR DROP clause, no checkpoint is taken on the data
file. This means you need to perform media recovery on the data file before bringing it
online. Performing media recovery applies any changes to the data file that are recorded
in the online redo logs that aren’t in the data files themselves. Before you can bring
online a data file that was taken offline with the OFFLINE FOR DROP clause, you must
perform media recovery on it. You can specify either the entire file name or the file
number:

SQL> recover datafile 4;


Renaming or Relocating a Data File
==================================
A data file must be online for the online move or rename to work. Here is an example
of renaming an online data file:

SQL> alter database move datafile '/u01/dbfile/o18c/users01.dbf' to
'/u01/dbfile/o18c/users_dev01.dbf';

Here is an example of moving a data file to a new mount point:
SQL> alter database move datafile '/u01/dbfile/o18c/hrdata01.dbf' to
'/u02/dbfile/o18c/hrdata01.dbf';

You can also specify the data file number when renaming or moving a data file; for
example,
SQL> alter database move datafile 2 to '/u02/dbfile/o18c/sysuax01.dbf';

If you’re moving a data file and, for any reason, want to keep a copy of the original
file, you can use the KEEP option:
SQL> alter database move datafile 4 to '/u02/dbfile/o18c/users01.dbf' keep;

You can specify the REUSE clause to overwrite an existing file:
SQL> alter database move datafile 4 to '/u01/dbfile/o18c/users01.dbf' reuse;

Oracle will not allow you to overwrite (reuse) a data file that is currently being used
by the database. That is a good thing.


Performing Offline Data File Operations
=======================================
Using SQL and OS Commands
Here are the steps for renaming a data file using SQL commands and OS commands:
1. Use the following query to determine the names of existing data files:
    SQL> select name from v$datafile;

2. Take the data file offline, using either the ALTER TABLESPACE or
ALTER DATABASE DATAFILE statement. You can also shut down your database and then start it
in mount mode; the data files can be moved while in this mode because they aren’t open for use.

3. Physically move the data file to the new location, using either an
OS command (like mv or cp) or the COPY_FILE procedure of the
DBMS_FILE_TRANSFER built-in PL/SQL package.

4. Use either the ALTER TABLESPACE ... RENAME DATAFILE ...
TO statement or the ALTER DATABASE RENAME FILE ... TO
statement to update the control file with the new data file name.

5. Alter the data file online.

SQL> alter tablespace users offline;
$ mv /u01/dbfile/o18c/users01.dbf /u02/dbfile/o18c/users01.dbf

Update the control file with the ALTER TABLESPACE statement:
alter tablespace users
rename datafile
'/u01/dbfile/o18c/users01.dbf'
to
'/u02/dbfile/o18c/users01.dbf';

SQL> alter tablespace users online;


If you want to rename data files from multiple tablespaces in one operation, you can
use the ALTER DATABASE RENAME FILE statement (instead of the ALTER TABLESPACE...
RENAME DATAFILE statement).

SQL> conn / as sysdba
SQL> shutdown immediate;
SQL> startup mount;

Because the database is in mount mode, the data files are not open for use, and thus
there is no need to take the data files offline. Next, physically move the files via the Linux
mv command:
$ mv /u01/dbfile/o18c/system01.dbf /u02/dbfile/o18c/system01.dbf
$ mv /u01/dbfile/o18c/sysaux01.dbf /u02/dbfile/o18c/sysaux01.dbf
$ mv /u01/dbfile/o18c/undotbs01.dbf /u02/dbfile/o18c/undotbs01.dbf

alter database rename file
'/u01/dbfile/o18c/system01.dbf',
'/u01/dbfile/o18c/sysaux01.dbf',
'/u01/dbfile/o18c/undotbs01.dbf'
to
'/u02/dbfile/o18c/system01.dbf',
'/u02/dbfile/o18c/sysaux01.dbf',
'/u02/dbfile/o18c/undotbs01.dbf';

SQL> alter database open;


Re-creating the Control File and OS Commands
============================================
Another way you can relocate all data files in a database is to use a combination of a
re-created control file and OS commands.

1. Create a trace file that contains a CREATE CONTROLFILE statement.
2. Modify the trace file to display the new location of the data files.
3. Shut down the database.
4. Physically move the data files, using an OS command.
5. Start the database in nomount mode.
6. Run the CREATE CONTROLFILE command.

Note When you re-create a control file, be aware that any RMAN information
that was contained in the file will be lost. If you are not using a recovery catalog,
you can repopulate the control file with RMAN backup information, using the RMAN
CATALOG command.

The following example walks through the previous steps. First, you write a CREATE
CONTROLFILE statement to a trace file via an ALTER DATABASE BACKUP CONTROLFILE TO
TRACE statement:

SQL> alter database backup controlfile to trace as '/tmp/mvctrlfile.sql' noresetlogs;

There are a couple of items to note about the prior statement. First, a file
named mvctrlfile.sql is created in the /tmp directory; this file contains a CREATE
CONTROLFILE statement. Second, the prior statement uses the NORESETLOGS clause; this
instructs Oracle to write only one SQL statement to the trace file. If you do not specify
NORESETLOGS, Oracle writes two SQL statements to the trace file: one to re-create the
control file with the NORESETLOGS option and one to re-create the control file with
RESETLOGS.

Next, edit the /tmp/mvctrlfile.sql file, and change the names of the directory
paths to the new locations. Here is a CREATE CONTROLFILE statement for this example:

CREATE CONTROLFILE REUSE DATABASE "O18C" NORESETLOGS NOARCHIVELOG
MAXLOGFILES 16
MAXLOGMEMBERS 4
MAXDATAFILES 1024
MAXINSTANCES 1
MAXLOGHISTORY 876
LOGFILE
GROUP 1 (
'/u01/oraredo/o18c/redo01a.rdo',
'/u02/oraredo/o18c/redo01b.rdo'
) SIZE 50M BLOCKSIZE 512,
GROUP 2 (
'/u01/oraredo/o18c/redo02a.rdo',
'/u02/oraredo/o18c/redo02b.rdo'
) SIZE 50M BLOCKSIZE 512,
GROUP 3 (
'/u01/oraredo/o18c/redo03a.rdo',
'/u02/oraredo/o18c/redo03b.rdo'
) SIZE 50M BLOCKSIZE 512
DATAFILE
'/u01/dbfile/o18c/system01.dbf',
'/u01/dbfile/o18c/sysaux01.dbf',
'/u01/dbfile/o18c/undotbs01.dbf',
'/u01/dbfile/o18c/users01.dbf'
CHARACTER SET AL32UTF8;

Now, shut down the database:
SQL> shutdown immediate;

Physically move the files from the OS prompt. This example uses the Linux mv
command to move the files:
$ mv /u02/dbfile/o18c/system01.dbf /u01/dbfile/o18c/system01.dbf
$ mv /u02/dbfile/o18c/sysaux01.dbf /u01/dbfile/o18c/sysaux01.dbf
$ mv /u02/dbfile/o18c/undotbs01.dbf /u01/dbfile/o18c/undotbs01.dbf
$ mv /u02/dbfile/o18c/users01.dbf /u01/dbfile/o18c/users01.dbf

Start up the database in nomount mode:
SQL> startup nomount;

SQL> @/tmp/mvctrlfile.sql
Control file created.

SQL> alter database open;


Using ASM for Tablespaces
=========================
SQL> alter system set DB_CREATE_FILE_DEST = '+oradata';

To create the tablespace:
SQL> create tablespace hrdata;

SQL> alter system set DB_CREATE_FILE_DEST = '+oradata(datatemplate)';


The dba_tablespaces view will still show the hrdata tablespace as with non-ASM
databases. There are also additional views that will show the files in the disk groups.
To see the ASM disks in a disk group view, v$asm_disk should be queried. The files in the
disk group are seen in the v$asm_file and v$asm_alias views.
From v$asm_file the file number, type, and space information are available and
v$asm_alias brings in the data file name:
  

SQL> select file.file_number, alias.name, file.type
From v$asm_file file, v$asm_alias alias
Where file.group_number=alias.group_number and file.file_number=alias.
file_number;
