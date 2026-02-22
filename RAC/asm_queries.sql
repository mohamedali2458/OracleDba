Oracle ASM Queries
==================

ASM Metadata allows you to manage ASM disks and Diskgroups 
smoothly. The fastest way to administer ASM is via sqlplus / as sysasm. 
Here are some of my favorite ASM queries that will help you 
quickly understand its configuration:
    Query to Find ASM Diskgroup Usage
    Query to Find ASM Disks Usage
    Query to Find Databases Connected to ASM
    Add Disk to ASM Diskgroup
    ASM Disks Header and Mount Status

  
Query to Find ASM Diskgroup Usage

To check ASM diskgroup size along with free space and used percentage:

SELECT NAME, STATE, TYPE, 
     ROUND(TOTAL_MB / 1024, 2) "SIZE_GB",
     ROUND(FREE_MB / 1024, 2) "AVAILABLE_GB",
     ROUND((total_mb - free_mb) / total_mb * 100, 2) AS "USED%"
FROM v$asm_diskgroup
ORDER BY name;


Query to Find ASM Disks Usage

To check ASM disks size along with free space and used percentage:

SELECT dg.name AS "Disk Group", d.name AS "Disk Name",
  ROUND(d.total_mb / 1024, 2) AS "SIZE_GB",
  ROUND(d.free_mb / 1024, 2) AS "AVAILABLE_GB",
  ROUND((d.total_mb - d.free_mb) / d.total_mb * 100, 2) AS "USED%"
FROM v$asm_disk d
JOIN v$asm_diskgroup dg ON (d.group_number = dg.group_number)
ORDER BY dg.name, d.name;


Query to Find Databases Using ASM

To check which database instances are connected to ASM instance:

SELECT instance_name, db_name, status, software_version 
FROM v$asm_client;


Add Disk to ASM Diskgroup

As root user, create the new ASM disk on the specific partition:

  oracleasm createdisk DATA02 /dev/sdc1
  
Check the newly added disk and attach it to the diskgroup:

select name, path, mount_status, header_status from v$asm_disk;

alter diskgroup DATA add disk '/dev/oracleasm/disks/DATA02' 
NAME DATA02 rebalance power 100;

Check rebalance status - If no output, then rebalance is completed:

select * from v$asm_operation;

Check the newly added disk in ASM Diskgroup:

ASM Disks Header and Mount Status

There are two important columns under V$ASM_DISK 
which are MOUNT_STATUS and HEADER_STATUS. 

These two columns are required when you add / remove ASM disks.

ASM Disk MOUNT_STATUS

MISSING – Disk is known to be part of the ASM disk group, but no disk in the storage
CLOSED – Disk is present in the storage system but is not being accessed by ASM
OPENED – Disk is present in the storage system and is being accessed by ASM
CACHED – Disk is present in the storage system, and is part of a disk group being 
         accessed by the ASM instance. This is the normal state for disks in an ASM.

  
ASM Disk HEADER_STATUS

UNKNOWN – ASM disk header has not been read
CANDIDATE – Can be used
INCOMPATIBLE – Version number in the disk header is not compatible with the ASM version
PROVISIONED – Disk is not part of a disk group and may be added to a disk group
MEMBER – Already member of a diskgroup
FORMER – Once used, can be re-used
CONFLICT – ASM disk was not mounted due to a conflict
