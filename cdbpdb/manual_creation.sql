CREATE PLUGGABLE DATABASE MANUALLY

Connect with CDB$ROOT

SQL> alter session set container=CDB$ROOT;

SQL> show pdbs

Now create pluggable database

SQL> create pluggable database pdb6
admin user ali identified by pass1234
file_name_convert=('/home/oracle/oradata/PROD/datafile','/home/oracle/app/oracle/oradata/PROD/datafile/PDB6');

this will give error.

solution:
convert all the explicitly
and put file name after directory

SQL> create pluggable database PDB6 admin user ali identified by pass1234
file_name_convert=('/home/oracle/app/oracle/oradata/PROD/datafile/',
  '/home/oracle/app/oracle/oradata/PROD/PDB6/PDB6');

Check the list of pdbs

SQL> select con_id, name, open_mode from v$pdbs;

open pdb6
SQL> alter pluggable database PDB6 open;

SQL> select con_id, name, open_mode from v$pdbs;

Now connect with new pdb
SQL> alter session set container=PDB6;

SQL> show con_name

SQL> select file_name from dba_data_files;
