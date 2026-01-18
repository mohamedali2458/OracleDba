13 Must Have Shell Scripts

To Automate Routine Tasks

Scripts
1. GoldenGate Monitor (gg_alert.sh)
Monitors the status of GoldenGate extract and replicate processes.
Sends email alerts if a process is down.

2. Standby Database Lag Monitor (dgmgrl_standby_lag.sh)
Uses dgmgrl to check the apply lag in a standby database.
Sends email alerts if the lag exceeds a threshold.

3. RMAN Archive Deletion Script (rman_arch_del.sh)
Uses RMAN to automatically delete archive logs based on a retention policy.

4. Blocking Session Monitor (blocker.sh)
Queries v$session to identify blocking sessions.
Sends email alerts with details of blocking sessions.

5. ASM Disk Group Usage Monitor (asm_dg.sh)
Monitors ASM disk group utilization.
Sends email alerts if usage exceeds a threshold.

6. Invalid Login Attempt Monitor (invalid_log.sh)
Audits failed login attempts in the database.
Sends email alerts for suspicious login activity.

7. Filesystem Alert Script
Monitors filesystem usage (for Solaris).
Sends email alerts if usage exceeds a threshold.

8. Oracle Alert Log Rotation Script (rotatealertlog.sh)
Rotates the Oracle alert log file and compresses the old log.

9. Tablespace Usage Monitor (tablespace_threshold.ksh)
Monitors tablespace usage and sends email alerts if it exceeds a threshold.

10. Alert Log Monitor (Adrci_alert_log.ksh)
Uses adrci to monitor Oracle alert logs for ORA errors.
Sends email alerts if ORA errors are found.

11. IP Address Tracking Script
Tracks IP addresses associated with a load-balanced HTTP link.
Sends email alerts if the IP addresses change.

12. RMAN Backup Script (rman_backup.sh)
Performs Oracle database backups (full, incremental, archive, cold) using RMAN.
Supports compressing backups and running parallel backup jobs.

13. Import And Export In Parallel With Datapump
