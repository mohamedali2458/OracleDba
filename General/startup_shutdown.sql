Startup
startup nomount;
startup mount;
startup open;

startup nomount;
alter database mount;
alter database open;

startup mount;
alter database open;

shutdown;
shutdown normal;
shutdown immediate;
shutdown abort;

startup force;

shutdown process step by step
alter database close;
alter database dismount;
shutdown;

SYS @ oradb > startup pfile=initoradb.ora
ORA-32006: SEC_CASE_SENSITIVE_LOGON initialization parameter has been deprecated







Topic : Startup & Shutdown Modes
================================
Starting and stopping an Oracle database is a core DBA task. Understanding the phases 
helps in maintenance, recovery, and troubleshooting.
  
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
  
