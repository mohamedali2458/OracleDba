Configure UDEV Rules for Oracle ASM

Pre-requisites:

a. Create OS user and groups for Oracle ASM disk owner
b. Add RAW disks to server (Check with sysadmin)

Configure UDEV Rules for Oracle ASM:

1. List the disks
2. Create partitions for the disks
3. Load updated block device partition tables
4. Find SCSI ID
5. Create udev rules
6. Reload the udev rules
7. List oracleasm disks


Pre-requisites


a. Create OS user and groups for Oracle ASM disk owner

http://www.br8dba.com/create-users-groups-and-paths-for-oracle-rac/


b. Add RAW disks to server

Operating System	  Red Hat Enterprise Linux release 8.7
Storage	
/dev/sda	100G for Linux and others
/dev/sdb	100G for /u01
/dev/sdc	100G for /orabackup
/dev/sdd	100G for ASM DISK
/dev/sde	100G for ASM DISK


Configure UDEV Rules for Oracle ASM

If ASMLIB kernel drivers are not available then we have to use udev rules to create the disks for Oracle ASM.

Setting up Oracle ASM udev rules is not so complicated. All you need is the udevadm command and editing one file.

  
1. List the disks

[root@testbox ~]# lsblk


2. Create partitions for the disks

fdisk /dev/sdd
fdisk /dev/sde


3. Load updated block device partition tables

# For Linux 5,6 and 7

# /sbin/partprobe /dev/sdd1
# /sbin/partprobe /dev/sde1

# For Linux8

[root@testbox ~]# /sbin/partx -u /dev/sdd1
[root@testbox ~]#
[root@testbox ~]# /sbin/partx -u /dev/sde1
[root@testbox ~]#


4. Find SCSI ID

[root@testbox ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdd
1ATA_VBOX_HARDDISK_VB0adc00d9-c5938e95
[root@testbox ~]#

[root@testbox ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sde
1ATA_VBOX_HARDDISK_VBdaa5e829-52e4b9b1
[root@testbox ~]#

  
5. Create udev rules

[root@testbox ~]# ls -ltr /etc/udev/rules.d
total 12
-rw-r--r--. 1 root root  67 Oct  2 18:03 69-vdo-start-by-dev.rules
-rw-r--r--. 1 root root 148 Nov  9 06:11 99-vmware-scsi-timeout.rules
-rw-r--r--. 1 root root 134 Apr  1 07:52 60-vboxadd.rules
[root@testbox ~]#

vi /etc/udev/rules.d/99-oracle-asmdevices.rules
and below lines and then save it.

KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/$parent", RESULT=="1ATA_VBOX_HARDDISK_VB0adc00d9-c5938e95", SYMLINK+="oracleasm/disks/DISK01", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/$parent", RESULT=="1ATA_VBOX_HARDDISK_VBdaa5e829-52e4b9b1", SYMLINK+="oracleasm/disks/DISK02", OWNER="grid", GROUP="asmadmin", MODE="0660"


[root@testbox ~]# cat /etc/udev/rules.d/99-oracle-asmdevices.rules
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/$parent", RESULT=="1ATA_VBOX_HARDDISK_VB0adc00d9-c5938e95", SYMLINK+="oracleasm/disks/DISK01", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/$parent", RESULT=="1ATA_VBOX_HARDDISK_VBdaa5e829-52e4b9b1", SYMLINK+="oracleasm/disks/DISK02", OWNER="grid", GROUP="asmadmin", MODE="0660"
[root@testbox ~]#

[root@testbox ~]# ls -ltr /etc/udev/rules.d/99-oracle-asmdevices.rules
-rw-r--r--. 1 root root 428 Apr  2 02:18 /etc/udev/rules.d/99-oracle-asmdevices.rules
[root@testbox ~]#

6. Reload the udev rules

The below commands will reload the complete udev configuration and will trigger all the udev rules. 
On a busy production system this could disrupt ongoing operations, applications running on the server. Please use the below command during a scheduled maintenance window only.

[root@testbox ~]# /sbin/udevadm control --reload-rules
[root@testbox ~]#
[root@testbox ~]# ls -ld /dev/sd*1
brw-rw----. 1 root disk 8,  1 Apr  2 02:23 /dev/sda1
brw-rw----. 1 root disk 8, 17 Apr  2 02:23 /dev/sdb1
brw-rw----. 1 root disk 8, 33 Apr  2 02:23 /dev/sdc1
brw-rw----. 1 root disk 8, 49 Apr  2 02:23 /dev/sdd1
brw-rw----. 1 root disk 8, 65 Apr  2 02:23 /dev/sde1
[root@testbox ~]#
[root@testbox ~]# /sbin/udevadm trigger
[root@testbox ~]#
[root@testbox ~]# ls -ld /dev/sd*1
brw-rw----. 1 root disk     8,  1 Apr  2 02:34 /dev/sda1
brw-rw----. 1 root disk     8, 17 Apr  2 02:34 /dev/sdb1
brw-rw----. 1 root disk     8, 33 Apr  2 02:34 /dev/sdc1
brw-rw----. 1 grid asmadmin 8, 49 Apr  2 02:34 /dev/sdd1
brw-rw----. 1 grid asmadmin 8, 65 Apr  2 02:34 /dev/sde1
[root@testbox ~]#

7. List the oracleasm disks

[root@testbox ~]# ls -ltra /dev/oracleasm/disks/*
lrwxrwxrwx. 1 root root 10 Apr  2 02:34 /dev/oracleasm/disks/DISK01 -> ../../sdd1
lrwxrwxrwx. 1 root root 10 Apr  2 02:34 /dev/oracleasm/disks/DISK02 -> ../../sde1
[root@testbox ~]#

[root@testbox ~]# ls -ld /dev/sd*1
brw-rw----. 1 root disk     8,  1 Apr  2 02:34 /dev/sda1
brw-rw----. 1 root disk     8, 17 Apr  2 02:34 /dev/sdb1
brw-rw----. 1 root disk     8, 33 Apr  2 02:34 /dev/sdc1
brw-rw----. 1 grid asmadmin 8, 49 Apr  2 02:34 /dev/sdd1
brw-rw----. 1 grid asmadmin 8, 65 Apr  2 02:34 /dev/sde1
[root@testbox ~]#

Note: symboliclinks are owned by root, but devices will be owned by grid:asmadmin
