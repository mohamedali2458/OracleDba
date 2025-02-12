How to Start and Stop MRP in Oracle Data Guard

Managed Recovery Process (MRP)

To Start MRP:

SQL Command:
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

This command starts the managed recovery process in the background.

Data Guard Command:
DGMGRL> EDIT DATABASE <standby_unique_name> SET STATE='APPLY-ON';


To Stop MRP:

SQL Command:
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
This command stops the managed recovery process.

Data Guard Command:
DGMGRL> EDIT DATABASE <standby_unique_name> SET STATE='APPLY-OFF';


Log Network Server (LNS) and Remote File Server (RFS)
  
These processes are typically managed automatically by Oracle Data Guard and do not 
require manual intervention to start or stop. However, they can be influenced by the 
configuration of redo transport services.

To Enable Redo Transport Services:

SQL Command:
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE;

To Disable Redo Transport Services:

SQL Command:
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=DEFER;

Monitoring the Processes

SELECT inst_id, process, status, thread#, sequence#, block#, blocks 
FROM gv$managed_standby 
WHERE process IN ('RFS', 'LNS', 'MRP0');
