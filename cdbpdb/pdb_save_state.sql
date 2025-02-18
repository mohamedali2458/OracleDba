save state
==========
sqlplus / as sysdba

show pdbs;
show con_name;
shut immediate;

ps -ef|grep pmon

sqlplus / as sysdba
startup;
show pdbs;

--all pdbs are in MOUNTED state only
--to open one pdb
alter pluggable database pdb1 open;
show pdbs;
alter pluggable database all open;
show pdbs;

--to save this pdb state
alter pluggable database pdb1 close;

--to check current status
set linesize 300
col name for a20
col con_name for a20
col instance_name for a20
select a.name,b.con_name,b.instance_name,b.state from v$pdbs a, dba_pdb_saved_states b
where a.con_id = b.con_id;

show pdbs;
set linesize 300
col con_name for a30
col instance_name for a30
select con_id,con_name, instance_name, state from cdb_pdb_saved_states order by con_id;

alter pluggable database pdb1 save state;

select con_name, instance_name, state from cdb_pdb_saved_states;
select a.name,b.state from v$pdbs a, dba_pdb_saved_states b
where a.con_id = b.con_id;

alter pluggable database pdb2 save state;

alter pluggable database pdb3 save state;

--pdb3 is in MOUNTED state will not appear here
--default state is closed
--no need to save it

shut immediate;
startup;
show pdbs;

--to discard the current saved state
alter pluggable database pdb1 discard state;
select con_name, instance_name, state from cdb_pdb_saved_states;
