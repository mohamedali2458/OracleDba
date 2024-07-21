Block Change Tracking (file)
----------------------------
RMAN's change tracking feature for incremental backups improves incremental backup 
performance by recording changed blocks in each datafile in a change tracking file. 
If change tracking is enabled, RMAN uses the change tracking file to identify 
changed blocks for incremental backup, thus avoiding the need to scan every block 
in the datafile.

Change tracking is disabled by default, because it introduces some minimal performance 
overhead on database during normal operations. However, the benefits of avoiding full 
datafile scans during backup are considerable, especially if only a small percentage 
of data blocks are changed between backups. If backup strategy involves incremental 
backups, then we should enable change tracking.

One change tracking file is created for the whole database. By default, the change 
tracking file is created as an Oracle managed file in DB_CREATE_FILE_DEST. We can 
also specify the name of the block change tracking file, placing it in any desired location.

Using change tracking in no way changes the commands used to perform incremental 
backups, and the change tracking files themselves generally require little maintenance 
after initial configuration.

From Oracle 10g, the background process Block Change Tracking Writer (CTWR) will do 
the job of writing modified block details to block change tracking file.

In a Real Applications Clusters (RAC) environment, the change tracking file must be 
located on shared storage accessible from all nodes in the cluster.

Oracle saves enough change-tracking information to enable incremental backups to be 
taken using any of the 8 most recent incremental backups as its parent.

Although RMAN does not support backup and recovery of the change-tracking file 
itself, if the whole database or a subset needs to be restored and recovered, 
then recovery has no user-visible effect on change tracking. After the restore 
and recovery, the change tracking file is cleared, and starts recording block 
changes again. The next incremental backup after any recovery is able to use 
change-tracking data.

After enabling change tracking, the first level 0 incremental backup still has 
to scan the entire datafile, as the change tracking file does not yet reflect 
the status of the blocks. Subsequent incremental backup that use this level 0 
as parent will take advantage of the change tracking file.



Enabling and Disabling Change Tracking
--------------------------------------
We can enable or disable change tracking when the database is either open or mounted. 
To alter the change tracking setting, we must use SQL*Plus to connect to the target 
database with administrator privileges.

To store the change tracking file in the database area, set DB_CREATE_FILE_DEST 
in the target database. Then issue the following SQL statement to enable change tracking:

SQL> ALTER DATABASE ENABLE BLOCK CHANGE TRACKING;  

We can also create the change tracking file in a desired location, using the following SQL statement:

SQL> ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '/u02/rman/rman_change_track.f';

The REUSE option tells Oracle to overwrite any existing file with the specified name.

SQL> ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '/u02/rman/rman_change_track.f' REUSE;

To disable change tracking, use this SQL statement:

SQL> ALTER DATABASE DISABLE BLOCK CHANGE TRACKING;  

If the change tracking file was stored in the database area, then it will be deleted when we 
disable change tracking.


Checking Whether Change Tracking is enabled
-------------------------------------------
From SQL*Plus, we can query V$BLOCK_CHANGE_TRACKING to determine whether change tracking is enabled or not. 

SQL> select status from V$BLOCK_CHANGE_TRACKING;

        ENABLED   => block change tracking is enabled.
        DISABLED  => block change tracking is disabled.

Query V$BLOCK_CHANGE_TRACKING to display the filename.

SQL> select filename from V$BLOCK_CHANGE_TRACKING;


Moving the Change Tracking File
-------------------------------
If you need to move the change tracking file, the ALTER DATABASE RENAME FILE command 
updates the control file to refer to the new location.

1. If necessary, determine the current name of the change tracking file:

SQL> SELECT filename FROM V$BLOCK_CHANGE_TRACKING;
/u02/rman/rman_change_track.f

2. Shutdown the database.

SQL> SHUTDOWN IMMEDIATE

3. Using host operating system commands, move the change tracking file to its new location.

$ mv /u02/rman/rman_change_track.f /u02/rman_new/rman_change_track.f

4. Mount the database and move the change tracking file to a location that has more space. For example:

SQL> ALTER DATABASE RENAME FILE '/u02/rman/rman_change_track.f' TO '/u02/rman_new/rman_change_track.f';

5. Open the database.

SQL> ALTER DATABASE OPEN;

SQL> SELECT filename FROM V$BLOCK_CHANGE_TRACKING;
/u02/rman_new/rman_change_track.f

If you cannot shutdown the database, then you must disable change tracking and re-enable it, at the new location:

SQL> ALTER DATABASE DISABLE BLOCK CHANGE TRACKING;

SQL> ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '/u02/rman_new/rman_change_track.f';

If you choose this method, you will lose the contents of the change tracking file. Until the next time 
you complete a level 0 incremental backup, RMAN will have to scan the entire file.


Estimating Size of the Change Tracking File on Disk
---------------------------------------------------
The size of the change tracking file is proportional to the size of the database and the number of 
enabled threads of redo. The size is not related to the frequency of updates to the database.

Typically, the space required for block change tracking is approximately 1/30,000 the size 
of the data blocks to be tracked. The following two factors that may cause the file to be 
larger than this estimate suggests:

1. To avoid overhead of allocating space as database grows, the change tracking file size 
starts at 10MB, and new space is allocated in 10MB increments. Thus, for any database 
up to approximately 300GB the file size is no smaller than 10MB, for up to approximately 
600GB the file size is no smaller than 20MB, and so on.

2. For each datafile, a minimum of 320K of space is allocated in the change tracking file, 
regardless of the size of the file. Thus, if you have a large number of relatively small 
datafiles, the change tracking file is larger than for databases with a smaller number 
of larger datafiles containing the same data.

SELECT FILE#, INCREMENTAL_LEVEL, COMPLETION_TIME, BLOCKS, DATAFILE_BLOCKS 
FROM V$BACKUP_DATAFILE 
WHERE INCREMENTAL_LEVEL > 0 AND BLOCKS / DATAFILE_BLOCKS > .5 ORDER BY COMPLETION_TIME;
