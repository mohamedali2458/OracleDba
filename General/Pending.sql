select ‘alter system kill session(‘||sid||’,’||serial#||’);’ from v$session where status=‘INACTIVE’;
Select ‘alter system kill session(‘||sid||’,’||serial#||’);’ from v$session where status=‘INACTIVE’ and username=‘&username’;
Select ‘alter system kill session‘||’’’’||sid||’,’||serial#||’,@’||inst_id||’’’’||’;’ from gv$session where status=‘INACTIVE’ and username=‘&username’;

Hi team, if audit is enabled on a db, then how to find which user has done the dml change on a table
Dba_audit_trail

Any help on ORA-01552: cannot use system rollback segment for non-system tablespace
Check UNDO tablespace utilisation

