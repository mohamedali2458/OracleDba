/*
Oracle.Database.11g.Performance.Tuning.Recipes 
    By Sam R. Alapati

Chapter 1: Optimizing Table Performance 1
Chapter 2: Choosing and Optimizing Indexes  43
Chapter 3: Optimizing Instance Memory  83
Chapter 4: Monitoring System Performance  113
Chapter 5: Minimizing System Contention 147
Chapter 6: Analyzing Operating System Performance 185
Chapter 7: Troubleshooting the Database 209
Chapter 8: Creating Efficient SQL 253
Chapter 9: Manually Tuning SQL 299
Chapter 10: Tracing SQL Execution 327
Chapter 11: Automated SQL Tuning 367
Chapter 12: Execution Plan Optimization and Consistency 409
Chapter 13: Configuring the Optimizer 447
Chapter 14: Implementing Query Hints 491
Chapter 15: Executing SQL in Parallel 525

*/

select user, sysdate from dual;

/*
1: Optimizing Table Performance

1-1. Building a Database That Maximizes Performance

Problem

You realize when initially creating a database that some features (when enabled) have long-lasting
ramifications for table performance and availability. Specifically, when creating the database, you want
to do the following:

    • Enforce that every tablespace ever created in the database must be locally
    managed. Locally managed tablespaces deliver better performance than the
    deprecated dictionary-managed technology.
    
    • Ensure users are automatically assigned a default permanent tablespace. This
    guarantees that when users are created they are assigned a default tablespace
    other than SYSTEM. You don’t want users ever creating objects in the SYSTEM
    tablespace, as this can adversely affect performance and availability.
    
    • Ensure users are automatically assigned a default temporary tablespace. This
    guarantees that when users are created they are assigned a temporary tablespace
    other than SYSTEM. You don’t ever want users using the SYSTEM tablespace for a
    temporary sorting space, as this can adversely affect performance and availability.


Solution

Use a script such as the following to create a database that adheres to 
reasonable standards that set the foundation for a well-performing database:*/

CREATE DATABASE O11R2
    MAXLOGFILES 16
    MAXLOGMEMBERS 4
    MAXDATAFILES 1024
    MAXINSTANCES 1
    MAXLOGHISTORY 680
    CHARACTER SET AL32UTF8
DATAFILE '/u01/O11R2/system01.dbf'
SIZE 500M REUSE
EXTENT MANAGEMENT LOCAL
UNDO TABLESPACE undotbs1 
DATAFILE '/u01/O11R2/undotbs01.dbf'
SIZE 800M
SYSAUX DATAFILE '/u01/O11R2/sysaux01.dbf'
SIZE 500M
DEFAULT TEMPORARY TABLESPACE 
TEMP TEMPFILE '/u01/O11R2/temp01.dbf'
SIZE 500M
DEFAULT TABLESPACE USERS 
DATAFILE '/u01/O11R2/users01.dbf'
SIZE 50M
LOGFILE GROUP 1
('/u01/O11R2/redo01a.rdo',
'/u01/O11R2/redo01b.rdo') SIZE 200M,
GROUP 2
('/u01/O11R2/redo02a.rdo',
'/u01/O11R2/redo02b.rdo') SIZE 200M,
GROUP 3
('/u01/O11R2/redo03a.rdo',
'/u01/O11R2/redo03b.rdo') SIZE 200M
USER sys IDENTIFIED BY topfoo
USER system IDENTIFIED BY topsecrectfoo;

/*
The prior CREATE DATABASE script helps establish a good 
foundation for performance by enabling features such as 
the following:

    • Defines the SYSTEM tablespace as locally managed via the 
    EXTENT MANAGEMENT LOCAL clause; this ensures that all 
    tablespaces ever created in database are locally managed. 
    If you are using Oracle Database 11g R2 or higher, the 
    EXTENT MANAGEMENT DICTIONARY clause has been deprecated.
    
    • Defines a default tablespace named USERS for any user 
    created without an explicitly defined default tablespace; 
    this helps prevent users from being assigned the SYSTEM 
    tablespace as the default. Users created with a default 
    tablespace of SYSTEM can have an adverse impact on performance.
    
    • Defines a default temporary tablespace named TEMP for all users; this helps
    prevent users from being assigned the SYSTEM tablespace as the default temporary
    tablespace. Users created with a default temporary tablespace of SYSTEM can have
    an adverse impact on performance, as this will cause contention for resources in
    the SYSTEM tablespace.
    
Solid performance starts with a correctly configured database. The prior 
recommendations help you create a reliable infrastructure for your table data.

How It Works

A properly configured and created database will help ensure that your database 
performs well. It is true that you can modify features after the database is 
created. However, oftentimes a poorly crafted CREATE DATABASE script leads 
to a permanent handicap on performance. In production database environments,
it’s sometimes difficult to get the downtime that might be required to 
reconfigure an improperly configured database. If possible, think about 
performance at every step in creating an environment, starting with how you 
create the database.

When creating a database, you should also consider features that affect 
maintainability. A sustainable database results in more uptime, which is 
part of the overall performance equation. The CREATE DATABASE statement in 
the “Solution” section also factors in the following sustainability features:

    • Creates an automatic UNDO tablespace (automatic undo management is 
    enabled by setting the UNDO_MANAGEMENT and UNDO_TABLESPACE 
    initialization parameters); this allows Oracle to automatically 
    manage the rollback segments. This relieves you of
    having to regularly monitor and tweak.
    
    • Places datafiles in directories that follow standards for the 
    environment; this helps with maintenance and manageability, which 
    results in better long-term availability and thus better performance.
    
    • Sets passwords to non-default values for DBA-related users; 
    this ensures the database is more secure, which in the long run can 
    also affect performance (for example, if a malcontent hacks into 
    the database and deletes data, then performance will suffer).
    
    • Establishes three groups of online redo logs, with two members each, sized
    appropriately for the transaction load; the size of the redo log directly 
    affects the rate at which they switch. When redo logs switch too often, 
    this can degrade performance.

If you’ve inherited a database and want to verify the default permanent 
tablespace setting, use a query such as this:*/

SELECT * FROM database_properties
WHERE property_name = 'DEFAULT_PERMANENT_TABLESPACE';

--If you need to modify the default permanent tablespace, do so as follows:

alter database default tablespace users;

--To verify the setting of the default temporary tablespace, use this query:
SELECT * FROM database_properties
WHERE property_name = 'DEFAULT_TEMP_TABLESPACE';

--To change the setting of the temporary tablespace, you can do so as follows:
alter database default temporary tablespace temp;

--You can verify the UNDO tablespace settings via this query:
select * from v$parameter;

select name, value 
from v$parameter
where name in ('undo_management','undo_tablespace');

--If you need to change the undo tablespace, first create a new undo 
--tablespace and then use the
ALTER SYSTEM SET UNDO_TABLESPACE = UNDOTBS2 SCOPE = BOTH;






/*
1-2. Creating Tablespaces to Maximize Performance

Problem

You realize that tablespaces are the logical containers for database objects 
such as tables and indexes. Furthermore, you’re aware that if you don’t 
specify storage attributes when creating objects, then the tables and indexes 
automatically inherit the storage characteristics of the tablespaces 
(that the tables and indexes are created within). Therefore you want to 
create tablespaces in a manner that maximizes table performance and 
maintainability.

Solution

When you have the choice, tablespaces should always be created with the 
following two features enabled:
    • Locally managed
    • Automatic segment space management (ASSM)
    
Here’s an example of creating a tablespace that enables the prior two 
features:*/

DROP TABLESPACE tools INCLUDING CONTENTS AND DATAFILES;

create tablespace tools
datafile '/u01/prod/tools01.dbf'
size 100m -- Fixed datafile size
extent management local -- Locally managed
uniform size 128k -- Uniform extent size
segment space management auto -- ASSM
/

/*
Note As of Oracle Database 11g R2, the EXTENT MANAGEMENT DICTIONARY 
clause has been deprecated.

Locally managed tablespaces are more efficient than dictionary-managed 
tablespaces. This feature is enabled via the EXTENT MANAGEMENT LOCAL clause. 
Furthermore, if you created your database with the SYSTEM tablespace as 
locally managed, you will not be permitted to later create a dictionary-managed
tablespace. This is the desired behavior.

The ASSM feature allows for Oracle to manage many of the storage 
characteristics that formerly had to be manually adjusted by the DBA on 
a table-by-table basis. ASSM is enabled via the SEGMENT SPACE
MANAGEMENT AUTO clause. Using ASSM relieves you of these manual tweaking 
activities. Furthermore, some of Oracle’s space management features 
(such as shrinking a table and SecureFile LOBs) are allowed only when using 
ASSM tablespaces. If you want to take advantage of these features, then you
must create your tablespaces using ASSM.

You can choose to have the extent size be consistently the same for every 
extent within the tablespace via the UNIFORM SIZE clause. Alternatively 
you can specify AUTOALLOCATE. This allows Oracle to allocate extent sizes 
of 64 KB, 1 MB, 8 MB, and 64 MB. You may prefer the auto-allocation 
behavior if the objects in the tablespace typically are of varying size.

How It Works

Prior to Oracle Database 11g R2, you had the option of creating a tablespace as dictionary-managed.
This architecture uses structures in Oracle’s data dictionary to manage an object’s extent allocation and
free space. Dictionary-managed tablespaces tend to experience poor performance as the number of
extents for a table or index reaches the thousands.

You should never use dictionary-managed tablespaces; instead use locally managed tablespaces.
Locally managed tablespaces use a bitmap in each datafile to manage the object extents and free space
and are much more efficient than the deprecated dictionary-managed architecture.

In prior versions of Oracle, DBAs would spend endless hours monitoring and modifying the physical
space management aspects of a table. The combination of locally managed and ASSM render many of
these space settings obsolete. For example, the storage parameters are not valid parameters in locally
managed tablespaces:
    • NEXT
    • PCTINCREASE
    • MINEXTENTS
    • MAXEXTENTS
    • DEFAULT

The SEGMENT SPACE MANAGEMENT AUTO clause instructs Oracle to manage physical space within the
block. When you use this clause, there is no need to specify parameters such as the following:
    • PCTUSED
    • FREELISTS
    • FREELIST GROUPS

The alternative to AUTO space management is MANUAL space management. When you use MANUAL, you
can adjust the previously mentioned parameters depending on the needs of your application. We
recommend that you use AUTO (and do not use MANUAL). Using AUTO reduces the number of parameters
you’d otherwise need to configure and manage. You can verify the use of locally managed and ASSM
with the following query:*/

select tablespace_name, extent_management, segment_space_management
from dba_tablespaces;

/*
Note You cannot create the SYSTEM tablespace with automatic segment space management. Also, the ASSM
feature is valid only for permanent, locally managed tablespaces.

You can also specify that a datafile automatically grow when it becomes full. This is set through the
AUTOEXTEND ON clause. If you use this feature, we recommend that you set an overall maximum size for
the datafile. This will prevent runaway or erroneous SQL from accidentally consuming all available disk
space.

SIZE 1G AUTOEXTEND ON MAXSIZE 10G

When you create a tablespace, you can also specify the tablespace type to be smallfile or bigfile.
Prior to Oracle Database 10g, smallfile was your only choice. A smallfile tablespace allows you to
create one or more datafiles to be associated with a single tablespace. This allows you to spread out the
datafiles (associated with one tablespace) across many different mount points. For many environments,
you’ll require this type of flexibility.

The bigfile tablespace can have only one datafile associated with it. The main advantage of the
bigfile feature is that you can create very large datafiles, which in turn allows you to create very large
databases. For example, with the 8 KB block size, you can create a datafile as large as 32 TB. With a 32 KB
block size, you can create a datafile up to 128 TB. Also, when using bigfile, you will typically have fewer
datafiles to manage and maintain. This behavior may be desirable in environments where you use
Oracle’s Automatic Storage Management (ASM) feature. In ASM environments, you typically are
presented with just one logical disk location from which you allocate space.

Here’s an example of creating a bigfile tablespace:*/
DROP TABLESPACE tools_bf INCLUDING CONTENTS AND DATAFILES;

create bigfile tablespace tools_bf
datafile '/u01/prod/tools_bf01.dbf'
size 100m
extent management local
uniform size 128k
segment space management auto
/

--You can verify the tablespace type via this query:

select tablespace_name, bigfile from dba_tablespaces;

/*
Unless specified, the default tablespace type is smallfile. You can make bigfile the default
tablespace type for a database when you create it via the SET DEFAULT BIGFILE TABLESPACE clause. You
can alter the default tablespace type for a database to be bigfile using the ALTER DATABASE SET DEFAULT
BIGFILE TABLESPACE statement.

CREATE DATABASE mydb
SET DEFAULT BIGFILE TABLESPACE
DEFAULT TEMPORARY TABLESPACE temp;

ALTER DATABASE mydb
SET DEFAULT SMALLFILE TABLESPACE;

While bigfile tablespaces suffer from limitations (must be locally managed 
tablespace (LMT) with automatic segment-space management (bitmap freelists)), 
the old-fashioned smallfile tablespaces the perfect for almost all types of 
Oracle data tables and indexes.

One of the greatest misconceptions about the smallfile tablespace is that 
it is only for small data files.  The "traditional" smallfile tablespaces 
can hold billions of bytes of data, and smallfile tablespaces should be 
used in all cases except true VLDB data warehouse system that require the 
specialized features of the bigfile tablespaces.






1-3. Matching Table Types to Business Requirements

Problem

You’re new to Oracle and have read about the various table types 
available. For example, you can choose between heap-organized tables, 
index-organized tables, and so forth. You want to build a database
application and need to decide which table type to use.

Solution

Oracle provides a wide variety of table types. The default table type 
is heap-organized. For most applications, a heap-organized table is 
an effective structure for storing and retrieving data. However,
there are other table types that you should be aware of, and you 
should know the situations under which each table type should be 
implemented. 

Table Type/Feature          
Description
Benefit/Use

Heap-organized              
|
The default Oracle table type and the most commonly used.
|
Table type to use unless you have a specific reason to use a different type.

Temporary 
|
Session private data, stored for the duration of a session or transaction;
space is allocated in temporary segments.
|
Program needs a temporary table structure to store and sort
data. Table isn’t required after program ends.


Index-organized (IOT) 
|
Data stored in a B-tree index structure sorted by primary key
|
Table is queried mainly on primary key columns; provides fast random access

Partitioned 
|
A logical table that consists of separate physical segments
|
Type used with large tables with millions of rows; dramatically
affects performance scalability of large tables and indexes

Materialized view (MV) 
|
A table that stores the output of a SQL query; periodically refreshed when you
want the MV table updated with a current snapshot of the SQL result set
|
Aggregating data for faster reporting or replicating data to
offload performance to a reporting database

Clustered 
|
A group of tables that share the same data blocks
|
Type used to reduce I/O for tables that are often joined on the same columns

External 
|
Tables that use data stored in operating system files outside of the database
|
This type lets you efficiently access data in a file outside of
the database (like a CSV or text file). External tables provide an
efficient mechanism for transporting data between databases.

Nested 
|
A table with a column with a data type that is another table
|
Seldom used

Object 
|
A table with a column with a data type that is an object type
|
Seldom used


How It Works

In most scenarios, a heap-organized table is sufficient to meet your requirements. This Oracle table type
is a proven structure used in a wide variety of database environments. If you properly design your
database (normalized structure) and combine that with the appropriate indexes and constraints, the
result should be a well-performing and maintainable system.

Normally most of your tables will be heap-organized. However, if you need to take advantage of a
non-heap feature (and are certain of its benefits), then certainly do so. For example, Oracle partitioning
is a scalable way to build very large tables and indexes. Materialized views are a solid feature for
aggregating and replicating data. Index-organized tables are efficient structures when most of the
columns are part of the primary key (like an intersection table in a many-to-many relationship). And
so forth.

Caution You shouldn’t choose a table type simply because you think it’s a cool feature that you recently heard
about. Sometimes folks read about a feature and decide to implement it without first knowing what the
performance benefits or maintenance costs will be. You should first be able to test and prove that a feature has
solid performance benefits.


1-4. Choosing Table Features for Performance

Problem

When creating tables, you want to implement the appropriate data types and constraints that maximize
performance, scalability, and maintainability.

Solution

There are several performance and sustainability issues that you should consider when creating tables.

Table 1-2. Table Features That Impact Performance

Recommendation 
Reasoning

If a column always contains numeric data, make it a number data type.
|
Enforces a business rule and allows for the greatest 
flexibility, performance, and consistent results when
using Oracle SQL math functions (which may behave
differently for a “01” character vs. a 1 number); correct
data types prevent unnecessary conversion of data types.

If you have a business rule that defines the
length and precision of a number field,
then enforce it—for example, NUMBER(7,2).
If you don’t have a business rule, make it
NUMBER(38).
|
Enforces a business rule and keeps the data cleaner;
numbers with a precision defined won’t unnecessarily
store digits beyond the required precision. This can affect
the row length, which in turn can have an impact on I/O
performance.

For character data that is of variable length,
use VARCHAR2 (and not VARCHAR).
|
Follows Oracle’s recommendation of using VARCHAR2 for
character data (instead of VARCHAR); Oracle guarantees
that the behavior of VARCHAR2 will be consistent and not
tied to an ANSI standard. The Oracle documentation
states in the future VARCHAR will be redefined as a separate
data type.

Use DATE and TIMESTAMP data types
appropriately.
|
Enforces a business rule, ensures that the data is of the
appropriate format, and allows for the greatest flexibility
and performance when using SQL date functions and
date arithmetic

Consider setting the physical attribute
PCTFREE to a value higher than the default of
10% if the table initially has rows inserted
with null values that are later updated with
large values.
|
Prevents row chaining, which can impact performance if
a large percent of rows in a table are chained

Most tables should be created with a
primary key.
|
Enforces a business rule and allows you to uniquely
identify each row; ensures that an index is created on
primary key column(s), which allows for efficient access
to primary key values

Create a numeric surrogate key to be the
primary key for each table. Populate the
surrogate key from a sequence.
|
Makes joins easier (only one column to join) and one
single numeric key performs better than large
concatenated columns.

Create a unique key for the logical business
key—a recognizable combination of
columns that makes a row unique.
|
Enforces a business rule and keeps the data cleaner;
allows for efficient retrieval of the logical key columns
that may be frequently used in WHERE clauses

Define foreign keys where appropriate. 
|
Enforces a business rule and keeps the data cleaner; helps
optimizer choose efficient paths to data; prevents
unnecessary table-level locks in certain DML operations

Consider special features such as virtual
columns, read-only, parallel, compression,
no logging, and so on.
|
Features such as parallel DML, compression, or no
logging can have a performance impact on reading and
writing of data.


How It Works

When creating a table, you should also consider features that 
enhance scalability and availability. Oftentimes DBAs and developers
don’t think of these features as methods for improving performance. 
However, building a stable and supportable database goes hand in hand 
with good performance.

Table 1-3. Table Features That Impact Scalability and Maintainability

Recommendation 
Reasoning

Use standards when naming tables, columns,
constraints, triggers, indexes, and so on.
|
Helps document the application and simplifies
maintenance

If you have a business rule that specifies the
maximum length of a column, then use that
length, as opposed to making all columns
VARCHAR2(4000).
|
Enforces a business rule and keeps the data cleaner

Specify a separate tablespace for the table and indexes.
|
Simplifies administration and maintenance

Let tables and indexes inherit storage
attributes from the tablespaces.
|
Simplifies administration and maintenance

Create primary-key constraints out of line. 
|
Allows you more flexibility when creating the primary
key, especially if you have a situation where the
primary key consists of multiple columns

Create comments for the tables and columns. 
|
Helps document the application and eases maintenance.

Avoid large object (LOB) data types if
possible.
|
Prevents maintenance issues associated with LOB
columns, like unexpected growth, performance issues
when copying, and so on

If you use LOBs in Oracle Database 11g or
higher, use the new SecureFiles architecture.
|
SecureFiles is the new LOB architecture going forward;
provides new features such as compression,
encryption, and deduplication

If a column should always have a value, then
enforce it with a NOT NULL constraint.
|
Enforces a business rule and keeps the data cleaner

Create audit-type columns, such as
CREATE_DTT and UPDATE_DTT, that are
automatically populated with default values
and/or triggers.
|
Helps with maintenance and determining when data
was inserted and/or updated; other types of audit
columns to consider include the users who inserted
and updated the row.

Use check constraints where appropriate. 
|
Enforces a business rule and keeps the data cleaner;
use this to enforce fairly small and static lists of values.



1-5. Avoiding Extent Allocation Delays When Creating Tables

Problem
You’re installing an application that has thousands of tables and indexes. Each table and index are
configured to initially allocate an initial extent of 10 MB. When deploying the installation DDL to your
production environment, you want install the database objects as fast as possible. You realize it will take
some time to deploy the DDL if each object allocates 10 MB of disk space as it is created. You wonder if
you can somehow instruct Oracle to defer the initial extent allocation for each object until data is
actually inserted into a table.

Solution

The only way to defer the initial segment generation is to use Oracle Database 11g R2. With this version
of the database (or higher), by default the physical allocation of the extent for a table (and associated
indexes) is deferred until a record is first inserted into the table. A small example will help illustrate this
concept. First a table is created:*/

create table f_regs(reg_id number, reg_name varchar2(200));

--Now query USER_SEGMENTS and USER_EXTENTS to verify that no physical space has been allocated:

select count(*) from user_segments where segment_name='F_REGS';
/*
COUNT(*)
----------
0
*/
select count(*) from user_extents where segment_name='F_REGS';
/*
COUNT(*)
----------
0
*/
--Next a record is inserted, and the prior queries are run again:

insert into f_regs values(1,'BRDSTN');

--1 row inserted.

select count(*) from user_segments where segment_name='F_REGS';
/*
COUNT(*)
----------
1
*/
select count(*) from user_extents where segment_name='F_REGS';
/*
COUNT(*)
----------
1

The prior behavior is quite different from previous versions of Oracle. In prior versions, as soon as
you create an object, the segment and associated extent are allocated.

Note Deferred segment generation also applies to partitioned tables and indexes. An extent will not be
allocated until the initial record is inserted into a given extent.

How It Works

Starting with Oracle Database 11g R2, with non-partitioned heap-organized tables created in locally
managed tablespaces, the initial segment creation is deferred until a record is inserted into the table.
You need to be aware of Oracle’s deferred segment creation feature for several reasons:

    • Allows for a faster installation of applications that have a large number of tables
    and indexes; this improves installation speed, especially when you have
    thousands of objects.
    
    • As a DBA, your space usage reports may initially confuse you when you notice that
    there is no space allocated for objects.
    
    • The creation of the first row will take a slightly longer time than in previous
    versions (because now Oracle allocates the first extent based on the creation of the
    first row). For most applications, this performance degradation is not noticeable.

We realize that to take advantage of this feature the only “solution” is to upgrade to Oracle Database
11g R2, which is oftentimes not an option. However, we felt it was important to discuss this feature
because you’ll eventually encounter the aforementioned characteristics (when you start using the latest
release of Oracle).

You can disable the deferred segment creation feature by setting the database initialization
parameter DEFERRED_SEGMENT_CREATION to FALSE. The default for this parameter is TRUE.

You can also control the deferred segment creation behavior when you create the table. The CREATE
TABLE statement has two new clauses: SEGMENT CREATION IMMEDIATE and SEGMENT CREATION DEFERRED—for
example:*/

create table f_regs(
reg_id number
,reg_name varchar2(2000))
segment creation immediate;

/*
Note The COMPATIBLE initialization parameter needs to be 11.2.0.0.0 or greater before using the SEGMENT
CREATION DEFERRED clause.


1-6. Maximizing Data Loading Speeds

Problem

You’re loading a large amount of data into a table and want to insert new records as quickly as possible.

Solution

Use a combination of the following two features to maximize the speed of insert statements:
    • Set the table’s logging attribute to NOLOGGING; this minimizes the generation redo
    for direct path operations (this feature has no effect on regular DML operations).
    • Use a direct path loading feature, such as the following:
        • INSERT /*+ APPEND */-- on queries that use a subquery for determining which
        --records are inserted
        --• INSERT /*+ APPEND_VALUES */ on queries that use a VALUES clause
        --• CREATE TABLE…AS SELECT

/*
Here’s an example to illustrate NOLOGGING and direct path loading. First, run the following query to
verify the logging status of a table. In this example, the table name is F_REGS:*/

select table_name, logging from user_tables
where table_name = 'F_REGS';

/*
The prior output verifies that the table was created with LOGGING enabled (the default). To enable
NOLOGGING, use the ALTER TABLE statement as follows:*/

alter table f_regs nologging;

/*
Now that NOLOGGING has been enabled, there should be a minimal amount of redo generated for
direct path operations. The following example uses a direct path INSERT statement to load data into the
table:*/

insert /*+APPEND */ into f_regs
select * from reg_master;

--The prior statement is an efficient method for loading data because direct path operations such as
--INSERT /*+APPEND */ combined with NOLOGGING generate a minimal amount of redo.

/*
How It Works

Direct path inserts have two performance advantages over regular insert statements:
    • If NOLOGGING is specified, then a minimal amount of redo is generated.
    • The buffer cache is bypassed and data is loaded directly into the datafiles. This can
    significantly improve the loading performance.

The NOLOGGING feature minimizes the generation of redo for direct path operations only. For direct
path inserts, the NOLOGGING option can significantly increase the loading speed. One perception is that
NOLOGGING eliminates redo generation for the table for all DML operations. That isn’t correct. The
NOLOGGING feature never affects redo generation for regular INSERT, UPDATE, MERGE, and DELETE statements.

One downside to reducing redo generation is that you can’t recover the data created via NOLOGGING
in the event a failure occurs after the data is loaded (and before you back up the table). If you can
tolerate some risk of data loss, then use NOLOGGING but back up the table soon after the data is loaded. If
your data is critical, then don’t use NOLOGGING. If your data can be easily re-created, then NOLOGGING is
desirable when you’re trying to improve performance of large data loads.

What happens if you have a media failure after you’ve populated a table in NOLOGGING mode (and
before you’ve made a backup of the table)? After a restore and recovery operation, it will appear that the
table has been restored:

However, when executing a query that scans every block in the table, an error is thrown.*/

select * from f_regs;
/*
This indicates that there is logical corruption in the datafile:
ORA-01578: ORACLE data block corrupted (file # 10, block # 198)
ORA-01110: data file 10: '/ora01/dbfile/O11R2/users201.dbf'
ORA-26040: Data block was loaded using the NOLOGGING option

As the prior output indicates, the data in the table is unrecoverable. Use NOLOGGING only in situations
where the data isn’t critical or in scenarios where you can back up the data soon after it was created.

Tip If you’re using RMAN to back up your database, you can report on unrecoverable datafiles via the REPORT
UNRECOVERABLE command.

There are some quirks of NOLOGGING that need some explanation. You can specify logging
characteristics at the database, tablespace, and object levels. If your database has been enabled to force
logging, then this overrides any NOLOGGING specified for a table. If you specify a logging clause at the
tablespace level, it sets the default logging for any CREATE TABLE statements that don’t explicitly use a
logging clause.

You can verify the logging mode of the database as follows:*/

select name, log_mode, force_logging from v$database;

--The next statement verifies the logging mode of a tablespace:

select tablespace_name, logging from dba_tablespaces;

--And this example verifies the logging mode of a table:

select owner, table_name, logging from dba_tables where logging = 'NO';

/*
How do you tell whether Oracle logged redo for an operation? One way is to measure the amount of
redo generated for an operation with logging enabled vs. operating in NOLOGGING mode. If you have a
development environment for testing, you can monitor how often the redo logs switch while the
transactions are taking place. Another simple test is to measure how long the operation takes with and
without logging. The operation performed in NOLOGGING mode should occur faster because a minimal
amount of redo is generated during the load.


1-7. Efficiently Removing Table Data

Problem

You’re experiencing performance issues when deleting data from a table. You want to remove data as
efficiently as possible.

Solution

You can use either the TRUNCATE statement or the DELETE statement to remove records from a table.
TRUNCATE is usually more efficient but has some side effects that you must be aware of. For example,
TRUNCATE is a DDL statement. This means Oracle automatically commits the statement (and the current
transaction) after it runs, so there is no way to roll back a TRUNCATE statement. Because a TRUNCATE
statement is DDL, you can’t truncate two separate tables as one transaction.

This example uses a TRUNCATE statement to remove all data from the COMPUTER_SYSTEMS table:*/

truncate table computer_systems;

/*
When truncating a table, by default all space is de-allocated for the table except the space defined by
the MINEXTENTS table-storage parameter. If you don’t want the TRUNCATE statement to de-allocate the
currently allocated extents, then use the REUSE STORAGE clause:*/

truncate table computer_systems reuse storage;

/*You can query the DBA/ALL/USER_EXTENTS views to verify if the extents have been de-allocated (or
not)—for example:*/

select count(*) from user_extents where segment_name = 'COMPUTER_SYSTEMS';

/*
How It Works

If you need the option of choosing to roll back (instead of committing) when removing data, then you
should use the DELETE statement. However, the DELETE statement has the disadvantage that it generates a
great deal of undo and redo information. Thus for large tables, a TRUNCATE statement is usually the most
efficient way to remove data.

Another characteristic of the TRUNCATE statement is that it sets the high-water mark of a table back to
zero. When you use a DELETE statement to remove data from a table, the high-water mark doesn’t
change. One advantage of using a TRUNCATE statement and resetting the high-water mark is that full table
scan queries search only for rows in blocks below the high-water mark. This can have significant
performance implications for queries that perform full table scans.

Another side effect of the TRUNCATE statement is that you can’t truncate a parent table that has a
primary key defined that is referenced by an enabled foreign-key constraint in a child table—even if the
child table contains zero rows. In this scenario, Oracle will throw this error when attempting to truncate
the parent table:

ORA-02266: unique/primary keys in table referenced by enabled foreign keys

Oracle prevents you from truncating the parent table because in a multiuser system, there is a
possibility that another session can populate the child table with rows in between the time you truncate
the child table and the time you subsequently truncate the parent table. In this situation, you must
temporarily disable the child table–referenced foreign-key constraints, issue the TRUNCATE statement,
and then re-enable the constraints.

Compare the TRUNCATE behavior to that of the DELETE statement. Oracle does allow you to use the
DELETE statement to remove rows from a parent table while the constraints are enabled that reference a
child table (assuming there are zero rows in the child table). This is because DELETE generates undo, is
read-consistent, and can be rolled back.

If you need to use a DELETE statement, you must issue either a COMMIT or a ROLLBACK to complete the
transaction. Committing a DELETE statement makes the data changes permanent:*/

delete from computer_systems;

commit;

/*Note Other (sometimes not so obvious) ways of committing a transaction include issuing a subsequent DDL
statement (which implicitly commits an active transaction for a session) or normally exiting out of the client tool
(such as SQL*Plus).

When working with DML statements, you can confirm the details of a transaction by querying from
the V$TRANSACTION view. For example, say that you have just inserted data into a table; before you issue a
COMMIT or ROLLBACK, you can view active transaction information for the currently connected session as
follows:*/

insert into computer_systems(cs_id) values(1);

select xidusn, xidsqn from v$transaction;
/*
XIDUSN      XIDSQN
----------  ----------
3           12878*/

commit;

select xidusn, xidsqn from v$transaction;
--no rows selected

--Comparison of DELETE and TRUNCATE

/*
Description
|
DELETE 
|
TRUNCATE

Option of committing or rolling back changes 
|
YES 
|
NO (DDL statement is always committed after it runs.)

Generates undo 
|
YES 
|
NO

Resets the table high-water mark to zero 
|
NO 
|
YES

Affected by referenced and enabled foreign-key constraints
|
NO 
|
YES

Performs well with large amounts of data 
|
NO 
|
YES


Note Another way to remove data from a table is to drop and re-create the table. However, this means you
also have to re-create any indexes, constraints, grants, and triggers that belong to the table. Additionally, when
you drop a table, it’s temporarily unavailable until you re-create it and re-issue any required grants. Usually,
dropping and re-creating a table is acceptable only in a development or test environment.


1-8. Displaying Automated Segment Advisor Advice

Problem

You have a poorly performing query accessing a table. Upon further investigation, you discover the table
has only a few rows in it. You wonder why the query is taking so long when there are so few rows. You
want to examine the output of the Segment Advisor to see if there are any space-related
recommendations that might help with performance in this situation.

Solution

Use the Segment Advisor to display information regarding tables that may have space allocated to
them (that was once used) but now the space is empty (due to a large number of deleted rows).
Tables with large amounts of unused space can cause full table scan queries to perform poorly. This is
because Oracle is scanning every block beneath the high-water mark, regardless of whether the blocks
contain data.

This solution focuses on accessing the Segment Advisor’s advice via the DBMS_SPACE PL/SQL
package. This package retrieves information generated by the Segment Advisor regarding segments that
may be candidates for shrinking, moving, or compressing. One simple and effective way to use the
DBMS_SPACE package (to obtain Segment Advisor advice) is via a SQL query—for example:*/

SELECT
'Segment Advice --------------------------'|| chr(10) ||
'TABLESPACE_NAME : ' || tablespace_name || chr(10) ||
'SEGMENT_OWNER : ' || segment_owner || chr(10) ||
'SEGMENT_NAME : ' || segment_name || chr(10) ||
'ALLOCATED_SPACE : ' || allocated_space || chr(10) ||
'RECLAIMABLE_SPACE: ' || reclaimable_space || chr(10) ||
'RECOMMENDATIONS : ' || recommendations || chr(10) ||
'SOLUTION 1 : ' || c1 || chr(10) ||
'SOLUTION 2 : ' || c2 || chr(10) ||
'SOLUTION 3 : ' || c3 Advice
FROM TABLE(dbms_space.asa_recommendations('FALSE', 'FALSE', 'FALSE'));

/*
Here is some sample output:
Segment Advice --------------------------
TABLESPACE_NAME : USERS
SEGMENT_OWNER : MV_MAINT
SEGMENT_NAME : F_REGS
ALLOCATED_SPACE : 20971520
RECLAIMABLE_SPACE: 18209960
RECOMMENDATIONS : Perform re-org on the object F_REGS, estimated savings is 182
09960 bytes.
SOLUTION 1 : Perform Reorg
SOLUTION 2 :
SOLUTION 3 :

In the prior output, the F_REGS table is a candidate for the shrink operation. It is consuming 20 MB,
and 18 MB can be reclaimed.


How It Works

In Oracle Database 10g R2 and later, Oracle automatically schedules and runs a Segment Advisor job.
This job analyzes segments in the database and stores its findings in internal tables. The output of the
Segment Advisor contains findings (issues that may need to be resolved) and recommendations (actions
to resolve the findings). Findings from the Segment Advisor are of the following types:
    • Segments that are good candidates for shrink operations
    • Segments that have significant row chaining
    • Segments that might benefit from OLTP compression

When viewing the Segment Advisor’s findings and recommendations, it’s important to understand
several aspects of this tool. First, the Segment Advisor regularly calculates advice via an automatically
scheduled DBMS_SCHEDULER job. You can verify the last time the automatic job ran by querying the
DBA_AUTO_SEGADV_SUMMARY view:*/

select segments_processed, end_time
from dba_auto_segadv_summary
order by end_time;

/*
You can compare the END_TIME date to the current date to determine if the Segment Advisor is
running on a regular basis.

Note In addition to automatically generated segment advice, you have the option of manually executing the
Segment Advisor to generate advice on specific tablespaces, tables, and indexes (see Recipe 1-9 for details).

When the Segment Advisor executes, it uses the Automatic Workload Repository (AWR) for the
source of information for its analysis. For example, the Segment Advisor examines usage and growth
statistics in the AWR to generate segment advice. When the Segment Advisor runs, it generates advice
and stores the output in internal database tables. The advice and recommendations can be viewed via
data dictionary views such as the following:
    • DBA_ADVISOR_EXECUTIONS
    • DBA_ADVISOR_FINDINGS
    • DBA_ADVISOR_OBJECTS

There are three different tools for retrieving the Segment Advisor’s output:
    • Executing DBMS_SPACE.ASA_RECOMMENDATIONS
    • Manually querying DBA_ADVISOR_* views
    • Viewing Enterprise Manager’s graphical screens

In the “Solution” section, we described how to use the DBMS_SPACE.ASA_RECOMMENDATIONS procedure
to retrieve the Segment Advisor advice. The ASA_RECOMMENDATIONS output can be modified via three input
parameters, which are described in Table 1-5. For example, you can instruct the procedure to show
information generated when you have manually executed the Segment Advisor.

Table 1-5. Description of ASA_RECOMMENDATIONS Input Parameters

Parameter 
|
Meaning

all_runs 
|
TRUE instructs the procedure to return findings from all runs, whereas FALSE instructs
the procedure to return only the latest run.

show_manual 
|
TRUE instructs the procedure to return results from manual executions of the
Segment Advisor. FALSE instructs the procedure to return results from the automatic
running of the Segment Advisor.

show_findings 
|
Shows only the findings and not the recommendations

