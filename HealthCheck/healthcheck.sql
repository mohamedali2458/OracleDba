Daily Health Check Checklist

Check if the database is up and running.
SELECT status FROM v$instance;

Review the alert log for any warnings or errors
tail -n 100 /path_to_oracle/diag/rdbms/your_db/your_db/alert.log

Check tablespace usage to ensure there’s enough space
SELECT tablespace_name, 
       ROUND(SUM(bytes) / 1024 / 1024, 2) AS total_mb,
       ROUND(SUM(bytes - free.bytes) / 1024 / 1024, 2) AS used_mb,
       ROUND(SUM(free.bytes) / 1024 / 1024, 2) AS free_mb
FROM dba_data_files
LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_free_space GROUP BY tablespace_name) free
ON dba_data_files.tablespace_name = free.tablespace_name
GROUP BY tablespace_name;

Monitor the number of active sessions to detect any unusual spikes
SELECT COUNT(*) FROM v$session WHERE status = 'ACTIVE';

Check for long-running queries and sessions.
SELECT sql_id, elapsed_time, cpu_time, buffer_gets, executions 
FROM v$sql
WHERE elapsed_time > 1000000
ORDER BY elapsed_time DESC;

Verify the status of recent backups
SELECT * FROM v$backup_set WHERE completion_time > SYSDATE - 1;

Check the status of any replication or data guard setups.

Ensure that the Oracle Listener is running
lsnrctl status

Monitor CPU and memory usage on the server.
Check for any alerts in system logs.

Review any failed login attempts or unauthorized access
SELECT * FROM dba_audit_trail WHERE action_name = 'LOGON' AND return_code != '0';


