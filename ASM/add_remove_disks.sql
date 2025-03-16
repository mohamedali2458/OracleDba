Oracle ASM DiskGroup : Add and Remove disks

ps -ef|grep -i pmon

crsctl stat res -t
in this result check for ora.oemdb.db home_path

su - grid
asmcmd
lsdg

to see existing disks
lsdsk
exit

sqlplus / as sysdba
SQL> @asm_disks
SQL> !asm_disks.sql
set lines 200 pages 1000
col name for a20
col path for a45
select GROUP_NUMBER,DISK_NUMBER,NAME,MOUNT_STATUS,HEADER_STATUS,
STATE,OS_MB,TOTAL_MB,FREE_MB,PATH
from v$asm_disk
order by GROUP_NUMBER,PATH;

To add disks to the vm we need to stop it
crsctl stop has
go to storage and attach new disk there
choose fix size
after adding disks 2 of 15 g each start vm

to check available disks
fdisk -l
on root user run
lsblk
check size=15G 2 disks, note down their name

To create partitions
fdisk /dev/sdc
fdisk /dev/sdd

lsblk

now to create asm diskgroup
ls -l /dev/oracleasm/disks/*
oracleasm createdisk ASMDATADISK02 /dev/sdd1
oracleasm createdisk ASMFRADISK02 /dev/sdc1

oracleasm scandisks

oracleasm listdisks

su - grid

validate permissions
ls -l /dev/oracleasm/disks/*
sqlplus / as sysasm
SQL> @asm_disks
HEADER_STATUS of those 2 new disks is shown as PROVISIONED
other 2 as MEMBER

alter diskgroup DG_DATA ADD DISK '/dev/oracleasm/disks/ASMDATADISK02' rebalance power 8;

select * from v$asm_operation;
here check result of OPERATION, PASS and STATUS column values

now if we check @asm_disks we see only one candidate disk remaining

asmcmd
lsdsk --candidate (we can see only one candidate)

alter diskgroup DG_FRA ADD DISK '/dev/oracleasm/disks/ASMFRADISK02' rebalance power 8;

select * from v$asm_operation;

asmcmd
lsdg
remove the old disk from DG_DATA and DG_FRA

sqlplus / as sysasm
select * from v$asm_operation;

make sure its completed

@asm_disks
note down disk names

alter diskgroup DG_DATA DROP DISK DG_DATA_0000 (NAME COLUMN) REBALANCE POWER 8;

SELECT * FROM V$ASM_OPERATION;

EST_MINUTES will give us time remaining

alter diskgroup DG_FRA DROP DISK DG_FRA_0000 REBALANCE POWER 8;

SELECT * FROM V$ASM_OPERATION;

@asm_disks

delete removed disks from OS
go root user
oracleasm deletedisk ASMDATADISK01
oracleasm deletedisk ASMFRADISK01

su - grid
sqlplus / as sysasm
@asm_disks
now we can see only 2 disks

lsblk

shut the vm
crsctl stop has
power off the vm
go to vm storage properties
right click and click on remove disks from vm
