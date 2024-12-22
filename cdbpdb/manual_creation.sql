CREATE PLUGGABLE DATABASE MANUALLY
==================================

Connect with CDB$ROOT

SQL> alter session set container=CDB$ROOT;

SQL> show pdbs

Now create pluggable database

SQL> create pluggable database pdb2
admin user ali identified by pass1234
file_name_convert=('/u01/app/oracle/oradata/ORADB/','/u01/app/oracle/oradata/ORADB//PDB2');

this will give error.

solution:
convert all the explicitly
and put file name after directory

SQL> create pluggable database PDB2 admin user ali identified by pass1234
file_name_convert=('/u01/app/oracle/oradata/ORADB/pdb1/',
  '/u01/app/oracle/oradata/ORADB/pdb2/');


Check the list of pdbs

SQL> select con_id, name, open_mode from v$pdbs;

open pdb6
SQL> alter pluggable database PDB6 open;

SQL> select con_id, name, open_mode from v$pdbs;

Now connect with new pdb
SQL> alter session set container=PDB6;

SQL> show con_name

SQL> select file_name from dba_data_files;



create pdb from another pdb
create pluggable database pdb2 from pdb1 storage unlimited tempfile reuse file_name_convert=('PDB1','PDB2');

show pdbs;

alter pluggable database orclpdb2 open;

show pdbs;

alter session set container=orclpdb2;

show con_name;

select file_name from dba_data_files;

show pdbs;

alter pluggable database pdb2 close;

drop pluggable database pdb2 keep datafiles;

drop pluggable database pdb2 including datafiles;

