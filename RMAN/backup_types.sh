Types of Backups in Oracle DBA.

Backups protect the database from data loss, corruption, and failures.
Every DBA must know which backup to use and when.
Types of backups 👇 

1)Physical Backups (RMAN)
 Used for fast and reliable recovery.
 a) Full Backup → Entire database
 b) Incremental Level 0 → Base backup
 c) Incremental Level 1 → Changes since last backup
 Differential
 Cumulative

2)Logical Backups (Data Pump)
👉 Used for migration & logical recovery (not point-in-time).
a)Export (expdp) → Schema / table level
b) Import (impdp) → Restore selected data

 3)Hot & Cold Backup
 a) Hot Backup → DB open (ARCHIVELOG mode)
 b) Cold Backup → DB closed (no redo needed)

📌 DBA Rule:
 No backup = No recovery.