RMAN BACKUP AS COPY
===================
By default the BACKUP command in RMAN creates BackupSet(s) -- each of which is one or 
more BackupPiece(s).  A datafile may span BackupPieces but may not span a BackupSet.

However, RMAN does allow another method -- BACKUP AS COPY.  This is akin to "User Managed Backups" 
created with OS commands -- except that the ALTER TABLESPACE | DATABASE BEGIN BACKUP command does 
not have to be issued.

BACKUP AS COPY creates a byte-for-byte copy of each datafile [except, inasmuch, blocks being modified 
by concurrent writes to the datafile].

If an active datafile is corrupted, the DBA can choose to SWITCH TO COPY instead of having to restore 
the datafile copy.  Thus, a switch can be a fast operation.  Obviously, the DBA must plan carefully 
where he creates such copies if he intends to SWITCH anytime later  (he wouldn't keep a datafile 
copy on a non-protected [RAID or ASM] storage target).

SQL> select file_id, file_name 
  2  from dba_data_files
  3  where tablespace_name = 'ADD_TBS';

SQL> alter tablespace add_tbs
  2  add datafile '/oradata/orcl/add_tbs_02.dbf' size 100M;

SQL> create table hemant.add_table tablespace add_tbs as select * from dba_source;

SQL> select file_id, count(*)
  2  from dba_Extents
  3  where owner = 'HEMANT'
  4  and segment_name = 'ADD_TABLE'
  5  group by file_id
  6  order by 1
  7  /

RMAN> backup as copy datafile 14 format '/tmp/ADDTBS01.DBF';

RMAN> backup as copy datafile 15 format '/tmp/add_tbs_second.dbf' ;

RMAN> list backup of tablespace add_tbs completed after "sysdate-1";

RMAN> list backup of datafile 14;

Notice how a LIST BACKUP doesn't show the backups ! Why ? 
Because it shows only BACKUPSET Backups ! If I want to see these BACKUP AS COPY backups, 
I must use LIST COPY :

RMAN> list copy of datafile 14;

RMAN> list copy of datafile 15;


What happens when I lose the datafiles ?

SQL> !rm /oradata/orcl/add_tbs_0[1-2].dbf

SQL> select count(*) from hemant.add_table;

  COUNT(*)
----------
    703021

SQL> alter system checkpoint;

System altered.

SQL> select count(*) from hemant.add_table;

  COUNT(*)
----------
    703021

SQL> alter system flush buffer_cache;

System altered.

SQL> select count(*) from hemant.add_table;

  COUNT(*)
----------
    703021

SQL> alter tablespace add_tbs offline;

Tablespace altered.

SQL> alter tablespace add_Tbs online;
alter tablespace add_Tbs online
*
ERROR at line 1:
ORA-01157: cannot identify/lock data file 14 - see DBWR trace file
ORA-01110: data file 14: '/oradata/orcl/add_tbs_01.dbf'

As an aside : Note how the extents and datafiles seemed to be accessible until I tried to ONLINE the datafiles.
Now, I do not have regular backups. Can I use the datafile copies ?  YES.

RMAN> restore datafile 14;

RMAN> switch datafile 15 to copy;

I actually restored datafile 14 to the target location but only switched datafile 15 to the copy. This is clearly evidenced by :

SQL> select file_id, file_name  
  2  from dba_data_files
  3  where tablespace_name = 'ADD_TBS';

   FILE_ID FILE_NAME
---------- ----------------------------------------
        14 /oradata/orcl/add_tbs_01.dbf
        15 /tmp/add_tbs_second.dbf

SQL> 
I can now simply recover the tablespace.

RMAN> recover tablespace add_tbs;

Starting recover at 03-JUN-12
using channel ORA_DISK_1

starting media recovery
media recovery complete, elapsed time: 00:00:00

Finished recover at 03-JUN-12

RMAN> sql 'alter tablespace add_tbs online';

sql statement: alter tablespace add_tbs online

RMAN> 
and query it now.

SQL> select /*+ FULL */ count(*) from hemant.add_table;

  COUNT(*)
----------
    703021

SQL> alter tablespace add_tbs offline;

Tablespace altered.

SQL> alter tablespace add_tbs online;

Tablespace altered.

SQL> select /*+ FULL */ count(*) from hemant.add_table;

  COUNT(*)
----------
    703021


I can also restore datafile 15 by using the same "AS COPY" and "SWITCH" trick.

RMAN> backup as copy datafile 15 format '/oradata/orcl/add_tbs_02.dbf' ;

RMAN> sql 'alter tablespace add_tbs offline';

RMAN> switch datafile 15 to copy;

RMAN> recover tablespace add_tbs;
                                                                     
RMAN> sql 'alter tablespace add_tbs online';

SQL> select file_id, file_name
  2  from dba_data_files
  3  where tablespace_name = 'ADD_TBS';

   FILE_ID FILE_NAME
---------- ----------------------------------------
        14 /oradata/orcl/add_tbs_01.dbf
        15 /oradata/orcl/add_tbs_02.dbf

                                                                     
                                                                     
                                                                     
