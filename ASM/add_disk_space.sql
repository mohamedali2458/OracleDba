✔ How to add a 100 GB disk to an existing ASM diskgroup
✔ How to monitor rebalance progress and extents

STEP 1: Check available diskgroups and status (login as sysdba)
SELECT name, state, type FROM v$asm_diskgroup;

STEP 2: Check diskgroups size and redundancy (login as sysdba/sysasm)
SELECT name, type,
ROUND(total_mb/1024,2) total_gb,
ROUND(free_mb/1024,2) free_gb,
ROUND(usable_file_mb/1024,2) usable_gb
FROM v$asm_diskgroup;

STEP 3: Find candidate/provisioned/Former disk (grid user) login as sysasm
set line 120
col path for a50
SELECT path, header_status, state, name FROM v$asm_disk;

STEP 4: Add the disk with header status “FORMER” to a diskgroup +DATA login as sysasm
ALTER DISKGROUP DATA
ADD DISK '/dev/oracleasm/disks/ASMDISK4_100G'
REBALANCE POWER 15;

Check progress :
SELECT operation, state, power, est_minutes FROM v$asm_operation;

STEP 5: Verify the diskgroup size (size of DATA diskgroup has increased from 25 gb to 125 gb)
 SELECT name,
 type,
 ROUND(total_mb/1024,2) total_gb,
 ROUND(free_mb/1024,2) free_gb,
 ROUND(usable_file_mb/1024,2) usable_gb
FROM v$asm_diskgroup;

