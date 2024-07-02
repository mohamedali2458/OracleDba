--alapati

select user,sysdate from dual;

--Managing Tablespaces

--MIGRATING FROM DICTIONARY-MANAGED TO LOCALLY MANAGED TABLESPACES
/*
Although locally managed tablespaces are the default in the Oracle Database 
11g release, if you are upgrading an older database to the Oracle Database 
11g release, you may want to migrate your tablespaces from being dictionary
managed to locally managed. You can simply create new tablespaces, 
which will be locally managed by default, and then migrate all your 
tables to the new tablespaces using the ALTER TABLE command, as shown here:
*/

ALTER TABLE emp MOVE TABLESPACE tbsp_new;

--In order to move your indexes, use the ALTER INDEX REBUILD command, as shown here:

ALTER INDEX emp_pk_idx REBUILD TABLESPACE tbsp_idx_new;

/*
Once you finish migrating all your objects to the new locally managed 
tablespaces, drop your old tablespaces to reclaim the space.

If you don't want to create new tablespaces and go through the trouble of migrating all tables and indexes, you can
use the PL/SQL package DBMS_SPACE_ADMIN, which enables you to perform the tablespace migration. You first
need to migrate all the other tablespaces to a local management mode before you migrate the System tablespace. If
you migrate your System tablespace from dictionary managed to locally managed first, all other tablespaces become
read-only. Make sure that you first take a cold backup of the database before performing the tablespace migration.
Here's an example of how you can migrate a dictionary-managed tablespace (USERS) to a locally managed
tablespace:
*/

EXECUTE dbms_space_admin.tablespace_migrate_to_local ('USERS');

/*
The TABLESPACE_MIGRATE_TO_LOCAL procedure can be used online, while users are selecting and modifying
data. However, if the DML operations need a new extent to be allocated, the operations will be blocked until the
migration is completed.

Once you've migrated all your other tablespaces to locally managed tablespaces, you can move the System tablespace.
Here's the command (you'll have to perform a few housekeeping chores beforehand, like making other
tablespaces read only, etc.):
*/

EXECUTE dbms_space_admin.tablespace_migrate_to_local ('SYSTEM');

/*
Note that if you use the DBMS_SPACE_ADMIN package to migrate from dictionary-managed to locally managed
tablespaces, you won't have the option of switching to the new Automatic Segment Space Management feature. All
dictionary-managed tablespaces use the older manual segment space management by default, and you can't
change to Automatic Segment Space Management when you migrate to locally managed tablespaces. Since Automatic
Segment Space Management offers so many benefits (such as the ability to use the Online Segment Shrink
capability of the Segment Advisor), you probably are better off biting the bullet and planning the migration of all your
objects to newly created locally managed tablespaces. By default, Oracle creates all new tablespaces as locally
managed with automatic segment space management.

In addition, if your current dictionary-managed tablespaces have a space fragmentation problem, the problem won't
disappear when you convert to locally managed tablespaces by using an in-place migration with the DBMS_SPACE_
ADMIN package. Again, you're better off creating a new locally managed tablespace and moving your objects into it.
Chapter 17 shows how to perform such migrations easily, using Oracle's online table reorganization features.

The segment space management that you specify at tablespace creation time applies to all segments you
later create in the tablespace.

Creating Tablespaces
====================
*/
set linesize 300 pagesize 60 colsep |
col name for a50
select * from v$dbfile order by file#;

CREATE TABLESPACE test
DATAFILE '/u01/prod/test01.dbf'
SIZE 50M;

--Extent Management 1. Local 2. Dictionary
--extent size 1. uniform 2. autoallocate
--segment space Management 1. auto 2. manual

SELECT extent_management, allocation_type, segment_space_management
FROM dba_tablespaces
WHERE tablespace_name = 'TEST';

/*
EXTENT_MAN  ALLOCATIO   SEGMEN
----------  ---------    -------
LOCAL       SYSTEM      AUTO

Here SYSTEM means autoallocate

We can create an identical tablespace by explicitly specifying all of these choices:
*/

CREATE TABLESPACE test02
DATAFILE '/u01/prod/test02.dbf'
size 50m
extent management local
autoallocate
segment space management auto;

select * from v$dbfile order by file#;

SELECT tablespace_name, extent_management, allocation_type, segment_space_management
FROM dba_tablespaces;

--Extent Allocation and Deallocation
/*
Once Oracle allocates space to a segment by allocating a certain number of extents to it, that
space will remain with the extent unless you make an effort to deallocate it. If you truncate a table with the DROP STORAGE option (TRUNCATE TABLE table_name DROP STORAGE), for example, Oracle deallocates the allocated extents. You can also manually deallocate unused extents using the following command:
*/

ALTER TABLE table_name DEALLOCATE UNUSED;

/*
When Oracle frees extents, it automatically modifies the bitmap in the datafile where the extents are located, to indicate that they are free and available again.

Storage Parameters
------------------
Remember that extents are the units of space allocation when you create tables and indexes in tablespaces.

Here is how Oracle determines extent sizing and extent allocation when you create tablespaces:

    The default number of extents is 1. You can override it by specifying MINEXTENTS during
    tablespace creation.
    
    You don't have to provide a value to the MAXEXTENTS parameter when you use locally managed
    tablespaces. Under locally managed tablespaces, the MAXEXTENTS parameter is set to UNLIMITED, and you don't have to configure it at all.
    
    If you choose UNIFORM extent size, the size of all extents, including the first, will be determined by the extent size you choose.
    
Initial extent: This storage parameter determines the initial amount of space that is allocated to any object you create in this tablespace. For example, if you specify a UNIFORM extent size of 10MB and specify an INITIAL_EXTENT value of 20MB, Oracle will create two 10MB-sized extents, to start with, for a new object. The example in Listing 6-1 shows an initial extent size of 5,242,880 bytes, based on the UNIFORM SIZE value, which is 5MB for this tablespace.

Next extent: The NEXT_EXTENT storage parameter determines the size of the subsequent
extents after the initial extent is created.

Extent management: This column can show a value of LOCAL or DICTIONARY, for locally
managed and dictionary-managed tablespaces, respectively.

Allocation type: This column refers to the extent allocation, which can have a value of
UNIFORM for uniform extent allocation, or SYSTEM for the AUTOALLOCATE option for sizing
extents.

Segment space management: This column shows the segment space management for the
tablespace, which can be AUTO (the default) or MANUAL.

Listing 6-1. Creating a Tablespace with Uniform Extents Using the UNIFORM SIZE Clause
*/

CREATE TABLESPACE test03
DATAFILE '/u01/prod/test03.dbf'
SIZE 50M
UNIFORM SIZE 5M;

SELECT tablespace_name, initial_extent, next_extent, extent_management,
allocation_type, segment_space_management
FROM dba_tablespaces;

/*
TEST03	5242880	5242880	LOCAL	UNIFORM	AUTO

If you choose to use the UNIFORM option for extent allocation but don't specify the additional
SIZE clause, Oracle will create uniform extents of size 1MB by default, as shown in Listing 6-2.

Listing 6-2. Creating a Tablespace with Uniform Extents
*/

CREATE TABLESPACE test04
DATAFILE '/u01/prod/test04.dbf'
SIZE 50M
UNIFORM;

SELECT tablespace_name, initial_extent, next_extent, extent_management,
allocation_type, segment_space_management
FROM dba_tablespaces;

/*
TEST04	1048576	1048576	LOCAL	UNIFORM	AUTO

If you choose the AUTOALLOCATE method of sizing extents, Oracle will size the extents starting with a 64KB (65536 bytes) minimum extent size. Note that you can specify the autoallocate method for extent sizing either by explicitly specifying it with the AUTOALLOCATE keyword, or by simply leaving out the keyword altogether, since by default, Oracle uses the AUTOALLOCATE method anyway. Listing 6-3
shows an example that creates a tablespace with system-managed (automatically allocated) extents.

Listing 6-3. Creating a Tablespace with Automatically Allocated Extents
*/

CREATE TABLESPACE test05
DATAFILE '/u01/prod/test05.dbf'
SIZE 50M;

SELECT tablespace_name, initial_extent, next_extent, extent_management,
allocation_type, segment_space_management
FROM dba_tablespaces
WHERE tablespace_name = 'TEST05';

--TEST05	65536		LOCAL	SYSTEM	AUTO

/*
Note that there is no value for the autoallocated tablespace for NEXT_EXTENT in Listing 6-3. When you choose the AUTOALLOCATE option (here it is chosen by default) rather than UNIFORM, Oracle allocates extent sizes starting with 64KB for the first extent. The next extent size will depend entirely upon the requirements of the segment (table, index, etc.) that you create in this tablespace.
*/

--Storage Allocation to Database Objects
/*
You can omit the specification of storage parameters, such as INITIAL, NEXT, MINEXTENTS, MAXEXTENTS, and PCTINCREASE, when you create objects like tables and indexes in the tablespaces. For locally managed tablespaces, Oracle will manage the storage extents, so there is very little scope for you to specify in terms of storage allocation parameters. Oracle retains the storage parameters for backward compatibility only.

You don't have to set the PCTUSED parameter if you're using locally managed tablespaces. If you set it, your object creation statement won't error out, but Oracle ignores the parameter. However, you can use the PCTFREE parameter to specify how much free space Oracle should leave in each block for future updates to data. The default is 10, which is okay if you don't expect the existing rows to get longer with time. If you do, you can change the PCTFREE parameter upward, say to 20 or 30 percent.

Of course, there is a price to pay for this'the higher the PCTFREE parameter, the more space you will 'waste' in your database.
*/

--CREATING TABLESPACES WITH NONSTANDARD BLOCK SIZES
/*
The default block size for all tablespaces is determined by the DB_BLOCK_SIZE initialization parameter for your database. You have the option of creating tablespaces with block sizes that are different from the standard database block size. In order to create a tablespace with a nonstandard block size, you must have already set the DB_CACHE_SIZE initialization parameter, and at least one DB_nK_CACHE_SIZE initialization parameter. For example, you must set the DB_16K_CACHE_SIZE parameter, if you wish to create tablespaces with a 16KB block
size.

By using a nonstandard block size, you can customize a tablespace for the types of objects it contains. For example, you can allocate a large table that requires a large number of reads and writes to a tablespace with a large block size. Similarly, you can place smaller tables in tablespaces with a smaller block size.

Here are some points to keep in mind if you're considering using the multiple block size feature for tablespaces:
    Multiple buffer pools enable you to configure up to a total of five different pools in the buffer cache, each with a different block size.
    
    The System tablespace always has to be created with the standard block size specified by the DB_BLOCK_SIZE parameter in the init.ora file.
    
    You can have up to four nonstandard block sizes.
    
    You specify the block size for tablespaces in the CREATE TABLESPACE statement by using the BLOCKSIZE clause.
    
    The nonstandard block sizes must be 2KB, 4KB, 8KB, 16KB, or 32KB. One of these sizes, of course, will have to be chosen as the standard block size by using the DB_BLOCK_SIZE parameter in the init.ora file.
    
    If you're transporting tablespaces between databases, using tablespaces with multiple block sizes makes it easier to transport tablespaces of different block sizes.

You use the BLOCKSIZE keyword when you create a tablespace, to specify a nonstandard block size. The following statement creates a tablespace with a nonstandard block size of 16KB (the standard block size, which is determined by the value you specify for the DB_BLOCK_SIZE initialization parameter, is 8 KB):
*/

CREATE TABLESPACE test06 
datafile '/u01/prod/test06.dbf'
BLOCKSIZE 16K;



--Adding Space to a Tablespace

ALTER TABLESPACE test01
ADD DATAFILE '/u01/prod/test01b.dbf'
size 50M;

select * from dba_data_files where tablespace_name='TEST';

/*
You can also increase or decrease the size of the tablespace by increasing or decreasing the size
of the tablespace's datafiles with the RESIZE option. You usually use the RESIZE option to correct
data-file sizing errors. Note that you can't decrease a datafile's size beyond the space that is already
occupied by objects in the datafile.

The following example shows how you can manually resize a datafile. Originally, the file was
50MB, and the following command doubles the size of the file to 100MB. Note that you need to use
the ALTER DATABASE command, not the ALTER TABLESPACE command, to resize a datafile.
*/

ALTER DATABASE DATAFILE '/u01/prod/test01.dbf'
RESIZE 100M;

select * from dba_data_files where tablespace_name='TEST01';

/*
You can use the AUTOEXTEND provision when you create a tablespace or when you add datafiles
to a tablespace to tell Oracle to automatically extend the size of the datafiles in the tablespace to a
specified maximum.
*/

ALTER TABLESPACE test01
ADD DATAFILE '/u01/prod/test01a.dbf'
SIZE 50M
AUTOEXTEND ON
NEXT 10M
MAXSIZE 1000M;

select * from dba_data_files where tablespace_name='TEST01';

/*
In the preceding example, 10MB extents will be added to the tablespace when space is required,
as specified by the AUTOEXTEND parameter. The MAXSIZE parameter limits the tablespace to 1000MB.
If you wish, you can also specify MAXSIZE UNLIMITED, in which case there is no set maximum size for
this datafile and hence for the tablespace. However, you must ensure that you have enough operating
system disk space to accommodate this.
*/


--Removing Tablespaces

DROP TABLESPACE test01;

/*
If the test01 tablespace includes tables or indexes when you issue a DROP TABLESPACE command,
you'll get an error. You can either move the objects to a different tablespace or, if the objects are
dispensable, you can use the following command, which will drop the tablespace and all the objects
that are part of the tablespace:
*/

DROP TABLESPACE test01 INCLUDING CONTENTS;

/*
Caution In Oracle Database 10g, database objects such as tables aren't dropped right away when you issue a
DROP TABLE command. Instead, they go to the Recycle Bin (discussed in Chapter 16), from which you can reclaim
the table you 'dropped.'

When you use the DROP TABLESPACE . . . INCLUDING CONTENTS command, the objects in the tablespace are
dropped right away, bypassing the Recycle Bin! Any objects belonging to this tablespace that are in the Recycle Bin
are also purged permanently when you issue this command. If you omit the INCLUDING CONTENTS clause and the
tablespace contains objects, the statement will fail, but any objects in the Recycle Bin will be dropped.

The DROP TABLESPACE . . . INCLUDING CONTENTS statement will not release the datafiles back to
the operating system's file system. To do so, you have to either manually remove the datafiles that
were a part of the tablespace or issue the following command to remove both the objects and the
physical datafiles at once:
*/

DROP TABLESPACE tbs01 INCLUDING CONTENTS AND DATAFILES;

select * from dba_data_files order by tablespace_name;
select * from v$dbfile;

/*
If there are referential integrity constraints in other tables that refer to the tables in the
tablespace you intend to drop, you need to use the following command:
*/

DROP TABLESPACE test02 CASCADE CONSTRAINTS;

/*
The one tablespace you can't drop, of course, is the System tablespace. You also can't drop the
Sysaux tablespace during normal database operation. However, provided you have the SYSDBA privilege
and you have started the database in the MIGRATE mode, you'll be able to drop the Sysaux
tablespace.

Of course, there aren't many reasons why you would want to drop your Sysaux tablespace. If you
simply want to move certain users out of this tablespace, you can always use the appropriate move
procedure specified in the V$SYSAUX_OCCUPANTS view.

The V$SYSAUX_OCCUPANTS view shows you details about the space usage by each occupant
of the Sysaux tablespace. It also provides you with the move procedure to use for a given occupant,
if you want to move the occupant to a different tablespace. Here's a sample query using this view:
*/

SELECT * FROM V$SYSAUX_OCCUPANTS;

set linesize 300 pagesize 100 colsep |
col occupant_name for a30
col schema_name for a20
col space_usage_kbytes for 99999999
col move_procedure for a30
SELECT occupant_name, schema_name, space_usage_kbytes, move_procedure
FROM V$SYSAUX_OCCUPANTS;

--ULTRASEARCH	WKSYS	0	MOVE_WK

/*
If you wish to move the Sysaux occupant ULTRASEARCH to a new tablespace called ULTRA1,
you can do so using the MOVE_WK procedure owned by the WKSYS schema, as shown here:
*/

EXECUTE WKSYS.MOVE_WK('ULTRA1');


--Number of User Tablespaces

/*
Oracle DBAs have traditionally used a large number of tablespaces for managing database objects.
Unfortunately, the larger the number of tablespaces in your database, the more time you'll have to
spend on mundane tasks, such as monitoring space and allocating space to the tablespaces. Disk
contention between indexes and tables and other objects were pointed out as the reason for
creating large numbers of tablespaces, but with the types of disk management used today in most
places, where Logical Volume Managers stripe operating system files over several disk spindles,
traditional tablespace-creation rules don't apply. You're better off using a very small number of
tablespaces'perhaps just four or five'to hold all your data.

Tablespace Quotas

You can assign a user a tablespace quota, thus limiting the user to a certain amount of storage space
in the tablespace. You can do this when you create the user, or by using the ALTER USER statement at
a later time.

In Chapter 9, I discuss Oracle's Resumable Space Allocation feature. User-quota-exceeded
errors are an important type of resumable statement. When a user exceeds the assigned quota,
Oracle will automatically raise a space-quota-exceeded error.

Proactive Tablespace Space Alerts

You can write scripts to alert you that a tablespace is about to run out of space, but the database
itself can send you proactive space alerts for all locally managed tablespaces, including the undo
tablespace. The Oracle database stores information on tablespace space usage in its system global
area (SGA). The new Oracle background process MMON checks tablespace usage every ten minutes
and raises alerts when necessary.

The database will send out two types of tablespace out-of-space alerts: a warning alert and
a critical alert. The warning alert cautions you that a tablespace's free space is running low, and the
critical alert tells you that you should immediately take care of the free space problem so the database
doesn't issue 'out of space' errors. Both of these alerts are based on threshold values called
warning and critical thresholds, which you can modify.

When you upgrade to Oracle Database 11g, by default, both the percent full and the bytes remaining alerts
are disabled. You must explicitly set both alerts yourself. For a given tablespace, you can use either or both types
of alerts.

Types of Alert Thresholds

There are two ways to set alert thresholds: you can specify that the database alert be based on the
percent of space used or on the number of free bytes left in the tablespace:

    Percent full: The database issues an alert when the space used in a tablespace reaches or
    crosses a preset percentage of total space. For a new database, 85 percent full is the threshold
    for the warning alerts, and 97 percent full is the threshold for the critical alerts. You can, if you
    wish, change these values and set, for example, 90 and 98 percent as the warning and critical
    thresholds.
    
    Bytes remaining: When the free space falls below a certain amount (specified in KB), Oracle
    issues an alert. For example, you can use a warning threshold of 10,240KB and a critical
    threshold of 4,096KB for a tablespace. By default, the 'bytes remaining alerts' (both warning
    and critical) in a new database are disabled, since the defaults for both types of bytes remaining
    thresholds are set to zero. You can set them to a size you consider appropriate for
    each tablespace.

You can disable the warning or critical threshold tablespace alerts by setting the threshold values to zero.

Setting the Alert Thresholds

Just go to the OEM Home Page and select Administration - Related Links - Manage
Metrics - Edit Thresholds.

You can also use the Oracle-provided PL/SQL package DBMS_SERVER_ALERT to set warning
and critical space alerts.
*/

--Listing 6-4. Setting a Tablespace Alert Threshold

BEGIN
    DBMS_SERVER_ALERT.SET_THRESHOLD(
    metrics_id              => DBMS_SERVER_ALERT.TABLESPACE_BYT_FREE,
    warning_operator        => DBMS_SERVER_ALERT.OPERATOR_LE,
    warning_value           => '10240',
    critical_operator       => DBMS_SERVER_ALERT.OPERATOR_LE,
    critical_value          => '2048',
    observation_period      => 1,
    consecutive_occurrences => 1,
    instance_name           => NULL,
    object_type             => DBMS_SERVER_ALERT.OBJECT_TYPE_TABLESPACE,
    object_name             => 'USERS');
END;
/

/*
In Listing 6-4, note that the warning_value attribute sets the bytes-remaining alert warning
threshold at 10MB and the critical_value attribute sets the critical threshold at 2MB.

You can always add a datafile to a tablespace to get it out of the low-free-space situation.
However, one easy way to avoid this problem altogether, in most cases, is to use autoextensible
tablespaces. Autoextensible tablespaces will automatically grow in size when table or index data
grows over time. For a new database, this may prove to be an excellent solution, saving you from outof-
space errors if you create tablespaces that are too small and from wasting space if you create too
large a tablespace. It's very easy to create an autoextensible tablespace'all you have to do is include
the AUTOEXTEND clause for the datafile when you create or alter a tablespace. Just make sure that you
have enough free storage to accommodate the autoextensible datafile.


Managing Logging of Redo Data

When you perform an insert, update, or delete operation, the database produces redo records to
protect the changed data. The database makes use of the redo records when it has to recover a database
following a media or an instance failure. However, the recording of the redo data creates an
overhead. When you perform an operation such as a create table as select . . . (CTAS) operation,
you really don't need the redo data, because you can rerun the statement if it fails midway. You
can't switch off the production of redo data for normal DML activity in your database. However, you
can do so for a direct load operation, as I explain in Chapter 14.

You can specify the NOLOGGING clause when you create a tablespace, so the database doesn't
produce any redo records for any of the objects in that tablespace. When you specify the NOLOGGGING
option in a CREATE TABLESPACE statement, all database objects that you create in that tablespace will
inherit that attribute. However, you can specify the LOGGING clause in a CREATE TABLE or ALTER TABLE
statement to override the NOLOGGING clause that you specified for the tablespace.


Managing the Availability of a Tablespace

You can change the status of a tablespace to offline, to make a tablespace or a set of tablespaces
unavailable to the users of the database. When you make a tablespace offline, all tables and indexes
in that tablespace become out of reach of the users. You normally take tablespaces offline when you
want to make an application unavailable to users by or when you want to perform management
operations such as renaming or relocation the datafiles that are part of a tablespace. When you take
a tablespace offline, the database automatically takes all datafiles that are part of that tablespace
offline.

You can't take the System or the temporary tablespaces offline. You can specify either the
NORMALl, TEMPORARY, or IMMEDIATE parameters as options to the tablespace offline statement. Here's
how you choose among the three options:

    If there are no error conditions for any of the datafiles of tablespace, use the OFFLINE NORMAL
    clause, which is the default when you offline a tablespace.
    
    Using the OFFLINE NORMAL clause is considered taking a tablespace offline cleanly, which
    means the database won't have to perform a media recovery on the tablespace before
    bringing it back online. If you can't take the tablespace offline with the OFFLINE NORMAL clause,
    specify the OFFLINE TEMPORARY clause. If the NORMAL and TEMPORARY settings don't work, specify
    the OFFLINE IMMEDIATE clause, as shown here:
*/

ALTER TABLESPACE users OFFLINE;

SELECT tablespace_name, status FROM dba_tablespaces;

ALTER TABLESPACE users OFFLINE IMMEDIATE;

--at rman
--restore tablespace users;
--recover tablespace users;

/*
When you specify the OFFLINE IMMEDIATE clause, the database requires media recovery of the
tablespace before it can bring the tablespace online.
*/

ALTER TABLESPACE users ONLINE;

SELECT tablespace_name, status FROM dba_tablespaces;


--Renaming Tablespaces

ALTER TABLESPACE test01 RENAME TO test02;

/*
You can rename both permanent and temporary tablespaces, but there are a few restrictions:
    ' You can't rename the System and Sysaux tablespaces.
    ' The tablespace being renamed must have all its datafiles online.
    ' If the tablespace is read-only, renaming it doesn't update the file headers of its datafiles.

Renaming a datafile:*/

--1. Take the datafile offline by taking its tablespace offline. Use the following command:

ALTER TABLESPACE test01 OFFLINE NORMAL;

--Rename the file using an operating system utility such as cp or mv in UNIX, or copy in Windows.

$ cp /u01/prod/test01.dbf /u02/prod/test01.dbf

--3. Rename the datafile before bringing it online by using the following command:

ALTER TABLESPACE test01
RENAME DATAFILE '/u01/prod/test01.dbf'
TO '/u02/prod/test01.dbf';


--Read-Only Tablespaces
ALTER TABLESPACE test01 READ ONLY;

ALTER TABLESPACE test01 READ WRITE;


--Taking Tablespaces Offline
/*
Except for the System tablespace, you can take any or all of the tablespaces offline'that is, you can
make them temporarily unavailable to users. You usually need to take tablespaces offline when a
datafile within a tablespace contains errors or you are changing code in an application that accesses
one of the tablespaces being taken offline.

Four modes of offlining are possible with Oracle tablespaces: normal, temporary, immediate,
and for recovery. Except for the normal mode, which is the default mode of taking tablespaces offline,
all the other modes can involve recovery of the included datafiles or the tablespace itself. You can
take any tablespace offline with no harm by using the following command:
*/
ALTER TABLESPACE index_01 OFFLINE;
ALTER TABLESPACE index_01 OFFLINE NORMAL;

/*
Oracle will ensure the checkpointing of all the datafiles in the tablespace (index_01 in this
example) before it takes the tablespace offline. Thus, there is no need for recovery when you later
bring the tablespace back online.

Oracle will ensure the checkpointing of all the datafiles in the tablespace (index_01 in this
example) before it takes the tablespace offline. Thus, there is no need for recovery when you later
bring the tablespace back online.

To bring the tablespace online, use the following command:
*/

ALTER TABLESPACE index_01 ONLINE;

--Temporary Tablespaces
/*
A temporary tablespace, contrary to what the name might indicate, does exist on a permanent basis
as do other tablespaces, such as the System and Sysaux tablespaces. However, the data in a temporary
tablespace is of a temporary nature, which persists only for the length of a user session. Oracle
uses temporary tablespaces as work areas for tasks such as sort operations for users and sorting
during index creation. Oracle doesn't allow users to create objects in a temporary tablespace. By
definition, the temporary tablespace holds data only for the duration of a user's session, and the
data can be shared by all users. The performance of temporary tablespaces is extremely critical
when your application uses sort- and hash-intensive queries, which need to store transient data in
the temporary tablespace.

Oracle writes data in the program global area (PGA) in 64KB chunks. Therefore, Oracle advises you to
create temporary tablespaces with extent sizes that are multiples of 64KB. For large data warehousing and decision-support system databases, which make extensive use of temporary tablespaces, the recommended extent size is 1MB.

The very first statement after starting up an instance that uses the temporary tablespace creates
a sort segment, which is shared by all sort operations in the instance. When you shut down the database,
the database releases this sort segment. You can query the V$SORT_SEGMENT view to review
the allocation and deallocation of space to this sort segment. You can see who's currently using the
sort segment by querying the V$SORT_USAGE view. Use the V$TEMPFILE and DBA_TEMP_FILES
views to find out details about the tempfiles currently allocated to a temporary tablespace.
*/

SELECT * FROM V$SORT_SEGMENT;
SELECT * FROM V$SORT_USAGE;

SELECT * FROM V$FILESTAT;

--Creating a Temporary Tablespace
/*
You create a temporary tablespace the same way as you do a permanent tablespace, with the difference
being that you specify the TEMPORARY clause in the CREATE TABLESPACE statement and substitute
the TEMPFILE clause for the DATAFILE clause.
*/

CREATE TEMPORARY TABLESPACE temp_demo
TEMPFILE '/u01/prod/temp01.dbf' 
SIZE 50M
AUTOEXTEND ON;

/*
The SIZE clause in the second line specifies the size of the datafile and hence the size of the
temporary tablespace, as 500MB. In the preceding statement, the AUTOEXTEND ON clause will automatically
extend the size of the temporary file, and thus the size of the temporary tablespace. By default,
all temporary tablespaces are created with uniformly sized extents, with each extent sized at 1MB.
You can, however, specify the UNIFORM SIZE clause to specify a nondefault extent size, as shown in
the following statement:
*/

CREATE TEMPORARY TABLESPACE temp_demo
TEMPFILE '/u01/prod/temp01.dbf' 
SIZE 50M
EXTENT MANAGEMENT LOCAL 
UNIFORM SIZE 16M;

/*
In the previous statement, the EXTENT MANAGEMENT clause is optional. The UNIFORM SIZE clause
specifies a custom extent size of 16MB instead of the default extent size of 1MB.

It's common to create a single temporary tablespace (usually named Temp) for each database,
but you can have multiple temporary tablespaces, which are part of a temporary tablespace group,
if your database needs them to support heavy sorting operations.

In order to drop a default temporary tablespace, you must first use the ALTER TABLESPACE
command to create a new default tablespace for the database. You can then drop the previous
default temporary tablespace like any other tablespace.

Oracle recommends that you use a locally managed temporary tablespace with a 1MB uniform extent size
as your default temporary tablespace.

Altering a Temporary Tablespace
*/

--to make a temporary tablespace larger by adding a new tempfile

ALTER TABLESPACE temp
ADD TEMPFILE '/u01/prod/tempo3.dbf' 
size 50M reuse;

--to resize a tempfile

ALTER DATABASE 
TEMPFILE '/u01/prod/temp03.dbf'
RESIZE 100M;

--to drop a temp file and remove the OS level file

ALTER DATABASE 
TEMPFILE '/u01/prod/temp03.dbf'
DROP INCLUDING DATAFILES;

/*
When you drop a tempfile belonging to a temporary tablespace, the tablespace itself will remain
in use.

You can shrink a temporary tablespace, just as you can a normal tablespace.
*/

ALTER TABLESPACE temp SHRINK SPACE KEEP 50M;

/*
Shrinking Temporary Tablespaces

You may have to increase the size of a temporary tablespace to accommodate an unusually large job
that makes use of the temporary tablespace. After the completion of the job, you can shrink the
temporary tablespace using the clause SHRINK SPACE in an ALTER TABLESPACE statement.
*/

ALTER TABLESPACE temp SHRINK SPACE;

/*
The SHRINK SPACE clause will shrink all tempfiles to a minimum size, which is about 1MB. You
can employ the KEEP clause to specify a minimum size for the tempfiles, as shown here:
*/

ALTER tablespace temp SHRINK SPACE
KEEP 20M;

/*
Oracle uses a peculiar logic when shrinking tempfiles in a temporary tablespace. Let's say you
have a temporary tablespace that contains two 1GB tempfiles. You issue a command to shrink the
tablespace to 1GB, a shown here:
*/

ALTER TABLESPACE temp SHRINK SPACE KEEP 1G;

set linesize 300
col name for a40
SELECT file#, name, bytes/1024/1024 mb FROM v$tempfile;

/*
FILE# NAME MB
----- ------------------------------------ ---------
1 /u01/app/oracle/tempfile/temp01.dbf 999.9375
2 /u01/app/oracle/tempfile/temp02.dbf' 1.0625

The database shrinks one of the two tempfiles all the way down to 1MB and the other only by
1MB, leaving 999MB of space intact in that tempfile. If your goal is to shrink a particular tempfile
down to a certain minimum, you can do so by specifying the name of the particular tempfile you
want to shrink, as shown here:
*/

ALTER TABLESPACE temp SHRINK SPACE
TEMPFILE tempfile '/u01/prod/temp02.dbf'
KEEP 100m;

--how to shrink a single tempfile without any specific retained space

ALTER TABLESPACE temp
SHRINK tempfile '/u01/prod/temp03.dbf';

/*
Since I didn't specify the KEEP clause in the previous statement, the database shrinks the tempfile
I specified to the minimum possible size, which is about 1MB.

Default Temporary Tablespace

When you create database users, you must assign a default temporary tablespace in which they can
perform their temporary work, such as sorting. If you neglect to explicitly assign a temporary
tablespace, the users will use the critical System tablespace as their temporary tablespace, which
could lead to fragmentation of that tablespace, besides filling it up and freezing database activity.

You can avoid these undesirable situations by creating a default temporary tablespace for the database
when creating a database by using the DEFAULT TEMPORARY TABLESPACE clause. Oracle will then
use this as the temporary tablespace for all users for whom you don't explicitly assign a temporary
tablespace.

Note that if you didn't create a default temporary tablespace while creating your database, it
isn't too late to do so later. You can just create a temporary tablespace, as shown in the preceding
example, and make it the default temporary tablespace for the database, with a statement like this:
*/

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temptbs02;

/*
You can find out the name of the current default temporary tablespace for your database by
executing the following query:
*/

SELECT PROPERTY_NAME, PROPERTY_VALUE
FROM database_properties
WHERE property_name='DEFAULT_TEMP_TABLESPACE';

/*
You can't use the AUTOALLOCATE clause for temporary tablespaces. By default, all temporary tablespaces
are created with locally managed extents of a uniform size. The default extent size is 1MB, as for all other tablespaces, but you can use a different extent size if you wish when creating the temporary tablespace.
*/

--Temporary Tablespace Groups
/*
Large transactions can sometimes run out of temporary space. Large sort jobs, especially those
involving tables with many partitions, lead to heavy use of the temporary tablespaces, thus potentially
leading to a performance hit. Oracle Database 10g introduced the concept of a temporary
tablespace group, which allows a user to utilize multiple temporary tablespaces simultaneously in
different sessions.

Here are some of the main characteristics of a temporary tablespace group:
    ' A temporary tablespace group must consist of at least one tablespace. There is no explicit
    maximum number of tablespaces.
    ' If you delete all members from a temporary tablespace group, the group is automatically
    deleted as well.
    ' A temporary tablespace group has the same namespace as the temporary tablespaces that are
    part of the group.
    ' The name of a temporary tablespace cannot be the same as the name of any tablespace
    group.
    ' When you assign a temporary tablespace to a user, you can use the temporary tablespace
    group name instead of the actual temporary tablespace name. You can also use the temporary
    tablespace group name when you assign the default temporary tablespace for the
    database.
    
Benefits of Temporary Tablespace Groups

Using a temporary tablespace group, rather than the usual single temporary tablespace, provides
several benefits:

    ' SQL queries are less likely to run out of sort space because the query can now simultaneously
    use several temporary tablespaces for sorting.
    ' You can specify multiple default temporary tablespaces at the database level.
    ' Parallel execution servers in a parallel operation will efficiently utilize multiple temporary
    tablespaces.
    ' A single user can simultaneously use multiple temporary tablespaces in different sessions.
    
    
Creating a Temporary Tablespace Group

When you assign the first temporary tablespace to a tablespace group, you automatically create the
temporary tablespace group.
*/

CREATE TEMPORARY TABLESPACE temp01
TEMPFILE '/u01/prod/temp01_01.dbf'
SIZE 50M 
TABLESPACE GROUP tmpgrp1;

/*
The preceding SQL statement will create a new temporary tablespace, temp01, along with the
new tablespace group named tmpgrp1. Oracle creates the new tablespace group because the key
clause TABLESPACE GROUP was used while creating the new temporary tablespace.

You can also create a temporary tablespace group by specifying the same TABLESPACE GROUP
clause in an ALTER TABLESPACE command, as shown here:
*/

ALTER TABLESPACE temp02
TABLESPACE GROUP tmpgrp1;

/*
If you specify a pair of quotes ('') for the tablespace group name, you are implicitly telling
Oracle not to allocate that temporary tablespace to a tablespace group. Here's an example:
*/

CREATE TEMPORARY TABLESPACE temp02
TEMPFILE '/u01/prod/temp02_01.dbf' 
SIZE 50M
TABLESPACE GROUP '';

/*
The preceding statement creates a temporary tablespace called temp02, which is a regular
temporary tablespace and doesn't belong to a temporary tablespace group.

If you completely omit the TABLESPACE GROUP clause, you'll create a regular temporary
tablespace, which is not part of any temporary tablespace group:
*/

CREATE TEMPORARY TABLESPACE temp03
TEMPFILE '/u01/prod/temp03_01.dbf' 
SIZE 50M;

--Adding a Tablespace to a Temporary Tablespace Group

/*
As shown in the preceding section, you can add a temporary tablespace to a group by using the ALTER
TABLESPACE command. You can also change which group a temporary tablespace belongs to by using
the ALTER TABLESPACE command.
*/

ALTER TABLESPACE temp02 TABLESPACE GROUP tmpgrp2;

/*
The database will create a new group with the name tmpgrp2 if there is no such group already.

Setting a Group as the Default Temporary Tablespace for the Database

If you issue the following statement, all users without a default tablespace can use any temporary
tablespace in the tmpgrp1 group as their default temporary tablespaces:
*/

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE tmpgrp1;

/*
The preceding ALTER DATABASE statement assigns all the tablespaces in tmpgrp1 as the default
temporary tablespaces for the database.

Assigning Temporary Tablespace Groups When Creating and Altering Users
*/

CREATE USER salapati IDENTIFIED BY sammyy1
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE tmpgrp1;

/*
Once you create a user, you can also use the ALTER USER statement to change the temporary
tablespace group of the user.
*/

ALTER USER salapati TEMPORARY TABLESPACE tmpgrp2;

--Viewing Temporary Tablespace Group Information

SELECT * FROM DBA_TABLESPACE_GROUPS;

SELECT group_name, tablespace_name
FROM dba_tablespace_groups;

/*
You can also use the DBA_USERS view to find out which temporary tablespaces or temporary
tablespace groups are assigned to each user.*/

SELECT username, temporary_tablespace
FROM dba_users;

--Default Permanent Tablespaces
/*
Prior to the Oracle Database 10g release, the System tablespace was the default permanent
tablespace for any users you created if you neglected to assign the user to a default tablespace. As of
Oracle Database 10g, you can create a default permanent tablespace to which a new user will be
assigned if you don't assign a specific default tablespace when you create the user.

You can't drop a default permanent tablespace without first creating and assigning another tablespace as
the new default tablespace.

To find out what the current permanent tablespace for your database is, use the following
query:*/

SELECT property_value FROM database_properties
WHERE property_name='DEFAULT_PERMANENT_TABLESPACE';

/*You can create a default permanent tablespace when you first create a database, as shown here:

CREATE DATABASE
DATAFILE '/u01/app/oracle/test/system01.dbf' SIZE 500M
SYSAUX DATAFILE '/u01/app/oracle/syaux01.dbf' SIZE 500M
DEFAULT TABLESPACE users
DATAFILE '/u01/app/oracle/users01.dbf' SIZE 250M

You can also create or reassign a default permanent tablespace after database creation, by using
the ALTER DATABASE statement, as shown here:*/

ALTER DATABASE DEFAULT TABLESPACE users;


--Bigfile Tablespaces
/*
Oracle Database 11g can contain up to 8 exabytes (8 million terabytes) of data. Don't panic, however,
thinking how many millions of datafiles you'd need to manage in order to hold this much data.
You have the option of creating really big tablespaces called, appropriately, bigfile tablespaces. A
bigfile tablespace (BFT) contains only one very large datafile. If you're creating a bigfile-based
permanent tablespace, it'll be a single datafile, and if it's a temporary tablespace, it will be a single
temporary file. The maximum number of datafiles in Oracle is limited to 64,000 files. So, if you're
dealing with an extremely large database, using bigfile tablespaces ensures you don't bump against
the ceiling for the number of datafiles in your database.

Depending on the block size, a bigfile tablespace can be as large as 128 terabytes. In previous
versions of Oracle, you always had to keep in mind the distinction between datafiles and tablespaces.
Now, using the bigfile concept, Oracle has made a tablespace logically equal to a datafile by creating
the new one-to-one relationship between tablespaces and datafiles. With Oracle Managed Files
(OMF), datafiles are completely transparent to you when you use a BFT, and you can directly deal
with the tablespace in many kinds of operations.

The traditional tablespaces are now referred to as smallfile tablespaces. Smallfile tablespaces are the
default tablespaces in Oracle Database 11g. You can have both smallfile and bigfile tablespaces in the same
database.

Here?fs a summary of the benefits offered by using BFTs:
    . You only need to create as many datafiles as there are tablespaces.
    . You don't have to constantly add datafiles to your tablespaces.
    . Datafile management in large databases is simplified--you deal with a few tablespaces
    directly, not many datafiles.
    . Storage capacity is significantly increased because you don't reach the maximum-files limitation
    quickly when you use BFTs.


Restrictions on Using Bigfile Tablespaces

You can use them only if you use a locally managed
tablespace with automatic segment space management. By now, you know that locally managed
tablespaces with automatic segment space management are the default in Oracle Database 11g
Release 1. Oracle also recommends that you use BFTs along with a Logical Volume Manager or Automated
Storage Management feature that supports striping and mirroring. Otherwise, you can't
really support the massive datafiles that underlie the BFT concept. Both parallel query execution
and RMAN backup parallelization would be adversely impacted if you used BFTs without striping.

To avoid creating millions of extents when you use a BFT in a very large (greater than one terabyte)
database, Oracle recommends that you change the extent allocation policy from AUTOALLOCATE,
which is the default, to UNIFORM and set a very high extent size. In databases that aren't very large,
Oracle recommends that you stick to the default AUTOALLOCATE policy and simply let Oracle take care
of the extent sizing.

Creating Bigfile Tablespaces

You can create bigfile tablespaces in three different ways: you can specify them at database creation
time and thus make them the default tablespace type, you can use the CREATE BIGFILE statement, or
you can use the ALTER DATABASE statement to set the default type to a BFT tablespace.

Here's a portion of the CREATE DATABASE statement, showing how you specify a BFT:

CREATE DATABASE
SET DEFAULT BIGFILE tablespace
...;

Once you set the default tablespace type to bigfile tablespaces, all tablespaces you create subsequently
will be BFTs unless you manually override the default setting, as shown shortly.

Irrespective of which default tablespace type you choose'bigfile or smallfile'you can always
create a bigfile tablespace by specifying the type explicitly in the CREATE TABLESPACE statement, as
shown here:

CREATE BIGFILE TABLESPACE bigtbs_01
DATAFILE '/u01/oracle/data/bigtbs_01.dbf' SIZE 100G
...

In the preceding statement, the explicit specification of the BIGFILE clause will override the
default tablespace type, if it was a smallfile type. Conversely, if your default tablespace type is
BIGFILE, you can use the SMALLFILE keyword to override the default type when you create a
tablespace.

When you specify the CREATE BIGFILE TABLESPACE clause, Oracle will automatically create a
locally managed tablespace with automatic segment space management. You can specify the datafile
size in kilobytes, megabytes, gigabytes, or terabytes.

On operating systems that don't support large files, the bigfile size will be limited by the maximum file size
that the operating system can support.

You can dynamically change the default tablespace type to bigfile or smallfile, thus making all
tablespaces you subsequently create either bigfile or smallfile type tablespaces. Here's an example
that shows how to set the default tablespace type in your database to bigfile:*/

ALTER TABLESPACE SET DEFAULT BIGFILE TABLESPACE;

/*
You can also migrate database objects from a smallfile tablespace to a bigfile tablespace, or vice
versa, after changing a tablespace's type. You can migrate the objects using the ALTER TABLE . . .
MOVE or the CREATE TABLE AS SELECT commands. Or you can use the Data Pump Export and Import
tools to move the objects between the two types of tablespaces.

Altering a Bigfile Tablespace

You can use the RESIZE and AUTOEXTEND clauses in the ALTER TABLESPACE statement to modify the size
of a BFT. Note that both these space-extension clauses can be used directly at the tablespace, not the
file, level. Thus, both of these clauses provide datafile transparency'you deal directly with the
tablespaces and ignore the underlying datafiles.

Here are more details about the two clauses:
    ' RESIZE: The RESIZE clause lets you resize a BFT directly, without using the DATAFILE clause, as
    shown here:*/
ALTER TABLESPACE bigtbs RESIZE 120G;
--  ' AUTOEXTEND: The AUTOEXTEND clause enables automatic file extension, again without referring
--  to the datafile. Here's an example:
ALTER TABLESPACE bigtbs AUTOEXTEND ON NEXT 20G;
  
    
--Viewing Bigfile Tablespace Information
/*
    ' DBA_TABLESPACES
    ' USER_TABLESPACES
    ' V$TABLESPACE

All three views have the new BIGFILE column, whose value indicates whether a tablespace is of
the BFT type (YES) or smallfile type (NO).

You can also use the DATABASE_PROPERTIES data dictionary view, as shown in the following
query, to find out what the default tablespace type for your database is:*/

SELECT property_value
FROM database_properties
WHERE property_name='DEFAULT_TBS_TYPE';


--Managing the Sysaux Tablespace
/*
Oracle Database 10g mandates the creation of the Sysaux tablespace, which serves as an auxiliary
tablespace to the System tablespace. Until now, the System tablespace was the default location for
storing objects belonging to components like the Workspace Manager, Logical Standby, Oracle
Spatial, LogMiner, and so on. The more features the database offered, the greater was the demand
for space in the System tablespace. In addition, several features had to be accommodated in their
own repositories, like the Enterprise Manager and its Repository. On top of all this, you had to create
a special tablespace for the Statspack Repository.

To alleviate this pressure on the System tablespace and to consolidate all the repositories for the
various Oracle features, Oracle Database 10g offers the Sysaux tablespace as a centralized single
storage location for various database components. 

Using the Sysaux tablespace offers the following benefits:
    ' There are fewer tablespaces to manage because you don't have to create a separate
    tablespace for many database components. You just assign the Sysaux tablespace as the
    default location for all the components.
    ' There is reduced pressure on the System tablespace.

The size of the Sysaux tablespace depends on the size of the database components that you'll
store in it. Therefore, you should base your Sysaux tablespace sizing on the components and features
that your database will use. Oracle recommends that you create the Sysaux tablespace with a
minimum size of 240MB. Generally, the OEM repository tends to be the largest user of the Sysaux
tablespace.

Creating the Sysaux Tablespace

If you use the Oracle Database Configuration Assistant (DBCA), you can automatically create the
Sysaux tablespace when you create a new database, whether it is based on the seed database or a
completely new, built-from-scratch, user-defined database. During the course of creating a database,
the DBCA asks you to select the file location for the Sysaux tablespace. When you upgrade a
database to Oracle Database 10g, the Database Upgrade Assistant will similarly prompt you for the
file information for creating the new Sysaux tablespace.

The Sysaux tablespace is mandatory, whether you create a new Oracle Database or migrate from a release
prior to Oracle Database 10g.

CREATE DATABASE mydb
USER sys IDENTIFIED BY abc1def
USER system IDENTIFIED BY uvw2xyz
. . .
SYSAUX DATAFILE '/u01/oracle/oradata/mydb/sysaux01.dbf' SIZE 500M REUSE
. . .

If you omit the SYSAUX creation clause from the CREATE DATABASE statement, Oracle will create
both the System and Sysaux tablespaces automatically, with their datafiles being placed in system-determined
default locations. If you are using Oracle Managed Files, the datafile location will be
dependent on the OMF initialization parameters. If you include the DATAFILE clause for the System
tablespace, you must use the DATAFILE clause for the Sysaux tablespace as well, unless you are using
OMF.

You can only set the datafile location when you create the Sysaux tablespace during database
creation, as shown in the preceding example. Oracle sets all the other attributes, which are mandatory
and not changeable, with the ALTER TABLESPACE command. Once you provide the datafile
location and size, Oracle creates the Sysaux tablespace with the following attributes:

    ' Permanent
    ' Read/write
    ' Locally managed
    ' Automatic segment space management

You can alter the Sysaux tablespace using the same ALTER TABLESPACE command that you use for
other tablespaces.*/

ALTER TABLESPACE sysaux 
ADD DATAFILE '/u01/prod/sysaux02.dbf' 
SIZE 100M;

/*
Usage Restrictions for the Sysaux Tablespace

Although using the ALTER TABLESPACE command to change the Sysaux tablespace may make it seem
as if the Sysaux tablespace is similar to the other tablespaces in your database, several usage features
set the Sysaux tablespace apart. Here are the restrictions:
    ' You can't drop the Sysaux tablespace by using the DROP TABLESPACE command during normal
    database operation.
    ' You can't rename the Sysaux tablespace during normal database operation.
    ' You can't transport a Sysaux tablespace like other tablespaces.

--some gap for encrypted tablespace concepts

Data Dictionary Views for Managing Tablespaces

    DBA_TABLESPACES
    DBA_FREE_SPACE
    DBA_SEGMENTS
    DBA_DATA_FILES
    DBA_TABLESPACE_GROUPS

Some more dynamic performance views

    V$DATAFILE
    V$FILESTAT

DBA_TABLESPACES
    ' Initial extent size
    ' Next extent size
    ' Default maximum number of extents
    ' Status (online, offline, or read-only)
    ' Contents (permanent, temporary, or undo)
    ' Type of extent management (DICTIONARY or LOCAL)
    ' Segment space management (AUTO or MANUAL)

DBA_FREE_SPACE
The DBA_FREE_SPACE view tells you how much free space you have in the database at any given
moment. Note that space belonging to a table that you dropped and is in the Recycle Bin shows
up as free space in this view. However, you can't use it for any other object. You get the space back
only after you permanently remove the item with the ALTER TABLE . . . PURGE statement.
*/

SELECT tablespace_name, SUM(bytes)
FROM DBA_FREE_SPACE
GROUP BY tablespace_name;

/*
DBA_SEGMENTS
As you're aware, the Oracle database contains several kinds of segments: table, index, undo, and so
on. The DBA_SEGMENTS data dictionary view shows the segment name and type and the tablespace
the segment belongs to, among other things.*/

SELECT * FROM dba_segments where owner='SCOTT';

SELECT
tablespace_name,
segment_name,
segment_type,
extents, /*Number of extents in the segment*/
blocks, /*Number of db blocks in the segment*/
bytes /*Number of bytes in the segment*/
FROM dba_segments
WHERE owner = 'SCOTT';

/*
USERS	DEPT	TABLE	1	8	65536
USERS	EMP	TABLE	1	8	65536
USERS	SALGRADE	TABLE	1	8	65536
USERS	EMP_TAB_SAMPLE	TABLE	1	8	65536
USERS	NESTED_TAB_SPACE	NESTED TABLE	1	8	65536
USERS	MY_SUBJECT	TABLE	1	8	65536
USERS	STORE_TAB_1	NESTED TABLE	1	8	65536
USERS	BASE_TABLE	TABLE	1	8	65536
USERS	PK_DEPT	INDEX	1	8	65536
USERS	BIN$Rp7gpwwyM+/gUwLkqMBvSA==$0	INDEX	1	8	65536


DBA_DATA_FILES
You can query the view to find out the names of all
the datafiles, the tablespaces they belong to, and datafile information such as the number of bytes
and blocks and the relative file number.
*/

SELECT * FROM dba_data_files order by file_id;

SELECT file_id, file_name, tablespace_name FROM DBA_DATA_FILES
ORDER BY FILE_ID;

/*
1	/u01/prod/system01.dbf	SYSTEM
2	/u01/prod/sysaux01.dbf	SYSAUX
3	/u01/prod/undotbs01.dbf	UNDOTBS1
4	/u01/prod/users01.dbf	USERS
5	/u01/prod/users02.dbf	USERS

The DBA_DATA_FILES view is especially useful when you join it with another data dictionary
view. The query produces a report showing you the tablespace sizes, free and used space, 
and the percentage of used space in each tablespace. At the end, you also get the sum of 
total space allocated to all the tablespaces, and the breakdown of free and used space 
in the database.*/

BREAK ON REPORT
COMPUTE SUM OF tbsp_size ON REPORT
compute SUM OF used ON REPORT
compute SUM OF free ON REPORT

COL tbspname FORMAT a20 HEADING 'Tablespace Name'
COL tbsp_size FORMAT 999,999 HEADING 'Size|(MB)'
COL used FORMAT 999,999 HEADING 'Used|(MB)'
COL free FORMAT 999,999 HEADING 'Free|(MB)'
COL pct_used FORMAT 999 HEADING'% Used'

SELECT df.tablespace_name tbspname
sum(df.bytes)/1024/1024 tbsp_size,
nvl(sum(e.used_bytes)/1024/1024,0) used,
nvl(sum(f.free_bytes)/1024/1024,0) free,
nvl((sum(e.used_bytes)*100)/sum(df.bytes),0) pct_used,
FROM DBA_DATA_FILES df,
(SELECT file_id
SUM(nvl(bytes,0)) used_bytes
FROM dba_extents
GROUP BY file_id) e,
(SELECT MAX(bytes) free_bytes, file_id
FROM dba_free_space
GROUP BY file_id) f
WHERE e.file_id(+) = df.file_id
AND df.file_id = f.file_id(+)
GROUP BY df.tablespace_name
ORDER BY 5 DESC;

/*
The DBA_TEMP_FILES view is analogous to the DBA_DATA_FILES view, and shows the temporary
tablespace temp file information.

DBA_TABLESPACE_GROUPS
You can group a set of temporary tablespaces together into a temporary tablespace group. The
DBA_TABLESPACE_GROUPS view shows you all the tablespace groups in your database. You can
also find out the individual tablespace name in each group by using this view.

V$DATAFILE
The V$DATAFILE view contains information about the datafile name, the tablespace number, the
status, the time stamp of the last change, and so on. The V$TEMPFILE view shows you particulars
about the temporary tablespace files. The V$DATAFILE view provides important information when
you join it to the V$FILESTAT view.

V$FILESTAT
The V$FILESTAT view provides you with detailed data on file read/write statistics, including the
number of physical reads and writes, the time taken for that I/O, and the average read and write
times in milliseconds. The V$TABLESPACE view provides information about the tablespaces.

Listing 6-9 shows how you can join the V$DATAFILE, V$TABLESPACE, and V$FILESTAT views to
obtain useful disk I/O information.*/

SELECT d.name, t.name, f.phyrds, f.phywrts, f.readtim, f.writetim
FROM V$DATAFILE d, V$FILESTAT f, V$TABLESPACE t
WHERE f.file# = d.file# AND d.ts# = t.ts#;

/*
Easy File Management with Oracle Managed Files

With operating system file management, where you, the DBA, manually create, delete, 
and manage the datafiles. Oracle Managed Files enable you to bypass dealing with 
operating system files directly.

In an Oracle database, you deal with various types of database files,
including datafiles, control files, and online redo log files. In addition, you also have to manage
tempfiles for use with temporary tablespaces, archived redo logs, RMAN backup files, and files for
storing flashback logs. Normally, you'd have to set the complete file specification for each of these
files when you create one of them. Under an OMF setup, however, you specify the file system directory
for all the previously mentioned types of Oracle files by specifying three initialization
parameters: DB_CREATE_FILE_DEST, DB_CREATE_ONLINE_LOG_DEST_n, and DB_RECOVERY_FILE_DEST.
Oracle will then automatically create the files in the specified locations without your having to
provide the actual location for it.

OMF offers a simpler way of managing the file system'you don't have to worry about specifying
long file specifications when you're creating tablespaces or redo log groups or control files.
When you want to create a tablespace or add datafiles when using OMF, you don't have to give a
location for the datafiles. Oracle will automatically create the file or add the datafile in the location
you specified in the init.ora file for datafiles. Note that you don't have to use a DATAFILE or TEMPFILE
clause when creating a tablespace when you use the OMF-based file system.*/

CREATE TABLESPACE finance01;

ALTER TABLESPACE finance01 ADD DATAFILE 500M;

DROP TABLESPACE finance01;

/*
OMF files are definitely easier to manage than the traditional manually created operating
system files. However, there are some limitations:
    ' OMF files can't be used on raw devices, which offer superior performance to operating
    system files for certain applications (such as Oracle Real Application Clusters).
    ' All the OMF datafiles have to be created in one directory. It's hard to envision a large database
    fitting into this one file system.
    ' You can't choose your own names for the datafiles created under OMF. Oracle will use a
    naming convention that includes the database name and unique character strings to name
    the datafiles.

Oracle recommends using OMF for small and test databases. Normally, if you drop a datafile,
the database won't have any references to the datafile, but the physical file still exists in the old location'
you have to explicitly remove the physical file yourself. If you use OMF, Oracle will remove the
file for you when you drop it from the database. According to Oracle, OMF file systems are most
useful for databases using Logical Volume Managers that support RAID and extensible file systems.
Smaller databases benefit the most from OMF, because of the reduced file-management tasks. Test
databases are another area where an OMF file system will cut down on management time.

You have to use operating system'based files if you want to use the OMF feature; you can't use
raw files. You do lose some control over the placement of data in your storage system when you use
OMF files, but even with these limitations, the benefits of OMF file management can outweigh its
limitations in some circumstances.

Benefits of Using OMF
    ' Oracle automatically creates and deletes OMF files.
    ' You don't have to worry about coming up with a naming convention for the files.
    ' It's easy to drop datafiles by mistake when you're managing them. With OMF files, you don't
    run the risk of accidentally deleting database files.
    ' Oracle automatically deletes a file when it's no longer needed.
    ' You can have a mix of traditional files and OMF files in the same database.

Creating Oracle Managed Files

You can create OMF files when you create the database, or you can add them to a database that you
created with traditional datafiles later on. Either way, you need to set some initialization parameters
to enable OMF file creation.

Initialization Parameters for OMF

We can set these parameters by changing them in parameter file, ALTER SYSTEM or by using ALTER SESSION.
You can use each of these parameters to specify the file destination for different types of OMF files, 
such as datafiles, control files, and online redo log files:

    ' DB_CREATE_FILE_DEST: This parameter specifies the default location of datafiles, online redo
    log files, control files, block-change tracking files, and tempfiles. You can also specify a
    control file location if you wish. Unfortunately, the DB_CREATE_FILE_DEST parameter can take
    only a single directory as its value; you can't specify multiple file systems for the parameter. If
    the assigned directory for file creation fills up, you can always specify a new directory,
    because the DB_CREATE_FILE_DEST parameter is dynamic. This enables you to place Oracle
    datafiles anywhere in the file system without any limits whatsoever.
    
    ' DB_CREATE_ONLINE_LOG_DEST_n: You can use this parameter to specify the default location of
    online redo log files and control files. In this parameter, n refers to the number of redo log files
    or control files that you want Oracle to create. If you want to multiplex your online redo log
    files as Oracle recommends, you should set n to 2.
    
    ' DB_RECOVERY_FILE_DEST: This parameter defines the default location for control files, archived
    redo log files, RMAN backups, and flashback logs. If you omit the
    DB_CREATE_ONLINE_LOG_DEST_n parameter, this parameter will determine the location of the
    online redo log files and control files. The directory location you specify using this parameter
    is also known as the flash recovery area, which I explain it in detail in Chapter 10.
    
In addition to the preceding three initialization parameters, the DB_RECOVERY_FILE_DEST_SIZE
parameter specifies the size of your flash recovery area.*/

ALTER SYSTEM SET DB_CREATE_FILE_DEST = '/u01/prod';
ALTER SYSTEM SET DB_CREATE_ONLINE_LOG_DEST_1 = '/u01/prod';
ALTER SYSTEM SET DB_CREATE_ONLINE_LOG_DEST_2 = '/u02/prod';
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 20G; (Size must be given before location)
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/u01/fra';

/*
File-Naming Conventions

Oracle uses the OFA standards in creating filenames, so filenames are unique and datafiles are easily
identifiable as belonging to a certain tablespace. Table 6-1 shows the naming conventions for
various kinds of OMF files and an example of each type. Note that the letter t stands for a unique
tablespace name, g stands for an online redo group, and u is an 8-character string.

OMF File Type                                   Naming Convention           Example
Datafile                                        ora_t%_u.dbf                ora_data_Y2ZV8P00.dbf

Temp file (default size is 100MB)               ora_%t_u.tmp                ora_temp_Y2ZWGD00.tmp

Online redo log file (default size is 100MB)    ora_%g_%u.log               ora_4_Y2ZSQK00.log

Control file                                    ora_u%.ctl                  ora_Y2ZROW00.ctl


Different Types of Oracle Managed Files

You can use OMF to create all three types of files that the Oracle database requires: control files, redo
log files, and, of course, datafiles. However, there are interesting differences in the way OMF requires
you to specify (or not specify) each of these types of files. The following sections cover how Oracle
creates different types of files.

Control Files

As you have probably noticed already, there is no specific parameter that you need to include in your
init.ora file to specify the OMF format. If you specify the CONTROL_FILES initialization parameter,
you will, of course, have to specify a complete file location for those files, and obviously they will not
be OMF files'they are managed by you. If you don't specify the CONTROL_FILES parameter, and you
use the DB_CREATE_FILE_DEST or the DB_CREATE_ONLINE_LOG_DEST_n parameter, your control files will
be OMF files.

If you are using a traditional init.ora file, you need to add the control file locations to it. If you
are using an SPFILE, Oracle automatically adds the control file information to it.

Redo Log Files

OMF redo log file creation is similar to control file creation. If you don't specify a location for the
redo log files, and you set either the DB_CREATE_FILE_DEST or the DB_CREATE_ONLINE_LOG_DEST_n
parameter in the init.ora file, Oracle automatically creates OMF-based redo log files.

Datafiles

If you don't specify a datafile location in the CREATE or ALTER statements for a regular datafile, or a
tempfile for a temporary tablespace, tempfile, or an undo tablespace datafile, but instead specify the
DB_CREATE_FILE_DEST parameter, all these files will be OMF files.

Simple Database Creation Using OMF

Let's look at a small example to see how OMF files can really simplify database creation. When you
create a new database, you need to provide the control file, redo log file, and datafile locations to
Oracle. You specify some file locations in the initialization file (control file locations) and some file
locations at database creation (such as redo log locations). However, if you use OMF-based files,
database creation can be a snap, as you'll see in the sections that follow.

Setting Up File Location Parameters

For the new OMF-based database, named nicko, let's use the following initialization parameters:

db_name=nicko
DB_CREATE_FILE_DEST = '/u01/app/oracle/oradata'
DB_RECOVERY_FILE_DEST_SIZE = 100M
DB_RECOVERY_FILE_DEST = '/u04/app/oracle/oradata'
LOG_ARCHIVE_DEST_1 = 'LOCATION = USE_DB_RECOVERY_FILE_DEST'

Note that of the four OMF-related initialization parameters, I chose to use only the
DB_CREATE_FILE_DEST, DB_RECOVERY_FILE_DEST_SIZE, and DB_RECOVERY_FILE_DEST parameters. I
didn't have to use the fourth parameter, DB_CREATE_ONLINE_LOG_DEST_n, in this example. When this
parameter is left out, Oracle creates a copy of the log file and the redo log file in the locations specified
for the DB_CREATE_FILE_DEST and the DB_RECOVERY_FILE_DEST parameters. I thus have two copies
of the control file and the online redo log files.

The setting for the last parameter, LOG_ARCHIVE_DEST_1, tells Oracle to send the archived redo
logs for storage in the flash recovery area specified by the DB_RECOVERY_FILE_DEST parameter.

Starting the Instance

Using the simple init.ora file shown in the preceding section, you can start an instance as shown in
Listing 6-10.

Creating the OMF-Based Instance

SQL> connect sys/sys_passwd as sysdba
Connected to an idle instance.

SQL> STARTUP NOMOUNT PFILE='initnicko.ora';
ORACLE instance started.
Total System Global Area 188743680 bytes
Fixed Size 1308048 bytes
Variable Size 116132464 bytes
Database Buffers 67108864 bytes
Redo Buffers 4194304 bytes
SQL>


Creating the Database

Now that you've successfully created the new Oracle instance, you can create the new database
nicko with this simple command:

SQL> CREATE DATABASE nicko;
Database created.

That's it! Just those two simple lines are all you need to create a functional database with the
following structures:
    ' A System tablespace created in the default file system specified by the 
    DB_CREATE_FILE_DEST parameter (/u01/app/oracle/oradata)
    ' A Sysaux tablespace created in the default file system (/u01/app/oracle/oradata)
    ' Two duplexed redo log groups
    ' Two copies of the control file
    ' A default temporary tablespace
    ' An undo tablespace automatically managed by the Oracle database

Where Are the OMF Files?

You can see the various files within the database by looking in the alert log for the new database,
alert_nicko.log, which you'll find in the $ORACLE_HOME/rdbms/log directory, since we didn't specify
the BACKGROUND_DUMP_DIR directory in the init.ora file.

In the following segment from the alert log file for the database, you can see how the various files
necessary for the new database were created. First, Oracle creates the control files and places them
in the location you specified for the DB_CREATE_ONLINE_LOG_DEST_n parameter.

Sun Jan 13 17:44:51 2008
create database nicko
default temporary tablespace temp
Sun Jan 13 17:44:51 2008
WARNING: Default passwords for SYS and SYSTEM will be used.
Please change the passwords.
Created Oracle managed file /u01/app/oracle/oradata/NICKO/controlfile/o1_mf_150w
. . .
Sun Jan 13 17:46:37 2008
Completed: create database nicko
default temporary tablespace
MMNL started with pid=13, OS id=28939


Here's what the alert log shows regarding the creation of the control files:

Created Oracle managed file /u01/app/oracle/oradata/NICKO/controlfile/o1_mf_150wh3r1_.ctl
Created Oracle managed file /u04/app/oracle/oradata/NICKO/controlfile/o1_mf_150wh3_.ctl


Next, the Oracle server creates the duplexed online redo log files. Oracle creates the minimum
number of groups necessary and duplexes them by creating a set of online log files (two) in the locations
specified by the DB_CREATE_ONLINE_LOG_DEST and the DB_RECOVERY_FILE_DEST parameters:

Created Oracle managed file /u01/app/oracle/oradata/NICKO/onlinelog/o1_mf_1_150wh48m_.log
Created Oracle managed file /u04/app/oracle/oradata/NICKO/onlinelog/o1_mf_1_150whf07_.log
Created Oracle managed file /u01/app/oracle/oradata/NICKO/onlinelog/o1_mf_2_150whonc_.log
Created Oracle managed file /u04/app/oracle/oradata/NICKO/onlinelog/o1_mf_2_150whwh0_.log


The System tablespace is created next, in the location you specified for the DB_CREATE_FILE_DEST
parameter:

create tablespace SYSTEM datafile /* OMF datafile */
default storage (initial 10K next 10K) EXTENT MANAGEMENT DICTIONARY online
Created Oracle managed file /u01/app/oracle/oradata/NICKO/datafile/o1_mf_system_150wj4c3_.dbf
Completed: create tablespace SYSTEM datafile /* OMF datafile


The default Sysaux tablespace is created next, as shown here:

create tablespace SYSAUX datafile / OMF datafile /
EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO online
Sun Jan 33 17:46:16 2008
Created Oracle managed file /u01/app/oracle/oradata/NICKO/datafile/o1_mf_sysaux_150wkk9n_.dbf
Completed: create tablespace SYSAUX datafile /* OMF datafile


The undo tablespace is created next, with the default name of SYS_UNDOTS in the location
specified by the DB_CREATE_FILE_DEST parameter. A temporary tablespace named TEMP is also
created in the same directory:

CREATE UNDO TABLESPACE SYS_UNDOTS DATAFILE SIZE 10M AUTOEXTEND ON
Created Oracle managed file
/test01/app/oracle/oradata/ora_omf/finDATA/ora_sys_undo_yj5mg123.dbf
...
Successfully onlined Undo Tablespace 1.
Completed: CREATE UNDO TABLESPACE SYS_UNDOTS DATAFILE SIZE 1
CREATE TEMPORARY TABLESPACE TEMP TEMPFILE
Created Oracle managed file
/test01/app/oracle/oradata/ora_omf/finDATA/ora_temp_yj5mg592.tmp
Completed: CREATE TEMPORARY TABLESPACE TEMP TEMPFILE


Adding Tablespaces 

Adding other tablespaces and datafiles within an OMF file system is easy. All you have to do is invoke
the CREATE TABLESPACE command without the DATAFILE keyword. Oracle will automatically create the
datafiles for the tablespace in the location specified in the DB_CREATE_FILE_DEST parameter.
*/

ALTER SYSTEM SET DB_CREATE_FILE_DEST = '/u01/prod';

CREATE TABLESPACE omftest;

SELECT file_name FROM dba_data_files WHERE tablespace_name = 'OMFTEST';


--adding datafiles is also simple in OMF

ALTER TABLESPACE omftest ADD DATAFILE;

/*
OMF files, as you can see, simplify file administration chores and let you create and manage
databases with a small number of initialization parameters. You can easily set up the necessary
number of locations for your online redo log files, control files, and archive log files by specifying the
appropriate value for the various OMF parameters. Oracle's ASM-based file system relies on the
OMF file system.

Copying Files Between Two Databases

You can copy files directly between databases over Oracle Net, without using either OS commands or
utilities such as the FTP protocol. You can use the DBMS_FILE_TRANSFER package to copy binary
files within the same server or to transfer a binary file between servers. You use the COPY_FILE
procedure to copy files on the local system, The GET_FILE procedure to copy files from a remote
server to the local server and the PUT_FILE procedure to read and copy a local file to a remote file
system. Here's a brief explanation of the key procedures of this new package.

COPY_FILE

The COPY_FILE procedure enables you to copy binary files from one location to another on the
same or different servers. Before you can copy the files, you must first create the source and destination
directory objects, as follows:*/

CREATE OR REPLACE DIRECTORY source_dir as '/u01/app/oracle/source';

CREATE OR REPLACE DIRECTORY dest_dir as '/u01/app/oracle/dest';

--Once you create your source and destination directories, you can use the COPY_FILE procedure
--to copy files, as shown here:

BEGIN
    DBMS_FILE_TRANSFER.COPY_FILE(
    source_directory_object => 'SOURCE_DIR',
    source_file_name => 'test01.dbf',
    destination_directory_object => 'DEST_DIR',
    destination_file_name => 'test01_copy.dbf');
END;
/

--Ensure that the copy was correctly copied by checking the destination directory.

/*
You use the GET_FILE procedure to copy binary files from a remote server to the local server. First,
log into the remote server and create the source directory object, as shown here:

SQL> CONNECT system/system_passwd@remote_db
Connected.

SQL> CREATE OR REPLACE DIRECTORY source_dir as '/u01/app/oracle/source';

Next, you log into the local server and create a destination directory object, as shown here:

SQL> CONNECT system/system_passwd@local_db
Connected.

SQL> CREATE OR REPLACE DIRECTORY dest_dir as /'u01/app/oracle/dest';

Once you create the source and destination directories, ensure that you have a database link
between the two databases, or create one if one doesn't exist:

SQL> CREATE DATABASE LINK prod1
CONNECT TO system IDENTIFIED BY system_passwd
USING 'prod1';

You must make sure that you've set up the connection to the prod1 database using a
tnsnames.ora file, for example, before you can create the database link.

Now you execute the GET_FILE procedure to transfer the file from the remote server to the local
server, as shown here:*/

BEGIN
    DBMS_FILE_TRANSFER.GET_FILE(
    source_directory_object => 'SOURCE_DIR',
    source_file_name => 'test01.dbf',
    source_database => 'remote_db',
    destination_directory_object => 'DEST_DIR',
    destination_file_name => 'test01.dbf');
END;
/

/*
Note that for the SOURCE_DATABASE attribute, you provide the name of the database link to the
remote database.


PUT_FILE
You use the PUT_FILE procedure to transfer a binary file from the local server to a remote server. As
in the case of the previous two procedures, you must first create the source and destination directory
objects, as shown here (in addition, you must ensure the existence of a database link from the local
to the remote database):*/

SQL> CONNECT system/system_passwd@remote_db
Connected.

SQL> CREATE OR REPLACE DIRECTORY source_dir as '/u01/app/oracle/source';

SQL> connect system/system_passwd@local_db
Connected.

SQL> CREATE OR REPLACE DIRECTORY dest_dir as /'u01/app/oracle/dest';

--You can now use the PUT_FILE procedure to put a local file on the remote server, as shown here:

SQL> BEGIN
    DBMS_FILE_TRANSFER.PUT_FILE(
    source_directory_object => 'SOURCE_DIR',
    source_file_name => 'test01.dbf',
    destination_directory_object => 'DEST_DIR',
    destination_file_name => 'test01.dbf',
    destination_database => 'remote_db');
END;
/

--More information about this package 
---------------------------------------------------
--http://www.dba-oracle.com/t_dbms_file_transfer.htm
---------------------------------------------------


/*
Finding Out How Much Free Space Is Left

--http://www.dba-oracle.com/t_packages_dbms_space_usage.htm

The DBMS_SPACE package is useful for finding out how much space is used and how much free
space is left in various segments such as table, index, and cluster segments. Recall that the DBA_
FREE_SPACE dictionary view lets you find out free space information in tablespaces and datafiles,
but not in the database objects. Unless you use the DBMS_SPACE package, it's hard to find out how
much free space is in the segments allocated to various objects in the database. The DBMS_SPACE
package enables you to answer questions such as the following:

    ' How much free space can I use before a new extent is thrown?
    ' How many data blocks are above the high-water mark (HWM)?

The DBA_EXTENTS and the DBA_SEGMENTS dictionary views do give you a lot of information
about the size allocated to objects such as tables and indexes, but you can't tell what the used and
free space usage is from looking at those views. If you've been analyzing the tables, the BLOCKS
column will give you the HWM'the highest point in terms of size that the table has ever reached.
However, if your tables are undergoing a large number of inserts and deletes, the HWM isn't an accurate
indictor of the real space used by the tables. The DBMS_SPACE package is ideal for finding out
the used and free space left in objects.

The DBMS_SPACE package has three main procedures: the UNUSED_SPACE procedure gives you
information about the unused space in an object segment, the FREE_BLOCKS procedure gives you
information about the number of free blocks in a segment, and the SPACE_USAGE procedure gives you
details about space usage in the blocks.

Let's look at the UNUSED_SPACE procedure closely and see how you can use it to get detailed
unused space information. The procedure has three IN parameters (a fourth one is a default parameter)
and seven OUT parameters.

UNUSED_SPACE procedure
----------------------
Using the DBMS_SPACE.FREE_SPACE Procedure*/

DECLARE
    v_total_blocks NUMBER;
    v_total_bytes NUMBER;
    v_unused_blocks NUMBER;
    v_unused_bytes NUMBER;
    v_last_used_extent_file_id NUMBER;
    v_last_used_extent_block_id NUMBER;
    v_last_used_block NUMBER;
BEGIN
 dbms_space.unused_space (segment_owner => 'OE',
 segment_name => 'PRODUCT_DESCRIPTIONS',
 segment_type => 'TABLE',
 total_blocks => v_total_blocks,
 total_bytes => v_total_bytes,
 unused_blocks => v_unused_blocks,
 unused_bytes => v_unused_bytes,
 last_used_extent_file_id => v_last_used_extent_file_id,
 last_used_extent_block_id => v_last_used_extent_block_id,
 last_used_block => v_last_used_block,
 partition_name => NULL);
 
 dbms_output.put_line ('Number of Total Blocks :'||v_total_blocks);
 dbms_output.put_line ('Number of Bytes :'||v_total_bytes);
 dbms_output.put_line ('Number of Unused Blocks :'||v_unused_blocks);
 dbms_output.put_line ('Number of unused Bytes :'||v_unused_bytes );
END;
/

/*
Number of Total Blocks : 384
Number of Bytes : 3145728
Number of Unused Blocks : 0
Number of unused Bytes : 0
PL/SQL procedure successfully completed.*/


/*
Working with Operating System Files

The wonderful UTL_FILE package enables you to write to and read from operating system files
easily. The UTL_FILE package provides you with a restricted version of standard operating-system
stream file I/O. The procedures and functions in the UTL_FILE package let you open, read from,
write to, and close the operating system files. Oracle also uses a client-side text I/O package, the
TEXT_IO package, as part of the Oracle Procedure Builder.

Using the UTL_FILE Package

It's easy to use the UTL_FILE package to read from and write to the operating system files. In many
cases, when you need to create reports, the UTL_FILE package is ideal for creating the file, which you
can then send to external sources using the FTP utility.

Creating the File Directory

The first step in using the UTL_FILE package is to create the directory where you want to place the
operating system files.*/

CREATE DIRECTORY utl_dir AS '/u50/oradata/archive_data';

/*the directory could be named anything you want - utl_dir is just an example*/

/*
The UTL_FILE_DIR initialization parameter is still valid, but Oracle doesn't recommend using it anymore.
Oracle recommends that you use the new CREATE DIRECTORY command instead. Using the CREATE DIRECTORY
approach is better because you don't have to restart the database (when you want to add the UTL_FILE_DIR
parameter).

Granting Privileges to Users*/

GRANT READ, WRITE ON DIRECTORY utl_dir to public;

/*
Key UTL_FILE Procedures and Functions

The UTL_FILE package uses its many procedures and functions to perform file manipulation and
text writing and reading activities.

Note UTL_FILE.FILE_TYPE is a file-handling data type, and you use it 
for all the procedures and functions of the UTL_FILE package. 
Any time you use the UTL_FILE package within a PL/SQL anonymous 
code block or a procedure, you must first declare a file handle 
of UTL_FILE.FILE_TYPE, as you'll see later.

Opening an Operating System File

You use the FOPEN function to open an operating system file for input and output. You can open a file
in three modes: read (r), write (w), or append (a).

Reading from a File

To read from a file, you first specify the read (r) mode when you open a file using the FOPEN function.
The GET_LINE procedure enables you to read one line of text at a time from the specified operating
system file.

Writing to a File

To write to a file, you must open the file in the write (w) or append (a) mode. The append (a) mode
just adds to the file, and the write (w) mode overwrites the file if it already exists. If the file doesn't
already exist in the UTL_FILE directory, the UTL_FILE utility will first create the file and then write
to it. Note that you don't have to create the file manually'the FOPEN function takes care of that for
you.

When you want to write a line to the file, you can use the PUT procedure. After the package writes
a line, you can ask it to go to a new line by using the NEW_LINE procedure. Better yet, you can just use
the PUT_LINE procedure, which is like a combination of the PUT and NEW_LINE procedures, to write to
the text file.

Closing a File

When you finish reading from or writing to the file, you need to use the FCLOSE procedure to close the
operating system file. If you have more than one file open, you may use the FCLOSE_ALL procedure to
close all the open files at once.

Exceptions

Whenever you use the UTL_FILE package in a PL/SQL procedure or block, make sure you have an
exception block at the end to account for all the possible errors that may occur while you're using the
package. For example, your directory location may be wrong, or a 'no data found' error may be
raised within the procedure. You may have a read or write error due to a number of reasons. The
UTL_FILE package comes with a large number of predefined exceptions, and I recommend using all
the exceptions at the end of your procedure or code block to facilitate debugging. If you use
RAISE_APPLICATION_ERROR to assign an error number and a message with the exceptions, you'll have
an easier time debugging the code.

A Simple Example Using the UTL_FILE Package

The following anonymous PL/SQL code uses the UTL_FILE package to write password-related information
using the DBA_USERS and the DBA_PROFILES dictionary views. Your goal is to produce an
operating system file listing user names, their maximum allowable login attempts, their password
lifetime, and their password lock time.*/

DECLARE
    v_failed    dba_profiles.limit%TYPE;
    v_lock      dba_profiles.limit%TYPE;
    v_reuse     dba_profiles.limit%TYPE;
    --the fHandle declared here is used every time the OS file is opened
    fHandle     UTL_FILE.FILE_TYPE;
    vText       VARCHAR2(10);
    v_username  dba_users.username%TYPE;
    
    CURSOR users IS
    SELECT username FROM dba_users;
BEGIN
--Open utlfile.txt file for writing, and get its file handle
fHandle := UTL_FILE.FOPEN('/a01/pas/pasp/import','utlfile.txt','w');

--Write a line of text to the file utlfile.txt
UTL_FILE.PUT_LINE(fHandle,'USERNAME'||'ATTEMPTS'||'LIFE'||'LOCK'||);

--Close the utlfile.txt file
UTL_FILE.FCLOSE(fHandle);

--Open the utlfile.txt file for writing, and get its file handle
fHandle := UTL_FILE.FOPEN('/a01/pas/pasp/import','utlfile.txt','a');

    OPEN users;
    LOOP
    FETCH users INTO v_username;
    EXIT when users%NOTFOUND;
    
    SELECT p.limit
    INTO v_failed
    FROM dba_profiles p, dba_users u
    WHERE p.resource_name='FAILED_LOGIN_ATTEMPTS'
    AND p.profile=u.profile
    AND u.username=v_username;
    
    SELECT p.limit
    INTO v_life
    FROM dba_profiles p, dba_users u
    WHERE p.resource_name='PASSWORD_LIFE_TIME'
    AND p.profile=u.profile
    AND u.username=v_username;
    
    SELECT p.limit
    INTO v_lock
    FROM dba_profiles p, dba_users u
    WHERE p.resource_name='PASSWORD_LOCK_TIME'
    AND p.profile=u.profile
    AND u.username=v_username;
    
    vtext :='TEST';
    
    --Write a line of text to the file utlfile.txt
    UTL_FILE.PUT_LINE(fHandle,v_username||v_failed||_life||v_lock);
    
    --Read a line from the file utltext.txt
    UTL_FILE.GET_LINE(fHandle,v_username||v_failed||v_life||v_lock);
    
    --Write a line of text to the screen
    UTL_FILE.PUT_LINE(v_username||_failed||v_life||v_lock);
    
    END LOOP;
    CLOSE users;
    
    --Close the utlfile.txt file
    UTL_FILE.FCLOSE(fHandle);
    
    --this is the exception block for the UTL_File errors
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
        WHEN UTL_FILE.INVALID_MODE THEN
            RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
        WHEN UTL_FILE.INVALID_OPERATION then
            RAISE_APPLICATION_ERROR(-20102,'Invalid Operation');
        WHEN UTL_FILE.INVALID_FILEHANDLE then
            RAISE_APPLICATION_ERROR(-20103,'Invalid Filehandle');
        WHEN UTL_FILE.WRITE_ERROR then
            RAISE_APPLICATION_ERROR(-20104,'Write Error');
        WHEN UTL_FILE.READ_ERROR then
            RAISE_APPLICATION_ERROR(-20105,'Read Error');
        WHEN UTL_FILE.INTERNAL_ERROR then
            RAISE_APPLICATION_ERROR(-20106,'Internal Error');
        WHEN OTHERS THEN
            UTL_FILE.FCLOSE(fHandle);
END;
/



--UTL_FILE Example

CREATE OR REPLACE DIRECTORY TEST_DIR AS 'c:\test'
/

GRANT READ, WRITE ON DIRECTORY TEST_DIR TO myuser
/

CREATE OR REPLACE PROCEDURE EXPORT_DATA
AS
	fileHandler UTL_FILE.FILE_TYPE;
	
	CURSOR C1 IS 
	SELECT ENAME,JOB,SAL FROM EMP;
	
BEGIN
	fileHandler := UTL_FILE.FOPEN('C:\TEST','emp.txt', 'W');
	
	FOR REC IN C1
	LOOP		
	UTL_FILE.PUT_LINE(fileHandler, REC.ENAME||'~'||REC.JOB);
	END LOOP;
	
	UTL_FILE.FCLOSE(fileHandler);
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR -->'|| SQLERRM);
END;
/

