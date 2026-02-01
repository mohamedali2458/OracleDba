ArchiveSpaceUtilization

select name, db_unique_name, open_mode, log_mode, database_role from v$database;

set linesize 300
col destination for a50
select destination from v$archive_dest where dest_name = 'LOG_ARCHIVE_DEST_1';

archive log list;

set linesize 300
col value for a50
select value from v$parameter where name = 'db_recovery_file_dest';

if archive location is asm:

set linesize 300
col name for a30
select group_number, name, state, type, round(total_mb/1024) total_gb,
round(free_mb/1024) free_gb, 100-round((100/total_mb)*free_mb,2) per_used
from v$asm_diskgroup
order by group_number;
