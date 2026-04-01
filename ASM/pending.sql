Day 40 | Oracle DBA Learning Series
Topic : ASM Administration — Day-to-Day Tasks Every Oracle DBA Must Know!

ASM (Automatic Storage Management) is Oracle’s built-in storage management system.
It helps DBAs manage database files efficiently without dealing with OS-level complexity.

Types of Redundancy
External – No mirroring (handled by storage)
Normal – 2-way mirroring
High – 3-way mirroring

Commonly used ASM Commands
 1) Create & Manage Disk Groups:

-- Create with mirroring
CREATE DISKGROUP DATA NORMAL REDUNDANCY
 FAILGROUP fg1 DISK '/dev/sdb'
 FAILGROUP fg2 DISK '/dev/sdc';

-- Mount / Dismount
ALTER DISKGROUP DATA MOUNT;
ALTER DISKGROUP DATA DISMOUNT;

2) Add / Drop / Resize Disks:

-- Add a new disk (ASM auto-rebalances!)
ALTER DISKGROUP DATA ADD DISK '/dev/sdd' NAME disk3;

-- Drop a disk (ASM migrates data first)
ALTER DISKGROUP DATA DROP DISK disk3;

-- Cancel a drop
ALTER DISKGROUP DATA UNDROP DISKS;

3) Monitor & Rebalance

-- Check rebalance progress
SELECT sofar, est_work, est_rate FROM v$asm_operation;

-- Speed up rebalance
ALTER DISKGROUP DATA REBALANCE POWER 8;

-- Check free space (keep >15%!)
SELECT name, total_mb, free_mb FROM v$asm_diskgroup;
```

ASMCMD Daily Tasks:

lsdg          → List disk groups
lsdsk --candidate    → Available disks
md_backup -b bkp -g DATA → Backup DG metadata

Pro Tip: When you add a disk, ASM automatically rebalances in the background. You don't need to do anything — but always monitor it with v$asm_operation!

 ASM administration sits on top of Oracle's core storage architecture — and understanding how datafiles, disk groups, and instances interact makes day-to-day ASM tasks much more intuitive. My Oracle Fundamental Architecture document covers these core fundamentals with real-time production scenarios. And more study material is coming soon — ASM deep dives, RAC, Performance Tuning, Migration, and much more! 