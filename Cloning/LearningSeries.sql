🚀 Day 1/100 – Oracle DBA Learning Series
 📘 Topic: Bigfile Tablespace
Bigfile Tablespace is designed to simplify storage management in large Oracle databases.
 Instead of managing many small datafiles, DBAs can work with one very large datafile, making scaling and administration easier.
🔹 Things to keep in mind
 ⚠ Single datafile = higher impact if corrupted
 ⚠ Backup & restore may take longer

CREATE BIGFILE TABLESPACE bft_ts
DATAFILE '+DATA' SIZE 10G AUTOEXTEND ON;

SELECT tablespace_name, bigfile FROM dba_tablespaces;

📌 DBA Tip:
 Use Bigfile Tablespaces for large, fast-growing databases and Smallfile Tablespaces when fine control is needed.










 🚀 Day 2/100 – Oracle DBA Learning Series
 Topic: Shared Pool
The Shared Pool is a key part of the SGA that helps Oracle improve performance by reusing SQL and PL/SQL code instead of parsing it again and again.
The size of the shared pool is defined by initialization parameter SHARED_POOL_SIZE in parameter file.
🔹 What the Shared Pool stores
 ✔ Parsed SQL & execution plans
 ✔ PL/SQL procedures & functions
 ✔ Data dictionary cache
🔹 Why it matters to DBAs
 ✅ Reduces hard parsing
 ✅ Improves query performance
 ✅ Saves CPU and memory
DBA Tip:
 If the shared pool is too small, you may see library cache misses and frequent hard parses.










🚀 Day 3/100 – Oracle DBA Learning Series
 Topic: PFILE & SPFILE
Oracle databases use initialization parameter files to start the instance. These can be PFILE or SPFILE.
🔹 PFILE (Parameter File)
 • Text file (init.ora)
 • Edited manually
 • Changes need DB restart
 • Good for troubleshooting & recovery
🔹 SPFILE (Server Parameter File)
 • Binary file (spfile.ora)
 • Managed by Oracle automatically
 • Supports dynamic parameter changes
 • Required for RAC & recommended for production
LOCATION: PFILE and SPFILE are located in $ORACLE_HOME/dbs on Unix/Linux and %ORACLE_HOME%\database on Windows; in ASM environments, SPFILE is stored inside ASM disk groups.
🔹 DBA Tips
 1) Use SPFILE in production environments
 2) Keep a PFILE backup for emergency startup
 3) Convert easily when needed
 4) Oracle database needs the SPFILE (or PFILE) to start, as it contains all initialization parameters required to create the instance.








🚀 Day 4/100 – Oracle DBA Learning Series
 📘 Topic: Oracle Background Processes.
Oracle uses background processes to handle routine tasks so user sessions can run smoothly and efficiently.
🔹 Core Background Processes (Must-Know)
 • DBWn – Writes modified (dirty) blocks from memory to datafiles
 • LGWR – Writes redo from memory to redo log files
 • CKPT – Updates control files & datafile headers during checkpoints
 • SMON – Performs crash recovery & cleans temporary segments
 • PMON – Cleans up failed user sessions and frees resources
🔹 Redo & Archiving
 • ARCn – Archives redo logs (ARCHIVELOG mode)
🔹 Why They Matter to DBAs
 ✅ Ensure data consistency
 ✅ Improve performance
 ✅ Enable recovery after failures
📌 DBA Tip:
 If background processes are not running or are stuck, the database performance and recovery are at risk.








🚀 Day 5/100 – Oracle DBA Learning Series
 Topic: Logical VS Physical Components in Oracle Database.
Oracle database architecture is built on logical components (how data is organized) and physical components (where and how data is stored).
🔹Logical Components (Design Layer)
 • Tablespaces – Logical storage containers
 • Segments – Tables, indexes, undo, temp
 • Extents – Group of blocks
 • Data Blocks – Smallest logical unit

🔹 How Tablespaces work
Table → Segment → Extent → Block → Datafile

🔹Physical Components (Storage & Files)
 • Datafiles – Store actual database data
 • Control Files – DB structure & status info
 • Redo Log Files – Record all data changes
 • Archive Log Files – Used for media recovery
 • Parameter Files (PFILE/SPFILE) – Startup settings
 • Password File – SYS authentication
 • Backup Files – RMAN / OS backups
 • Trace Files – Detailed error diagnostics
 • Alert Log File – Database health log

📌 DBA Tip:
 Developers work with logical objects, DBAs manage physical files.







🚀 Day 6/100 – Oracle DBA Learning Series
 📘 Topic: Tablespaces in Oracle DBA.
Tablespaces are logical storage units in Oracle that organize how data is stored inside the database.
🔹 Main Types of Tablespaces
• SYSTEM – Core metadata of the database (must always be online)
 • SYSAUX – Auxiliary metadata (AWR, OEM, etc.)
 • UNDO – Stores undo data for rollback & read consistency
 • TEMP – Used for sorting, joins, and temporary operations
 • USER – Stores application/user data
 • BIGFILE – Uses one very large datafile for large databases
 • SMALLFILE – Uses multiple datafiles (default type)
 • READ ONLY – Data that does not change (reports, history)
🔹 Why DBAs Must Know This
 ✅ Proper data organization
 ✅ Better performance & space management
 ✅ Smooth backup & recovery
📌 DBA Tip:
 Never store user data in SYSTEM or SYSAUX tablespaces.







🚀 Day 7/100 – Oracle DBA Learning Series
 Topic: TEMP Tablespace vs UNDO Tablespace
Both TEMP and UNDO tablespaces are critical in Oracle, but they serve completely different purposes.
🔹 TEMP Tablespace
 • Used for sorting, joins, GROUP BY, ORDER BY
 • Stores temporary data only
 • Data is not recovered after a crash
 • Used by queries when memory is not enough
🔹 UNDO Tablespace
 • Stores before-image of data
 • Used for ROLLBACK, read consistency, flashback
 • Required for transaction recovery
 • Data is recovered after a crash.
📌 DBA Tip:
 TEMP helps queries run fast, UNDO protects data consistency — both are mandatory for a healthy database.








🚀 Day 8/100 – Oracle DBA Learning Series
 Topic: OLTP VS OLAP in Oracle DBA
Oracle databases are commonly designed for OLTP or OLAP workloads. Knowing the difference helps DBAs design and tune systems correctly.
🔹 OLTP (Online Transaction Processing)
 • Used for day-to-day transactions
 • Handles many small INSERT/UPDATE/DELETE operations
 • Fast response time
 • Examples: Banking, e-commerce, ERP

🔹 OLAP (Online Analytical Processing)
 • Used for reporting and analysis
 • Handles large SELECT queries
 • Works on historical data
 • Examples: Data warehouse, BI reports

How Both Coexist in Real Life?
OLTP (Live App DB)
 ↓
 Data copied via ETL / GoldenGate
 ↓
OLAP (Data Warehouse)

📌 DBA Tip:
 OLTP needs indexing and undo tuning, while OLAP benefits from partitioning, parallelism, and large scans.

 Ever wondered where OLTP and OLAP are used in real life?
OLTP runs the business (When customers use an e-commerce website)
->Customer orders, payments, inventory updates — many small and fast transactions happening every second.

OLAP analyzes the business (Analyzing the Business (Reports System))
->Sales reports, trends, comparisons — large SELECT queries on historical data.








🚀 Day 9/100 – Oracle DBA Learning Series
 Topic: Alert Log File

The Alert Log File is one of the most important files for an Oracle DBA.
It acts like a health diary of the database.

 What does it record?
. Database startup & shutdown
. Errors (ORA- errors)
. Tablespace issues
. Checkpoints & background process messages

🤔Why is it important?
Whenever something goes wrong in the database, the first place a DBA checks is the Alert Log.
It helps in quick troubleshooting and proactive monitoring.

📍 Default Location:
$ORACLE_BASE/diag/rdbms/<DB_NAME>/<DB_NAME>/trace/alert_<DB_NAME>.log

💡 DBA Tip:
Make it a habit to check the alert log daily to avoid unexpected issues.






🚀 Day 10/100 – Oracle DBA Learning Series
 Topic: How SELECT & UPDATE Queries Work Internally in Oracle
From the moment a user hits Enter, Oracle performs parsing, semantic checks, memory lookups, and disk access before showing results on the client.

Here’s the step-by-step flow in simple terms
SELECT Query Flow
1) User submits SQL from client (SQL*Plus / App)
 2) Parsing starts
 • Syntax check (SQL is written correctly)
 • Semantic check (table, column, privileges exist)
 3) Oracle checks Shared Pool
 • If SQL exists → Soft parse
 • If not → Hard parse & execution plan created
 4) Server process fetches data
 • From Buffer Cache (if available)
 • Else from Datafiles (disk)
 5) Result set is sent back to client
 6) Client displays the output to user

UPDATE Query Flow
 1) SQL is parsed (syntax + semantic checks)
 2) Undo data is generated (for rollback & consistency)
 3) Data blocks updated in Buffer Cache
 4) Redo generated and written by LGWR
 5) On COMMIT → changes are permanent
 6) DBWn later writes dirty blocks to datafiles

📌 Key DBA Insight
• SELECT → Read operation (no redo for data change)
 • UPDATE → Generates UNDO + REDO
 • Performance depends on parsing, memory, and I/O






🚀 Day 11/100 – Oracle DBA Learning Series.
 Topic :  User Management & How It Works

User management is a core DBA responsibility to ensure database security, access control, and accountability.

💥 What DBAs Do in User Management
 • Create & drop users
 • Grant and revoke privileges
 • Assign roles
 • Manage passwords & profiles
 • Lock and unlock accounts
💥 Types of Privileges
 • System privileges – CREATE USER, CREATE TABLE
 • Object privileges – SELECT, INSERT, UPDATE on objects
 • Roles – Group of privileges for easier management
💥 Profiles (Security Control)
 • Password policies
 • Resource limits (sessions, CPU)

---> Basic Commands
CREATE USER app_user IDENTIFIED BY password;
GRANT connect, resource TO app_user;
ALTER USER app_user ACCOUNT LOCK;

📌 DBA Tip:
Always follow the principle of least privilege — give users only what they need.








🚀 Day 12/100 – Oracle DBA Learning Series
 Topic: Roles VS Privileges

Roles and privileges are the foundation of database security in Oracle. They define who can access what and what actions they can perform.

Privilege allows a user to perform a specific action.
Examples of privileges:
CREATE TABLE → create tables
SELECT → read data from a table
INSERT → add data into a table

ROLE is a collection of privileges grouped together.

example:
Instead of granting SELECT and INSERT to every user, DBAs create a role and assign it — cleaner, safer, and easier to manage.

Grant Privileges Directly (Hard to manage if many users exist)
GRANT SELECT, INSERT ON employees TO app_user;

Use a Role (Reusable for multiple users)
CREATE ROLE app_read_write;
GRANT SELECT, INSERT ON employees TO app_read_write;
GRANT app_read_write TO app_user;

💥 DBA Best Practices
1)Use roles for general access
2)Grant critical privileges directly
3)Follow least privilege principle






🚀 Day 13/100 – Oracle DBA Learning Series
 Topic: Networking in Oracle DBA

Oracle networking allows clients and applications to connect to the Oracle database securely and efficiently.
💥 Key Networking Components
 • Listener – Listens for incoming connection requests
 • Service Name / SID – Identifies the database service
 • tnsnames.ora – Client-side connection details
 • listener.ora – Listener configuration file
 • sqlnet.ora – Controls security and connection behavior

💥 Why Networking Matters to DBAs
 1) Ensures application connectivity
 2) Supports load balancing & failover
 3) Helps troubleshoot connection issues

📌 DBA Tip:
 Most connection issues are related to listener status, service name, or network files.







🚀 Day 14/100 – Oracle DBA Learning Series
 Topic : Startup & Shutdown Modes

Starting and stopping an Oracle database is a core DBA task. Understanding the phases helps in maintenance, recovery, and troubleshooting.
💥 Startup Phases
A) NOMOUNT
 • Reads PFILE/SPFILE
 • Allocates memory (SGA)
 • Starts background processes
B) MOUNT
 • Opens control files
 • Database knows its structure
C) OPEN
 • Opens datafiles & redo logs
 • Database is ready for users

💥 Shutdown Modes
 A) NORMAL – Waits for users to disconnect
 B) IMMEDIATE – Disconnects users, safe & common
 C) TRANSACTIONAL – Waits for active transactions
These are also known as Graceful shutdown.

 D) ABORT – Force stop (used in emergencies)
This is also known as Non-Graceful shutdown.

📌 DBA Tip:
 Use SHUTDOWN IMMEDIATE for planned maintenance and ABORT only as a last option.








🚀 Day 15/100 – Oracle DBA Learning Series
 Topic : Redo Log File Management.

Redo log files are critical in Oracle because they record every change made to the database. They help Oracle recover data after failures.
💥What Are Redo Log Files?
 • Store redo entries (change records)
 • Written by LGWR process
 • Required for instance & crash recovery

--> Types of Log Switch
Manual Log Switch → Triggered by DBA

ALTER SYSTEM SWITCH LOGFILE;
Automatic Log Switch → Happens when current redo log becomes full

💥Redo Log File Status & Meaning
Status Meaning
CURRENT - Currently being written by LGWR
ACTIVE - Needed for recovery, not yet reusable
INACTIVE - No longer needed, can be reused
UNUSED - Never used since creation

1)Check Redo Log Status
SELECT group#, status FROM v$log;
SELECT member FROM v$logfile;

2)Add Redo Log Group
ALTER DATABASE ADD LOGFILE
GROUP 4 ('/u01/oradata/redo04.log') SIZE 200M;

3)Add Member
ALTER DATABASE ADD LOGFILE MEMBER
'/u02/oradata/redo01b.log' TO GROUP 1;

4)Drop Redo Log Group
ALTER DATABASE DROP LOGFILE GROUP 4;

5)Drop Redo Log Member
ALTER DATABASE DROP LOGFILE MEMBER

📌 DBA Tips
 • Use multiplexing for safety
 • Avoid dropping CURRENT or ACTIVE redo logs
 • Monitor frequent log switches











🚀 Day 16/100 – Oracle DBA Learning Series
 Topic: Static and Dynamic Parameters in Oracle Database.

In Oracle DBA, initialization parameters control how the database behaves.
 These parameters are mainly of two types 👇
1)Static parameters : 
Parameters that cannot be changed while the database is running.They require a database restart to take effect.Used for core database structure, so changes must be planned during maintenance windows.
Examples:
db_name, db_block_size, control_files
Scope: Scope decides when and how long the change applies.
SCOPE=SPFILE only

2)Dynamic Parameters:
Dynamic parameters can be changed while the database is OPEN, without restarting.Mostly used for performance tuning and workload management.
Examples:
memory_target, pga_aggregate_target, open_cursors
Scope options: Scope decides when and how long the change applies.
SCOPE=MEMORY → Change valid until next restart
SCOPE=SPFILE → Change effective after restart
SCOPE=BOTH → Change immediately and persist after restart








🚀 Day 17/100 – Oracle DBA Learning Series
 Topic: Compression in Oracle DBA.

Compression in Oracle is used to reduce storage usage and improve performance by storing data in a compressed format.
 a)Used in tables, indexes, backups, and Data Pump
 b)Best for read-heavy workloads
 c)Trades extra CPU for lower storage cost.

💥 Types of Compression in Oracle
1) Table Compression
Basic Compression → For bulk loads
OLTP Compression → For frequent INSERT/UPDATE
Advanced Compression → Better compression + performance
2) Index Compression
Compresses repeated values in index keys
Useful for large indexes
3) Backup Compression (RMAN)
Reduces backup size
Uses more CPU but saves storage
4) Data Pump Compression
Compresses exported data
Faster transfers, smaller dump files.

 How It Works ?
Oracle finds duplicate values in blocks → stores them once → references them → less space, fewer reads.
💡 DBA Tip:
 Compression saves space but uses extra CPU, so always test before enabling in production.







🚀 Day 18/100 – Oracle DBA Learning Series
 Topic: TEMP Tablespace Groups

TEMP Tablespace Groups allow multiple temporary tablespaces to work together as one logical unit. Oracle automatically uses available temp space across the group.

👉 Why TEMP Tablespace Groups?
 • Supports RAC & high concurrency
 • Better load distribution
 • Prevents temp space bottlenecks
 • Improves query performance
👉 How It Works?
 • Multiple TEMP tablespaces are grouped
 • Sessions use any available temp space
 • Oracle balances usage automatically
👉 Is TEMP Tablespace Group compulsory?
No,Oracle works perfectly fine with a single TEMP tablespace.
👉 How many TEMP tablespaces can be added to a TEMP group?
Oracle does not set a hard limit on the number of TEMP tablespaces in a TEMP group.
👉 When TEMP Tablespace Group is NOT needed ?
 • Single-instance database
 • Low or moderate workload
 • Minimal sorting / reporting

📌 DBA Tip:
 TEMP tablespace groups are highly recommended in RAC environments and systems with heavy sorting.







🚀 Day 19/100 – Oracle DBA Learning Series
 Topic: Oracle Multitenant vs Non-Multitenant Architecture.

1) Non-Multitenant (Traditional Architecture)
 • One database = one application
 • Separate memory & background processes
 • Simple but resource-heavy
 👇 Supported Versions:
 • Oracle 10g
 • Oracle 11g
 • Oracle 12c (deprecated from 12.2)

 2)Multitenant Architecture
 • One CDB with multiple PDBs
 • Shared memory & background processes
 • Easy patching, cloning & consolidation
👇 Supported Versions:
 • Oracle 12c (introduced)
 • Oracle 18c
 • Oracle 19c (recommended LTS)
 • Oracle 21c & later.

💥 Important DBA Note:
 From Oracle 19c onward, multitenant architecture is mandatory (CDB + PDB).
Traditional non-CDB is legacy; multitenant is the present and future.








🚀 Day 20/100 – Oracle DBA Learning Series
Topic : Common ORA Errors Every L1 & L2 DBA Should Know.

🔹 L1 DBA – Monitoring & User Issues
1) ORA-00054 (Resource busy)
 Approach 👇 
 Wait for transaction to finish or use NOWAIT carefully.
 Check blocking sessions before retrying.
2) ORA-01017 (Invalid username/password)
 Approach 👇 
 Verify username/password and case sensitivity.
 Check account status and password expiry.
3) ORA-01109 (Database not open)
 Approach 👇 
 Start database using STARTUP.
 Confirm database state using V$INSTANCE.
4) ORA-01555 (Snapshot too old)
 Approach 👇 
 Increase UNDO tablespace size.
 Tune long-running queries.
5) ORA-12154 (TNS resolution error)
 Approach 👇 
 Check tnsnames.ora entry.
 Verify service name and network configuration.

🔹 L2 DBA – Storage, Memory & Recovery
1) ORA-01157 / ORA-01110 (Datafile missing)
 Approach 👇
 Check datafile location and OS permissions.
 Restore or recover the missing datafile.
2) ORA-01653 (Tablespace full)
 Approach 👇
 Add datafile or enable autoextend.
 Monitor space usage proactively.
3) ORA-16014 (Archive destination full)
 Approach 👇
 Clear old archive logs.
 Increase archive destination space.
4) ORA-04031 (Shared pool memory issue)
 Approach 👇
 Flush shared pool or increase memory.
 Check for memory fragmentation.
5) ORA-00257 (Archiver error)
 Approach 👇 
 Free archive destination space immediately.
 Take backup and delete old archive logs.

📌 DBA Golden Rule:
 Always check alert log and trace files before applying a fix.








🚀 Day 21/100 – Oracle DBA Learning Series
Topic: RESETLOGS in Oracle DBA.
 
RESETLOGS is used when Oracle starts a new redo log sequence after an incomplete recovery or major database change.

👉 When is RESETLOGS Required?
1)After incomplete recovery
2) After restoring control file from backup
3)After using backup controlfile
4)After database structure changes.

👉 What Happens During RESETLOGS?
 1) Redo log sequence is reset
 2) Old redo logs become invalid
 3) New incarnation of database is created
 4) Previous backups become unusable for recovery.

command
ALTER DATABASE OPEN RESETLOGS;

💥 Important DBA Rules
 1)Always take a FULL BACKUP immediately after RESETLOGS
 2)RESETLOGS is not reversible
 3) Use only when required








🚀 Day 22/100 – Oracle DBA Learning Series
Topic : Types of Backups in Oracle DBA.

Backups protect the database from data loss, corruption, and failures.
Every DBA must know which backup to use and when.
Types of backups 👇 

1)Physical Backups (RMAN)
 Used for fast and reliable recovery.
 a) Full Backup → Entire database
 b) Incremental Level 0 → Base backup
 c) Incremental Level 1 → Changes since last backup
 Differential
 Cumulative
(Will explain this in next post)

2)Logical Backups (Data Pump)
👉 Used for migration & logical recovery (not point-in-time).
a)Export (expdp) → Schema / table level
b) Import (impdp) → Restore selected data
(Will explain this in further posts)

 3)Hot & Cold Backup
 a) Hot Backup → DB open (ARCHIVELOG mode)
 b) Cold Backup → DB closed (no redo needed)
(Will explain this in further posts)

📌 DBA Rule:
 No backup = No recovery.








🚀 Day 23/100 – Oracle DBA Learning Series
Topic : Physical Backups in Oracle DBA (With Explanation & Commands)

Physical backups are exact copies of Oracle database files like datafiles, control files, and redo logs. They are taken using RMAN and used for complete recovery.
Types of Physical Backups 👇 

1) Full Database Backup
Backs up all datafiles in the database.Used as base backup.
RMAN> BACKUP DATABASE;

2)Incremental Backup
Backs up only changed data blocks, saving time and space.

a) Level 0 → Base incremental backup
RMAN> BACKUP INCREMENTAL LEVEL 0 DATABASE;

b) Level 1 Differential → Changes since last backup
Backs up only the blocks changed since the last incremental backup (Level 0 or Level 1).
Smaller & faster backups, Recovery needs more backup pieces.
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;

c) Level 1 Cumulative → Changes since last Level 0
Backs up all blocks changed since the last Level 0 backup.
Larger backup size, Faster recovery (fewer backups to apply)
RMAN> BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE;

3) Control File Backup
Backs up database structure (datafiles, redo logs info).
RMAN> BACKUP CURRENT CONTROLFILE;

4) SPFILE Backup
Backs up database initialization parameters.
RMAN> BACKUP SPFILE;

5) Archive Log Backup
Backs up archived redo logs for point-in-time recovery.
RMAN> BACKUP ARCHIVELOG ALL;








Day 24 | Oracle DBA Learning Series
Topic: Logical Backups in Oracle DBA.

Logical backups capture database objects and data (not physical files) and are mainly taken using Oracle Data Pump (EXPDP / IMPDP).
Why DBAs use Logical Backups ????????
👉 Object-level recovery & Easy data migration
👉 DEV/TEST refresh
👉 Cross-version and cross-platform support

Types of Logical Backups 👇 

1) Full Database Logical Backup
Backs up the entire database logically. Used for migrations and cloning
 (not a replacement for RMAN).
SQL> expdp system/password full=y directory=DATA_PUMP_DIR dumpfile=full_db.dmp logfile=full_db.log

2)Table-level Logical Backup
Backs up one or more specific tables, Used when only a few tables need recovery or migration.
SQL> expdp system/password tables=HR.EMPLOYEES directory=DATA_PUMP_DIR dumpfile=emp_tab.dmp logfile=emp_tab.log

3)Schema-level Logical Backup
Backs up all objects owned by a user (tables, indexes, procedures, etc.).
Most commonly used by DBAs.
SQL> expdp system/password schemas=HR directory=DATA_PUMP_DIR dumpfile=hr_schema.dmp logfile=hr_schema.log

4)Tablespace-level Logical Backup
Backs up all objects stored in a specific tablespace.
Useful when applications are separated by tablespaces.
expdp system/password tablespaces=USERS directory=DATA_PUMP_DIR dumpfile=users_ts.dmp logfile=users_ts.log

💥Limitations to remember:
a)Slower for large databases.
b)No point-in-time recovery.
c)Needs database to be OPEN.







Day 25 | Oracle DBA Learning Series
Topic: Corruptions in RMAN – What Every DBA Should Know.

In Oracle DBA, corruption means data is damaged and cannot be read correctly. RMAN helps us detect, report, and recover from these issues.
RMAN is not just for backups—it’s your first line of defense against data corruption.
Types of Corruption RMAN Handles:

 1) Physical Corruption
 Occurs when database blocks are damaged at the OS or storage level.
 👉 Example: Disk issues, bad sectors, I/O problems.
 Detected by RMAN during backup or validation.

 2) Logical Corruption
 Block structure is fine, but data inside is invalid or inconsistent.
 👉 Example: Wrong data values due to bugs or software issues.
 Detected using RMAN VALIDATE or CHECK LOGICAL.

🤔 How RMAN Detects Corruption ????
 a)During backup or During RESTORE
 b)Using VALIDATE DATABASE / DATAFILE
 c)Stored in V$DATABASE_BLOCK_CORRUPTION

📌 RMAN Commands to Detect Corruption
1)Validate entire database
 RMAN> VALIDATE DATABASE;
2)Validate with logical check
RMAN> VALIDATE DATABASE CHECK LOGICAL;
3)Validate specific datafile
RMAN> VALIDATE DATAFILE 5;
4)Validate backupsets
RMAN> VALIDATE BACKUPSET 123;
5)Check Corrupted Blocks
SQL> SELECT * FROM V$DATABASE_BLOCK_CORRUPTION;
6)Recover Corrupted Blocks
RMAN> BLOCKRECOVER DATAFILE 5 BLOCK 123;

💥 Best Practices
 👉 Run periodic RMAN VALIDATE
 👉 Monitor alert log and RMAN output
 👉 Keep multiple backups
 👉 Act early—small corruption can become a big outage







Day 26 | Oracle DBA Learning Series
Topic : Types of Indexes in Oracle DBA.

Indexes help Oracle find data faster, just like an index in a book. Choosing the right index is a key DBA skill. 
Choosing the right index type is a key DBA responsibility.

1) B-Tree Index (Default | Non-Clustered Equivalent)
 Stores index separately from table data.
Used for =, <, >, and range queries.
 👉 Best for OLTP systems and high-cardinality columns.

2) Bitmap Index
 Uses bitmaps instead of row pointers.
Best for low-cardinality columns (status, gender, flags).
 👉 Best for low-cardinality columns in OLAP systems.

3) Unique Index
 Ensures column values are unique.
 👉 Automatically created for PRIMARY KEY & UNIQUE constraints.

4) Composite Index
 Index created on multiple columns.
 👉 Column order matters for performance.

5) Function-Based Index
 Index built on expressions or functions.
 👉 Used when WHERE clause applies functions.

6) Reverse Key Index
 Reverses index values to avoid hot blocks.
 👉 Useful for high-insert workloads.

7) Invisible Index
 Not used by optimizer unless enabled.
 👉 Helps test index impact safely.

8) Cluster Index
 Used with clustered tables where related rows are stored together.
 👉 Improves joins on clustered columns.

9) Index Organized Table (IOT – Clustered Behavior)
 Table data itself is stored inside the index.
 👉 Faster access when data is always queried via primary key.

📌 Index Rebuilding (DBA Maintenance)
 Rebuilds index to remove fragmentation and improve performance.
 👉 Often done after heavy DML or space issues.








Day 27 | Oracle DBA Learning Series
Topic : Index Fragmentation & Index Rebuilding in Oracle DBA.

Indexes speed up queries, but over time they can lose efficiency. That’s where index fragmentation and index rebuilding come in.

📌 What is Index Fragmentation?
Index fragmentation happens when index entries are not stored in order or contain unused space due to frequent INSERT, UPDATE, and DELETE operations.
It happens when the logical order of index entries no longer matches the physical order on disk.

The index becomes scattered, so Oracle needs more I/O to read it.
1) Logical Fragmentation – Index entries are scattered
2) Space Fragmentation – Empty blocks after large deletes

📌 What is Index Rebuilding?
Index rebuilding recreates the index from scratch using existing data.
 • Removes fragmentation
 • Reclaims unused space
 • Improves index structure
Think of it like reorganizing a messy book index into a clean, sorted one.

📌 When Should a DBA Rebuild an Index?
 1) After bulk DELETE operations
 2) When index height (BLEVEL) increases
 3) When index size is much larger than expected
 4) Performance issues linked to index scans
🚫 Not needed after every DML (common myth!)

DBA Tip:
Unnecessary index rebuilds can waste CPU and I/O. Always rebuild only when required.






Day 28 | Oracle DBA Learning Series
Topic: DB Links in Oracle DBA (With Commands)

A Database Link (DB Link) allows one Oracle database to access objects in another Oracle database.
A DB Link is a bridge between two databases.
📌 How It Works ?
a) Query uses @dblink_name
b) Oracle connects using TNS entry
c) Authentication happens
d) Data is fetched from remote DB

Types of DB Links & Commands
1) Private DB Link
Accessible only to the user who creates it.
SQL>CREATE DATABASE LINK remote_db
CONNECT TO hr IDENTIFIED BY password
USING 'ORCL' ;

2) Public DB Link
Accessible to all users in the database.
SQL> CREATE PUBLIC DATABASE LINK remote_db
CONNECT TO hr IDENTIFIED BY password
USING 'ORCL' ;

Using a DB Link
a) Query remote table:
SQL> SELECT * FROM employees@remote_db;
b) Insert into remote table:
SQL> INSERT INTO employees@remote_db VALUES (...);

Drop a DB Link
PRIVATE 👇 
SQL> DROP DATABASE LINK remote_db;
PUBLIC 👇 
SQL> DROP PUBLIC DATABASE LINK remote_db;

🔹 DBA Best Practices
 a) Avoid hardcoding passwords & Prefer private over public DB links
 b) Monitor performance & Drop unused DB links
 c) Secure network communication








Day 29 / Oracle DBA Learning Series
 Topic: MATERIALIZED VIEWS in Oracle DBA

Materialized Views (MV) are physical copies of query results stored in the database.
Unlike normal views (which run the query every time), Materialized Views store data and refresh it when needed.
They are mainly used for:
 a) Performance improvement
 b) Reporting systems
 c) Data warehouse environments
 d) Reducing load on base tables.

 📌 When Should a DBA Use Materialized Views?
 a) Large reporting queries & Complex joins
 b) Aggregations & When performance tuning alone is not enough.

📌 How Materialized Views Work
Data is selected from one or more tables
Result is stored physically
It can be refreshed:
ON COMMIT
ON DEMAND
Scheduled

Types of Refresh
1) COMPLETE Refresh
2) FAST Refresh
3) FORCE Refresh
(Explanation will be done in next post)

💥 Important DBA Points
👉 FAST refresh requires MV Logs
👉 Monitor refresh time
👉 Avoid unnecessary frequent refresh
👉 Keep statistics updated
👉 Check staleness from DBA_MVIEWS









Day 30 | Oracle DBA Learning Series
Topic : TYPES OF REFRESH in MATERIALIZED VIEWS (Oracle DBA)

Materialized Views (MV) store query results physically.
But the real power lies in how they refresh.
Let’s understand all refresh types in simple words 👇 

1) COMPLETE REFRESH
 Rebuilds the entire Materialized View
 Deletes old data and re-inserts fresh data
 Heavy but simple
 👉 Best when data change is large
 👉 No need for MV logs
SQL> EXEC DBMS_MVIEW.REFRESH('MV_NAME','C');

 2) FAST REFRESH
Refreshes only changed data
Uses Materialized View Logs
Very efficient
👉 Best for large tables with small changes
👉 Requires PRIMARY KEY or ROWID.
SQL> EXEC DBMS_MVIEW.REFRESH('MV_NAME','F');

3) FORCE REFRESH
 Oracle decides FAST or COMPLETE
 If fast refresh possible → does FAST
 Else → does COMPLETE
SQL> EXEC DBMS_MVIEW.REFRESH('MV_NAME','?');

4) ON COMMIT REFRESH
Refresh happens automatically when transaction commits
Keeps MV always up to date
Can slow DML operations
While Creating MV:
SQL> REFRESH FAST ON COMMIT

5) ON DEMAND REFRESH
Manual refresh
Controlled by DBA
Most commonly used
While Creating MV:
SQL> REFRESH FAST ON DEMAND

📌 Simple Rule
Need real-time → ON COMMIT
Need control → ON DEMAND
Small changes → FAST
Large changes → COMPLETE











Day 31 | Oracle DBA Learning Series
Topic : CLONING in Oracle DBA (Explained Simple).

Cloning means creating an exact copy of an Oracle database.
DBAs use cloning for 👇🏼 
Testing, Development, Backup validation, Reporting, Migration.

📌 What Happens During Cloning?
Cloning copies:
Datafiles
Control files
Redo logs
SPFILE / PFILE
Database structure
Result → A new database that works like the original.

 Types of Cloning in Oracle

1) Cold Cloning (Offline Clone)
 It is simple but requires downtime.
 a) Shutdown source database 
 b)Copy datafiles physically
 c) Start cloned database

2) Hot Cloning (Online Clone)
It is Production-friendly and Most commonly used.
 a) Database stays OPEN
 b) Uses RMAN
 c) No downtime
Basic RMAN Example :
RMAN> DUPLICATE TARGET DATABASE TO CLONE_DB;

3) RMAN Active Database Duplication
 It is Fast and Preferred in modern setups
 a) No need for backup
 b) Copies directly from running database.
RMAN> DUPLICATE TARGET DATABASE TO CLONE_DB FROM ACTIVE DATABASE;

4) Cloning Using Backup
 a) Restore from RMAN backup
 b) Recover database
It is Useful when Migrating servers and Disaster recovery testing.

📌 Important DBA Points
 a) Always change DB_NAME / DBID and Update listener & tnsnames
 b) Reset passwords if required and Check archive log mode
 c) Verify application connectivity and Run post-clone cleanup.
📌 Common Mistakes
❌ Forgetting to change DBID
 ❌ Not renaming redo logs
 ❌ Missing parameter file changes
 ❌ Not opening database with RESETLOGS (when required)







Day 32 | Oracle DBA Learning Series
Topic : MIGRATIONS in Oracle DBA (Explained Simple).

Migration means moving an Oracle database from one place to another. DBAs use migration for 👇 New server, Cloud move, Version upgrade, Platform change, Storage change.

📌 Why Migration Matters? 
Wrong migration = Data loss + Downtime + Business impact. 
Right migration = Zero data loss + Minimal downtime + Happy team. 

Types of Migrations in Oracle DBA

1) Platform Migration Moving DB from one OS to another (Linux → Windows or vice versa). 
    a) Use RMAN or Data Pump 
    b) Check endian format compatibility 
    c) Use RMAN CONVERT DATABASE for cross-platform.

2) Version Upgrade Migration Moving from old Oracle version to new (11g → 19c). 
    a) Run Pre-Upgrade Info Tool first 
    b) Use DBUA (Database Upgrade Assistant) 
    c) Compile invalid objects after upgrade.

3) On-Premises → Cloud Migration Moving DB from local server to Oracle Cloud (OCI) or AWS. 
    a) Use Oracle Zero Downtime Migration (ZDM) tool 
    b) Or use GoldenGate for real-time sync 
    c) Or use Data Pump + Object Storage.

4) Schema / Data Migration Moving specific tables or schemas between databases. 
    a) Export : expdp system/pwd schemas=HR directory=DPDIR dumpfile=hr.dmp 
    b) Import : impdp system/pwd schemas=HR directory=DPDIR dumpfile=hr.dmp 
    c) Fast and most commonly used by DBAs.

5) Non-Oracle → Oracle Migration Moving SQL Server / MySQL data to Oracle. 
    a) Use SQL Developer Migration Workbench 
    b) Convert data types manually where needed 
    c) Test all stored procedures and functions.

6) Transportable Tablespace Migration Move specific tablespace from one DB to another quickly. 
    a) Make tablespace READ ONLY 
    b) Use expdp with TRANSPORT_TABLESPACES option 
    c) Copy datafiles + import metadata on target.

👉🏼  General Migration Steps Every DBA Must Follow
Step 1 → Plan : Check DB size, downtime window, rollback plan.
Step 2 → Pre-checks : Invalid objects, space, health check.
Step 3 → Backup : Always take full RMAN backup before starting. 
Step 4 → Execute : Run migration using right tool.
Step 5 → Validate : Row counts, objects, app connectivity, performance

 Key Tools Used in Oracle Migration 
→ RMAN
→ Data Pump (expdp / impdp)
→ Oracle GoldenGate 
→ DBUA (Database Upgrade Assistant) 
→ SQL Developer Migration Workbench 
→ Zero Downtime Migration (ZDM) 
→ Transportable Tablespace.

DBA Tips 
1) Always test in UAT before touching Production
2) Keep rollback plan ready before every migration 
3) Document every step — logs save you during issues.
4) Use GoldenGate for near-zero downtime migration





Day 35 | Oracle DBA Learning Series
Topic : Split Brain Syndrome in Oracle RAC 

📌 What is Split Brain?
 Split Brain happens when:
 👉 Node1 cannot see Node2
 👉 Node2 cannot see Node1
 👉 Both think they are the only active node
This can cause data corruption if not handled properly.

⚠️ Causes:
1) Private interconnect / NIC failure
2) Network switch failure between nodes 
3) OS hang or high load on a node 
4) Misconfigured interconnect.

Basic commands every dba should know

 1) Check Cluster Status
     crsctl check cluster -all
     crsctl stat res -t
 2) Check Node Status
     olsnodes -n
3) Check Voting Disk
     crsctl query css votedisk
4)  Check Interconnect Information
     oifcfg getif
5) Check CRS Alerts (for eviction details)
     cd $GRID_HOME/log/<node_name>/crsd/
6) Check alert log:
     tail -f alert.log
7) Check Database Instances
     SELECT inst_id, instance_name, status 
      FROM gv$instance;

To avoid split brain, Oracle uses a mechanism called:
👉 Node Eviction
The node that loses communication or voting majority is automatically removed (evicted) from the cluster.
This protects the database from corruption.

📌  How Oracle Prevents Split Brain
 a) Voting disk majority rule(Always use ODD number of voting disks (3 or 5)). 
 b) Clusterware heartbeat monitoring
 c) Automatic node eviction
 d) Fencing mechanism
Oracle chooses safety over availability.













📌Oracle DBA Knowledge Day 148:- Checking Oracle RAC Cluster Health

Monitoring the health of your Oracle RAC cluster is critical to ensure high availability and performance. As a DBA, you should regularly verify that all cluster components are running properly.

🔍 1. Check Cluster Status
crsctl check cluster -all
✔ Verifies Clusterware status on all nodes

🔍 2. Check Cluster Resources
crsctl stat res -t
✔ Shows status of all resources (database, ASM, listeners, services)

🔍 3. Check Node Applications
crsctl stat res -t -init
✔ Displays node-level resources like VIP, network, and ONS

🔍 4. Verify Database Status
srvctl status database -d <db_name>

🔍 5. Verify Instance Status
srvctl status instance -d <db_name>

🔍 6. Check ASM Status
srvctl status asm

🔍 7. Check Voting Disk
crsctl query css votedisk

🔍 8. Check OCR Health
ocrcheck

💡 Why This Matters?
Regular health checks help detect issues early — preventing node eviction, service downtime, or cluster failures.

🔥 Pro Tip:
Make a daily checklist for RAC health monitoring — this is often asked in interviews and required in production support roles.










Turning Instability into Reliability: Oracle DBA Case Study

I encountered repeated database crashes and file corruption due to missing ARCHIVELOG mode and incomplete backup routines.
By systematically addressing the issues, I:

Enabled ARCHIVELOG mode to ensure consistent recovery

Implemented RMAN backups (datafiles, archivelogs, controlfile, SPFILE)

Configured controlfile autobackup for metadata safety

Applied retention policy + delete obsolete to keep the Fast Recovery Area clean

The result: a stable environment, error‑proof backups, and instant recovery capability with zero data loss.

👉 Key takeaway: A disciplined backup and recovery strategy is not just technical hygiene — it is the backbone of business continuity.


--Enable ARCHIVELOG mode
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;
SQL> ALTER DATABASE ARCHIVELOG;
SQL> ALTER DATABASE OPEN;

--Take full backup with archivelogs
rman target /
backup database plus archivelog;

--Crosscheck backups
crosscheck backup;

--Report obsolete backups
report obsolete;

--Delete obsolete backups
delete obsolete;

--Show RMAN configuration
show all;

--Configure retention policy(example: keep 2 backups)
configure retention policy to recovery window of 2 days;
configure controlfile autobackup on;
configure retention policy to redundancy 2;

