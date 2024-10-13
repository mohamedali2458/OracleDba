Configure ASMLib for Oracle ASM

Environment

Pre-requisites

a. Create OS user and groups for Oracle ASM disk owner
b. Add RAW disks to server (Check with osadmin)

Configure ASMLib for Oracle ASM (Only on Linux)

1. List the disks
2. Create partitions for the disks
3. Load updated block device partition tables
4. Install ASMLib packages
5. Configure Oracle ASMLib
6. Create ASM disks
7. List oracleasm disks

  
Environment

OS	            Red Hat Enterprise Linux release 8.7
Kernel Version	4.18.0-477.27.1.el8_8.x86_64
ASM disk owner	grid user


Pre-requisites

a. Create OS user and groups for Oracle ASM disk owner
http://www.br8dba.com/create-users-groups-and-paths-for-oracle-rac/


b. Add RAW disks to server (Please verify with your system administrator for ASM disk names)
Operating System	    Red Hat Enterprise Linux release 8.7
Storage	
/dev/sda	For Operating system and other
/dev/sdb	100G for ASM DISK
/dev/sdc	100G for ASM DISK
/dev/sdd	100G for ASM DISK
/dev/sde	100G for ASM DISK
/dev/sdf	100G for ASM DISK


Configure ASMLib for Oracle ASM (Only on Linux)

What is ASMLib?
ASMLib, short for "Automatic Storage Management Library," is a support library provided 
by Oracle for managing Oracle ASM (Automatic Storage Management) on Linux systems. It 
simplifies the administration and management of Oracle ASM disk groups and volumes 
by providing a set of utilities and kernel modules.
 
ASMLib is typically used in Oracle Database environments to interact with ASM disks 
and is specifically designed to work with Oracle ASM.

ASMlib driver is required on Linux operating systems, to enable a disk readable by ASM. 
Without ASMLIB, disks can’t be used at asm disks.

All ASMLib installations require the kmod-redhat-oracleasm, oracleasmlib and oracleasm-support 
packages appropriate for their machine.

ASMLib is not mandatory for the Automatic Storage Management (ASM) feature of Oracle Database 
on Linux and all features and functionality of ASM will work without ASMLib. 

oracleasm-support
kmod-redhat-oracleasm  <-- download from Redhat
oracleasmlib

You can also use udev rules instead of Oracle ASMLib.
https://www.br8dba.com/configure-udev-rules-for-oracle-asm/


1. List the disks

[root@db1 ~]# lsblk


2. Create partitions for the disks

[root@db1 ~]# fdisk /dev/sdb
[root@db1 ~]# fdisk /dev/sdc
[root@db1 ~]# fdisk /dev/sdd
[root@db1 ~]# fdisk /dev/sde
[root@db1 ~]# fdisk /dev/sdf
[root@db1 ~]#

[root@db1 ~]# lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda           8:0    0  100G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0   99G  0 part
  ├─ol-root 252:0    0 61.2G  0 lvm  /
  ├─ol-swap 252:1    0  7.9G  0 lvm  [SWAP]
  └─ol-home 252:2    0 29.9G  0 lvm  /home
sdb           8:16   0  100G  0 disk
└─sdb1        8:17   0  100G  0 part
sdc           8:32   0  100G  0 disk
└─sdc1        8:33   0  100G  0 part
sdd           8:48   0  100G  0 disk
└─sdd1        8:49   0  100G  0 part
sde           8:64   0  100G  0 disk
└─sde1        8:65   0  100G  0 part
sdf           8:80   0  100G  0 disk
└─sdf1        8:81   0  100G  0 part
sr0          11:0    1 1024M  0 rom
[root@db1 ~]#


3. Load updated block device partition tables

# For Linux 5,6 and 7

# /sbin/partprobe /dev/sdb1
# /sbin/partprobe /dev/sdc1
# /sbin/partprobe /dev/sdd1
# /sbin/partprobe /dev/sde1
# /sbin/partprobe /dev/sdf1

# For Linux8

[root@db1 ~]# /sbin/partx -u /dev/sdb1
[root@db1 ~]# /sbin/partx -u /dev/sdc1
[root@db1 ~]# /sbin/partx -u /dev/sdd1
[root@db1 ~]# /sbin/partx -u /dev/sde1
[root@db1 ~]# /sbin/partx -u /dev/sdf1


4. Install ASMLib packages

*** Download and install ASMLib packages that support your kernel. 
[root@db1 ~]# uname -rms
Linux 4.18.0-477.27.1.el8_8.x86_64 x86_64

[root@db1 ~]# yum clean all ; yum repolist

[root@db1 ~]# yum install -y oracleasm

[root@db1 ~]# rpm -qa | grep -i oracleasm
kmod-redhat-oracleasm-2.0.8-17.0.2.el8.x86_64

[root@db1 ~]# yum install -y oracleasm-support

[root@db1 ~]# yum install oracleasmlib

[root@db1 ~]# wget https://download.oracle.com/otn_software/asmlib/oracleasmlib-2.0.17-1.el8.x86_64.rpm
[root@db1 ~]# wget https://public-yum.oracle.com/repo/OracleLinux/OL8/addons/x86_64/getPackage/oracleasm-support-2.1.12-1.el8.x86_64.rpm

[root@db1 ~]# ls -ltr *.rpm
-rw-r--r--. 1 root root 99852 Feb 28  2020 oracleasm-support-2.1.12-1.el8.x86_64.rpm
-rw-r--r--. 1 root root 27092 Jun  1  2020 oracleasmlib-2.0.17-1.el8.x86_64.rpm

[root@db1 ~]# yum localinstall ./oracleasm-support-2.1.12-1.el8.x86_64.rpm ./oracleasmlib-2.0.17-1.el8.x86_64.rpm

[root@db1 ~]# rpm -qa | grep -i oracleasm
oracleasmlib-2.0.17-1.el8.x86_64
kmod-redhat-oracleasm-2.0.8-17.0.2.el8.x86_64
oracleasm-support-2.1.12-1.el8.x86_64


5. Configure Oracle ASMLib

[root@db1 ~]# /usr/sbin/oracleasm configure -i
[root@db1 ~]# /usr/sbin/oracleasm configure -i
Configuring the Oracle ASM library driver.

This will configure the on-boot properties of the Oracle ASM library
driver.  The following questions will determine whether the driver is
loaded on boot and what permissions it will have.  The current values
will be shown in brackets ('[]').  Hitting  without typing an
answer will keep that current value.  Ctrl-C will abort.

Default user to own the driver interface []: grid
Default group to own the driver interface []: asmadmin
Start Oracle ASM library driver on boot (y/n) [n]: y
Scan for Oracle ASM disks on boot (y/n) [y]: y
Writing Oracle ASM library driver configuration: done
[root@db1 ~]#

[root@db1 ~]# /usr/sbin/oracleasm init
Creating /dev/oracleasm mount point: /dev/oracleasm
Loading module "oracleasm": failed
Unable to load module "oracleasm"
Mounting ASMlib driver filesystem: failed
Unable to mount ASMlib driver filesystem


*** Please consult with the OS Administrator. The ASM library does not load with the current kernel version. I simply want to modify the default kernel boot order. Before making kernel changes, please consult with Oracle and Redhat support.

[root@db1 ~]# ls -l /boot/vmlinuz-*
-rwxr-xr-x. 1 root root 13287760 Feb 24  2023 /boot/vmlinuz-0-rescue-93eed19701864c2cac4193714f746de8
-rwxr-xr-x. 1 root root 10744352 Nov  8  2022 /boot/vmlinuz-4.18.0-425.3.1.el8.x86_64
-rwxr-xr-x. 1 root root 10851840 Sep 27 14:23 /boot/vmlinuz-4.18.0-477.27.1.el8_8.x86_64
-rwxr-xr-x. 1 root root 13287760 Oct 19  2022 /boot/vmlinuz-5.15.0-3.60.5.1.el8uek.x86_64
[root@db1 ~]#
[root@db1 ~]# grubby --set-default /boot/vmlinuz-4.18.0-477.27.1.el8_8.x86_64
The default is /boot/loader/entries/93eed19701864c2cac4193714f746de8-4.18.0-477.27.1.el8_8.x86_64.conf with index 1 and kernel /boot/vmlinuz-4.18.0-477.27.1.el8_8.x86_64
[root@db1 ~]# 

[root@db1 ~]# shutdown -Fr now


[root@db1 ~]# /usr/sbin/oracleasm init

[root@db1 ~]# /usr/sbin/oracleasm status
Checking if ASM is loaded: yes
Checking if /dev/oracleasm is mounted: yes
[root@db1 ~]#


6. Create ASM disks

[root@db1 ~]# /usr/sbin/oracleasm createdisk DISK1 /dev/sdb1
[root@db1 ~]# /usr/sbin/oracleasm createdisk DISK2 /dev/sdc1
[root@db1 ~]# /usr/sbin/oracleasm createdisk DISK3 /dev/sdd1
[root@db1 ~]# /usr/sbin/oracleasm createdisk DISK4 /dev/sde1
[root@db1 ~]# /usr/sbin/oracleasm createdisk DISK5 /dev/sdf1
[root@db1 ~]#

[root@db1 ~]# /usr/sbin/oracleasm scandisks
[root@db1 ~]# /usr/sbin/oracleasm listdisks
DISK1
DISK2
DISK3
DISK4
DISK5


7. List oracleasm disks

[root@db1 ~]# ls -ld /dev/sd*1
brw-rw----. 1 root disk 8,  1 Oct 14 06:32 /dev/sda1
brw-rw----. 1 root disk 8, 17 Oct 14 07:13 /dev/sdb1
brw-rw----. 1 root disk 8, 33 Oct 14 07:13 /dev/sdc1
brw-rw----. 1 root disk 8, 49 Oct 14 07:13 /dev/sdd1
brw-rw----. 1 root disk 8, 65 Oct 14 07:13 /dev/sde1
brw-rw----. 1 root disk 8, 81 Oct 14 07:13 /dev/sdf1
[root@db1 ~]#

[root@db1 ~]# ls -ltra /dev/oracleasm/disks/*
brw-rw----. 1 grid asmadmin 8, 17 Oct 14 07:11 /dev/oracleasm/disks/DISK1
brw-rw----. 1 grid asmadmin 8, 33 Oct 14 07:12 /dev/oracleasm/disks/DISK2
brw-rw----. 1 grid asmadmin 8, 49 Oct 14 07:12 /dev/oracleasm/disks/DISK3
brw-rw----. 1 grid asmadmin 8, 65 Oct 14 07:12 /dev/oracleasm/disks/DISK4
brw-rw----. 1 grid asmadmin 8, 81 Oct 14 07:12 /dev/oracleasm/disks/DISK5
[root@db1 ~]#

[root@db1 ~]# systemctl status oracleasm
● oracleasm.service - Load oracleasm Modules
   Loaded: loaded (/usr/lib/systemd/system/oracleasm.service; enabled; vendor preset: disabled)
   Active: active (exited) since Sat 2023-10-14 06:32:29 EDT; 2h 55min ago
  Process: 852 ExecStart=/usr/sbin/oracleasm.init start_sysctl (code=exited, status=0/SUCCESS)
 Main PID: 852 (code=exited, status=0/SUCCESS)
    Tasks: 0 (limit: 17392)
   Memory: 0B
   CGroup: /system.slice/oracleasm.service

Oct 14 06:32:27 db1.rajasekhar.com systemd[1]: Starting Load oracleasm Modules...
Oct 14 06:32:28 db1.rajasekhar.com oracleasm.init[852]: Initializing the Oracle ASMLib driver: OK
Oct 14 06:32:29 db1.rajasekhar.com oracleasm.init[852]: Scanning the system for Oracle ASMLib disks: OK
Oct 14 06:32:29 db1.rajasekhar.com systemd[1]: Started Load oracleasm Modules.
[root@db1 ~]#


