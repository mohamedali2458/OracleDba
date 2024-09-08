Get ASM disk info

set pagesize 2000
set lines 2000
set long 999
col path for a54
select name, path, header_status, total_mb free_mb, trunc(bytes_read/1024/1024) read_mb, trunc(bytes_written/1024/1024)
write_mb from v$asm_disk;

Get ASM disk group details

SELECT name, free_mb, total_mb, free_mb/total_mb*100 as percentage
FROM v$asm_diskgroup;

Drop an ASM disk

-----Dropping one disk:
alter diskgroup data drop disk DATA_ASM0001;
-----Dropping multiple disk:
alter diskgroup data drop disk DATA_ASM0001,DATA_ASM00002, DATA_ASM0003 rebalance power 100;
---- Monitoring the rebalance operation:
select * from v$asm_operation;

Monitor ASM disk rebalance

set pagesize 299
set lines 2999
select GROUP_NUMBER,OPERATION,STATE,POWER,ACTUAL,ACTUAL,EST_MINUTES from gv$asm_operation;

Execute runcluvfy.sh for RAC precheck

-- Runcluvfy.sh script is available after unzipping the grid software.
Syntax –
./runcluvfy.sh stage -pre crsinst -n host1,host2,host3 -verbose
./runcluvfy.sh stage -pre crsinst -n classpredb1,classpredb2 -verbose

Copy ASM file to remote ASM instance

--- ASM file can be copied to remote asm instance(diskgroup) using asmcmd command.
SYNTAX -
asmcmd> cp - -port asm_port file_name remote_asm_user/remote_asm_pwd@remote_host:Instancce_name:TARGET
_ASM_PATH
ASMCMD> cp --port 1521 s_srv_new21.dbf sys/oracle@172.20.17.69.+ASM1:+ARCL/s_srv_new21.dbf

Mount/dismount ASM disk groups

-- For mount a diskgroup,(This is instance specific, for mounting on all nodes, run the same on all nodes)
SQL>alter diskgroup DATA mount;
or
asmcmd>mount DATA
-- For umount a diskgroup,(This is instance specific, for unmounting on all nodes, run the same on all nodes)
SQL>alter diskgroup DATA dismount;
Or
asmcmd>umount DATA
-- To mount/Dismount all the diskgroups
SQL>alter diskgroup ALL mount;
SQL>alter diskgroup ALL dismount;
