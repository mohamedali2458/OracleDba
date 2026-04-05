ArchiveSpaceUtilization

SELECT name, db_unique_name, open_mode, log_mode, database_role FROM v$database;

set linesize 300
col destination for a50
SELECT destination FROM v$archive_dest 
WHERE dest_name = 'LOG_ARCHIVE_DEST_1';

archive log list;

set linesize 300
col value for a50
SELECT value FROM v$parameter WHERE name = 'db_recovery_file_dest';

--if archive location is ASM:

set linesize 300
col name for a30
SELECT group_number, name, state, type, round(total_mb/1024) total_gb,
round(free_mb/1024) free_gb, 100-round((100/total_mb)*free_mb,2) per_used
FROM v$asm_diskgroup
ORDER BY group_number;
