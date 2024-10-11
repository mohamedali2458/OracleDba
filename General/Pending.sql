select ‘alter system kill session(‘||sid||’,’||serial#||’);’ from v$session where status=‘INACTIVE’;
Select ‘alter system kill session(‘||sid||’,’||serial#||’);’ from v$session where status=‘INACTIVE’ and username=‘&username’;
Select ‘alter system kill session‘||’’’’||sid||’,’||serial#||’,@’||inst_id||’’’’||’;’ from gv$session where status=‘INACTIVE’ and username=‘&username’;
