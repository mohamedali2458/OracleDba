RMAN Incremental Backup & Recovery
==================================
Take RMAN Incremental Backup

Connect to the target DB and catalog. Take level 0 backup
RMAN> backup incremental level 0 database plus archivelog;

Once backup is completed, check backup tag via below command
RMAN> list backup of database summary;

Create New User & Table
-----------------------
SQL> create user ogr identified by ogr;
SQL> grant connect, resource, create session to ogr;
SQL> conn ogr/ogr
SQL> create table test(serial number(2),name varchar2(5));
SQL> insert into test values(1,'one');
SQL> insert into test values(2,'Two');
SQL> insert into test values(3,'Three');
SQL> insert into test values(4,'Four');
SQL> commit;

Trigger DB L1 Backup
--------------------
RMAN> backup incremental level 1 database plus archivelog;

Once backup is completed, check backup tag via below command
RMAN> list backup of database summary;

Simulate Failure
----------------
Delete all the datafiles from server

SQL> select name from v$datafile;
rm -rf <DF locations>

Start Database Recovery
-----------------------
Kill the DB instance, if running. You can do shut abort or kill pmon at OS level

Start the DB instance and take it to Mount stage. Connect to RMAN and issue below command

run
{
RESTORE DATABASE from tag TAG20170115T113749;
RECOVER DATABASE from tag TAG20170115T114127;
RECOVER DATABASE;
sql 'ALTER DATABASE OPEN';
}
