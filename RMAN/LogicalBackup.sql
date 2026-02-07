Topic: Logical Backups in Oracle DBA.

Logical backups capture database objects and data (not physical files) 
and are mainly taken using Oracle Data Pump (EXPDP / IMPDP).

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

Continuing my Journey of #100DaysOfOracleDBA by breaking complex oracle concepts into simple words.
#OracleDBA #LogicalBackup #DataPump #EXPDP