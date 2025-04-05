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
