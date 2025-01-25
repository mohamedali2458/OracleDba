CREATE PLUGGABLE DATABASE MANUALLY
==================================

Connect with CDB$ROOT

SQL> alter session set container=CDB$ROOT;

SQL> show pdbs

Now create pluggable database

set linesize 300 pagesize 100
col name for a100
select con_id, file#, creation_time, name from v$datafile 
order by con_id, file#;
  
SQL> 
create pluggable database pdb2
admin user ali identified by pass1234
file_name_convert=('/u01/app/oracle/oradata/ORADB/pdbseed','/u01/app/oracle/oradata/ORADB/pdb2');

this will give error.

solution:
convert all the explicitly
and put file name after directory

SQL> 
create pluggable database PDB2 
admin user ali identified by pass1234
file_name_convert=('/u01/app/oracle/oradata/ORADB/pdbseed/','/u01/app/oracle/oradata/ORADB/pdb2/');


Check the list of pdbs

SQL> 
set linesize 300
col name for a30
select con_id, name, open_mode from v$pdbs;

open pdb2
SQL> alter pluggable database PDB2 open;

SQL> select con_id, name, open_mode from v$pdbs;

Now connect with new pdb
SQL> alter session set container=PDB2;

SQL> show con_name

SQL> 
set linesize 250 pagesize 100
col tablespace_name for a20
col file_name for a60
select tablespace_name, file_id, file_name, round(bytes/1024/1024/1024,2) "Gb", status, round(maxbytes/1024/1024/1024,2) "Maxbytes", increment_by 
from dba_data_files
order by file_id;

show pdbs;

alter pluggable database pdb2 open;

show pdbs;

alter session set container=pdb2;

show con_name;

select file_name from dba_data_files;

show pdbs;

alter pluggable database pdb2 close;

drop pluggable database pdb2 keep datafiles;

drop pluggable database pdb2 including datafiles;
