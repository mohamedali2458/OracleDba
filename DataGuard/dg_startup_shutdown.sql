Oracle Data Guard Startup & Shutdown Steps
==========================================
We will look at Oracle Data Guard startup and shutdown sequence. 
You must follow proper shutdown order to perform a graceful shutdown.

Make sure you have permission from application owner / database architect 
to perform primary shutdown.


Data Guard Shutdown Sequence
----------------------------
Stop log apply service or MRP and shutdown the standby

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SQL> SHUT IMMEDIATE;

Stop log shipping from primary and shutdown primary database

SQL> ALTER SYSTEM SET log_archive_dest_state_2='DEFER';
SQL> SHUT IMMEDIATE;


Data Guard Startup Sequence
---------------------------
Startup primary database and enable log shipping

SQL> STARTUP;
SQL> ALTER SYSTEM SET log_archive_dest_state_2='ENABLE';

Startup standby and enable log apply service or MRP

SQL> startup nomount;
SQL> alter database mount standby database;

SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
