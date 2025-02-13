How to Clean Up Oracle’s SYSAUX Tablespace

Cleaning up the SYSAUX tablespace in Oracle involves identifying and managing the objects occupying 
space within it. Here are the general steps and commands to help you clean up the SYSAUX tablespace:

1. Identify the occupants:
First, you need to identify what is consuming space in the SYSAUX tablespace. The V$SYSAUX_OCCUPANTS view provides this information.

SELECT OCCUPANT_NAME, SCHEMA_NAME, MOVE_PROCEDURE, SPACE_USAGE_KBYTES FROM V$SYSAUX_OCCUPANTS ORDER BY SPACE_USAGE_KBYTES DESC;

2. Analyze space usage:
After identifying the occupants, check if any of them can be purged, moved, or otherwise managed.
Purge AWR (Automatic Workload Repository) data:
AWR data can often consume a significant amount of space in the SYSAUX tablespace. You can reduce the retention period of AWR data or manually purge old snapshots.
Reduce AWR retention period:
BEGIN DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(
retention => 43200, -- Retention in minutes (e.g., 30 days)
interval => 60 -- Snapshot interval in minutes );
END; /
Manually purge AWR snapshots:
BEGIN DBMS_WORKLOAD_REPOSITORY.DROP_SNAPSHOT_RANGE(
low_snap_id => 100, -- Lower bound snapshot ID
high_snap_id => 200 -- Upper bound snapshot ID );
END; /
Move occupants:
Some occupants in the SYSAUX tablespace can be moved to other tablespaces. The MOVE_PROCEDURE column in V$SYSAUX_OCCUPANTS can help identify the procedure to move certain occupants.
For example, to move the STATISTICS_LEVEL data: EXEC DBMS_STATS.ALTER_STATS_TABLESPACE('NEW_TABLESPACE');
Purge Optimizer Statistics History:
Optimizer statistics history can also consume significant space.
EXEC DBMS_STATS.PURGE_STATS(SYSDATE - 30); -- Keep statistics for the last 30 days

Shrink tablespace:
After purging or moving data, you might want to reclaim space in the SYSAUX tablespace.
ALTER TABLESPACE SYSAUX SHRINK SPACE KEEP 500M;

Important Notes
Backup: Before making any changes, ensure that you have a full backup of your database.
Consult Documentation: Refer to the Oracle documentation for your specific version for any additional options or features.
Test: Perform these operations in a test environment before applying them to your production database.
Permissions: Ensure you have the necessary privileges to execute these commands. Typically, these operations require DBA privileges.
