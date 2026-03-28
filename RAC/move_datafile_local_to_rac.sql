How to move a datafile that was added by mistake on local storage to shared location

In Real Application Cluster (RAC) environments, data files need to be on shared storage. It is possible that a data file gets added to a tablespace on the local filesystem instead of the shared storage subsystem by mistake. 

When another instance tries to contact the local file it will error out with:

ORA-01157: cannot identify/lock data file 17 - see DBWR trace file
ORA-01110: data file 17: '/home/oracle/test01.dbf'

Starting in 12c the process can be simplified using the new "online move" feature.

You need to have all the archive files since the creation of the datafile (when it was added to the tablespace)

1.  Find out the exact file name, file location, size and file number: 

SQL> select file_id, file_name, bytes, online_status from dba_data_files 
        where tablespace_name = '<tablespace_name>';

FILE_ID FILE_NAME                          BYTES     ONLINE_
---------- ---------------------------------------- ---------- -------
16 +DATA/RAC/DATAFILE/test.309.1199529051  104857600 ONLINE
17 /home/oracle/test01.dbf                 104857600 ONLINE <<----

2. Put the datafile offline
SQL> alter database datafile 17 offline;
Database altered.

3. Recreate the datafile on the shared storage, please note that you need to do this on the node where the physical file resides and you need to specify the size retrieved in step 1

SQL> alter database create datafile '/home/oracle/test01.dbf' as '+DATA' size 100M;
Database altered.

4. Check the datafile status on second node.It will show RECOVER

SQL> select file_id, file_name, bytes, online_status from dba_data_files 
        where tablespace_name ='TEST';

   FILE_ID FILE_NAME                                     BYTES ONLINE_
---------- ---------------------------------------- ---------- ------
        16 +DATA/RAC/DATAFILE/test.309.1199529051    104857600 ONLINE
        17 +DATA/RAC/DATAFILE/test.276.1199530103              RECOVER

5. Now Recover the datafile
SQL> recover datafile 17;
Media recovery complete.

6. Place the datafile back online
SQL>alter database datafile 17 online;
Database altered.

7. Verify the datafile status
 select file_id, file_name, bytes, online_status from dba_data_files where tablespace_name ='TEST';

   FILE_ID FILE_NAME                                     BYTES ONLINE_
---------- ---------------------------------------- ---------- ------
        16 +DATA/RAC/DATAFILE/test.309.1199529051    104857600 ONLINE
        17 +DATA/RAC/DATAFILE/test.276.1199530103    104857600 ONLINE

