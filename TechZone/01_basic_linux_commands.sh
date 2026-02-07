Linux
=====
$pwd
#displays the current directory (present working directory)

$clear (ctrl+l)
#used to make the screen clear

$ls
#lists all files and directories in the specified directory

$ls -al
#The -a flag lists hidden "." files. 
#The "-l" flag lists file permissions.
$ls -l #(files and their permissions)
$ll #(same as above)
$ls -a #(visible and hidden files together)

$ls -s
#to see size of files

$ls -ltr
#Will sort by time.

$cd
#is used to change directories
$cd $ORACLE_HOME

$touch
#is used to create a new empty file with the default permissions.

$touch f1 f2 f3 f4 #(creates f1 f2 f3 f4 empty text files)

$cat
#is used to display file contents.

$cat > filename 
#to create new text file and enter data into the file 
#press ctrl+d to save&exit

$cat >> filename
#to enter the data and to append existing data in a file.

$cat f1 f2 > f3 
#copy data of f1 and f2 to f3

$cp
#The cp command is used to copy files from one location to other.

$cp -rvf oldfileloc newfileloc
#(-r flag indicates recursively)
#(-v flag indicates verbose means display to us)
#(-f flag indicates forcibly means if old exist replace it)

$mv
#is used to move or rename files and directories

$mv oldloc newloc
$mv $ORACLE_HOME/dbs/spfileprod.ora /u01/user10/

$head
#is used to display top lines of the file
$head -10 filename
#(will display top 10 lines)

$tail 
#to see the last lines of a file
$tail -20 filename

$who 
#to see the users logged in to the server and their IP addresses
$who #--> no of login users
$whoami #--> current working username

$passwd
#to change password of oracle user.
$passwd oracle

$cal
#is used to display calendar
$cal -3 --> #displays previous, current and next months calendar

$mkdir 
#is used to create new directories
$mkdir dir1

$rm
#is used to delete files and directories
$rm dir1
$rm -r dir1/dir2/
#The -r flag tells the command to recurse through subdirectories.

$cp
#is used to copy files and directories
$cp dir1/file1 dir2/
$rmdir
#is used to delete directories

$mkdir dir1
$rmdir dir1

$find
#can be used to find the location of specific files
$find / -name tnsnames.ora
$find / -print | grep -I tnsnames.ora
$find . -name file_name -> to find file location from current dir
#The "/" flag represents the starting directory for the search. Wildcards such 
#as "dbms" can be used for the filename.

$which
#can be used to find the location of an executable you are using 
$which sqlplus
#The which command searches your PATH setting for occurances of the specified executable.

$umask
#can be used to read or set default file permissions for the current user.
$umask oo2
#The umask value is subtracted from the default permissions(666) to give the final permission.
666 : default permission
022 : -umask value
644 : final permission

$chmod
#is used to alter file permissions after the file has been created
$chmod 777 *.log (character equivalents can be used in the chmod command)
$chmod 0+rwx *.log
$chmod g+r *.log

$chown
#is used to reset the ownership of files after creation
$chown -R oracle:oinstall *
$chown -R oracle:oinstall /u01
#The "-R" flag causes the command to recurse through any subdirectories.

$groupadd
#is used to create a new group
$groupadd -g oinstall
$chgrp
#used to change the group of the user
$chgrp newgroup filename

$useradd
#is used to add OS users
$useradd -G oinstall -g dba -d /u01/home -m -s /bin/sh oracle
- The "-G" flag specifies the primary group.
- The "-g" flag specifies the secondary group.
- The "-d" flag specifies the default or home directory.
- The "-m" flag specifies creates the default directory.
- The "-s" flag specifies the default shell.

$chsh #(to change the default shell)
$passwd
#is used to set, or reset the users login password
$passwd oracle

$usermod
#is used to modify the user settings after a user has been created.
$usermod -s /bin/ksh oracle

$userdel
#is used to delete existing users.
$usedel -r oracle
#The "-r" flag removes the default directory.

#The "who" command can be used to list all users who have OS connections.
$who
$who | head -5
$who | tail -5
$who | grep -i ora
$who | wc -l
#- The "head -5" command restricts the output to the first 5 lines of the who commad result.
#- The "tail -5" command restricts the output to the last 5 lines of the who command result.
#- The "grep -i ora" command restricts the output to lines containing "ora".
#- The "wc -i" command returns the number of lines from "who", and hence number of connected users.

$wc
#To see the number of lines in a text file(can be used to find the number of records while loading data from text file).
$wc -l filename
$wc filename #(wll show number of lines, number of words and size)

$sort
#is used to sort the contents of a file.
$sort <option> filename
$sort -r file1 
sort and display contents of file1 in reverse order

$wall
broadcasting the message on the network
$wall <message>

$write
its one way communication, message can be sent to a particular user.
$write <username>

$mail
send the message when the user is offline
$mail <username>

$grep
global regular expression print to search for an expression in a file or group of files, grep has two flavours
egrep (extended - expands wild card characters in the expression) 
and
frep (fixed-string - does not expand wild card characters)
This is a very useful command, especially to use in scripts.
$grep oracle /etc/passwd
to display the lines containing "oracle" from /etc/passwd file.
$grep -i -l EMP_TAB *.sql 
to display only the file names (-l option) which contains the string EMP_TAB, ignore case for the string (-i option), in all files with sql extention.
$grep -v '^#' /etc/oratab
display only the lines in /etc/oratab where the lines do not (-v option; negation) start with # character(^ is a special character indicating beginning of line, similarly $ is end of line).
$find /usr/oracle -mtime +7 -print
lists all files under /usr/oracle which are older than a week.
$find /usr/oracle -mtime -7 -print
lists all files under /usr/oracle which are modified within a week.
$ps
The "ps" command lists current process information.
$ps
$ps -ef | grep -i ora
The -f does full listing.
The -e selects all processes.
$kill
to kill a process from Unis/Linux
$kill -9 12345 
specific processes can be killed by specifying the process id
$uname
$hostname
The "uname" and "hostname" commands can be used to get information about the host.
#uname -> Linux
#hostname -> dba.tzone.com
#uname -a
#uname -a|awk '{print $2}'
The "-a" flag prints basic information currently available from the system.
The "-i" flag prints name of hardware implementation (platform).
The "-r" flag displays operating system release level.

Error lines in files
You can return the error lines in a file using:
#cat alert_prod1.log | grep -i ORA-The "grep -i ORA-" | wc -l
command limits the output to lines containing "ORA-".
The "-i" flag makes the comparison case insensitive.  A count of the error lines can be returned using the "wc" command.  This normally give a word count, but the "-l" flag alters it to give a line count.
compress files
In order to save space on the filesystem you may wish to compress files such as archived redo logs.  This can be using either the gzip or the compress commands.
gzip
The gzip command results in a compressed copy of the original file with a ".gz" extention.
The gunzip command reverses this process.
#gzip myfile
#gunzip myfile.gz
compress
The compress command results in a compressed copy of the original file with a ".Z" extention.  The uncompress command reverses this process.
#compress myfile
#uncompress myfile.z
vmstat
Reports virtual memory statistics.
#vmstat 5 3
sar
collect, report or save system activity information
#sar -u 10 8
mpstat
Reports processor related statistics.
#mpstat 10 2
top
displays top tasks
#top
df [options][mountpoint]
Freespace available on the system (Disk Free); without arguments will list all the mount points.
#df (will show all mount points and sizes in kilobytes)
#df -k (same, as "k" is default)
#df -m (will show all mount points and sizes in megabytes)
#df -k /u01 (freespace available on /u01 in kilobytes)
du: du [-s][directoryname]
Disk used; gives operating system blocks used by each subdirectory.
To convert to KB, for 512k OS blocks, devide the number by 2.
#du -s
gives the summary, no listing for subdirectories

Some usefull files:
/etc/group -> group settings
/etc/hosts -> hostname information
/etc/exports -> it states how partitions are mounted and shared with other Linux/Unix systems.
/etc/fstab -> this file automatically mounts filesystems that are spread across multiple drives
/etc/inittab -> describes which processes are started at bootup or at different runlevels.
/etc/passwd -> contains user information
/etc/shells -> contains the names of all the shells installed on the system
/etc/ftpusers -> contains the login names of users who are not allowed to log in by way of FTP
/etc/shadow -> it contains encrypted passwords are stored in /etc/shadow
/etc/profile -> This file contains settings and global startup info the bash shell
/etc/crontab -> Lists commands and times to run them for the cron deamon
/var/log/messages -> The main system message log file
/var/spool/mail -> where mailboxes are usually stored
/etc/resolv.conf -> Configures the name resolver, specifying the address of your name server and your domain name.
/etc/sysconfig/network -> Defines a network interface
/proc/version -> The kernel version
/etc/redhat-release -> Includes one line stating the Red Hat release number and name
ipcs: To see the shared memory segment sizes
ipcs
ipcs -mb

To see if SQL*Net connection is OK.
tnsping SID

To see if the server is up.
ping servername
or
ping ipaddress

To see the versions of all Oracle products installed on the server.
$ORACLE_HOME/orainst/inspdver



vi EDITOR
vi editor is used to make new text files, scripting files or modifying contents of existing files.
modes of vi editor: command mode, execution mode
command mode:
i - to start insertion from current cursor position
I - to start editing from beginning of line
a - to append contents to right side of your current cursor position
A - to append contents to the end of the current cursor line
r - to replace a char from current cursor position
R - to replace a whole word from current cursor position
x - to remove the char from current cursor position
dd - to remove or to delete a line
2dd - to remove 2 lines from current cursor position
yy - to copy the line of current cursor position
2yy - to copy 2 lines from current cursor position
p - to paste the copied content to after cursor position
P - to paste the content above the cursor line
u - to undo previous operations
dgg - to remove or delete above lines including current cursor line till beginning of file
dG - to remove or delete below lines including current cursor line till end of file
l - to move cursor to character by character at a time
h - to move cursor back char by char
k - to move cursor to above line
j - to go to next line
H - to go to end of the file
G - to go to beginning of file


Execution mode
esc - to go to execution mode
:w - to save changes in the file
:q - to quit from the file
:wq - to save and quit
:x - to save and quit
:wq! - Forcibly save changes in the file and quit
:%s/oldtext/newtext/g - to replace all oldtext with newtext in the file
:se no - to display line number
:no se - to hide line number






Partitioning with fdisk
fdisk -l  - to view all available partitions
fdisk -l /dev/sda - view partitions of a specific hard disk 
fdisk -s /dev/sda - to view the size of an existing partition
mkfs.ext3 /dev/sda - after partition is created, format it using the mkfs command
partprobe /dev/sda - It will update in kernel
mount /dev/sda /u03 - mount on a particular directory
Save the /etc/fstab file.(To make partition permanent)
/dev/sda /u03 ext3 defaults 0 0

fsck /dev/sda2 - To repair a corrupted file system.











My Notes
Storage Management
Very first part of a hard disk is called MBR.

MBR=Master Boot Record

This contains partition table and boot loader program.
After MBR the second thing is our first partition.

Another is 2nd partition. These are primary partitions. We can 
create maximum 4 primary partitions. After 4 we can’t create any 
more primary partitions, so the entire remaining space is empty. 
We create there as an extended partition, which is a container for 
remaining additional partitions. Inside this extended partition 
(whole remaining empty space) we can add additional partitions (upto 16). 
These extended partitions are called as logical partitions.

We cannot have extended and primary partitions beyond 4. Total can't exceed 4. 
We can have 2 primary and 1 extended. 3 primary and 1 extended.

A single harddisk cannot have more than 4 partitions.

Storage scenario #1
------------------------
You have been given a task by your manager to plan for the future disk 
space requirement of your server.  As a first step towards this task, 
you are required to find out the following information about your server.  
Please run appropriate commands to gather the information.

1.	Names of the disks attached to your server. (fdisk)
2.	What are their sizes? (parted)
3.	How much of free space is left on each disk? (df)


1.fdisk - l
2.parted
This will take us into the parted command tool.

If we have one disk only sda we can directly enter the commands
q<enter>

3.df –h
here h for human readable format

MBR (Master Boot Record)
1st	/boot
2nd	pv (physical volume)(logical)
Volume manager concept
There are 2 partitions, both are initialized by a command. Each one will 
be a physical volume of 10g and 20g each. Here an administrator creates 
a combined 30g single piece combining both is called a vg (volume group).

All the pv and vg are given names.

PE = physical extents

Within vg we create small sections called pe.

Pv1=10g
Pv2=20g
Vg=pv1+pv2=30g

This entire 30g can be devided into smaller units called physical extents. 
Each can be say 4M. Means total 30g is divided into 4m each physical extents.
From pe we can create the next step is lv (logical volume).
From this 30g we can have logical volumes like 100 physical extents 
together become 100*4=400mb logical volume.
The advantage of doing this is on each LV we can mount a directory. Suppose we 
used almost the space of the current lv in a vg, we can come to this vg and add 
some more space to our lv. My first lv can become from 100m to 200m or more 
depending on the requirement.

Scenario
Is LVM implemented for any of the partitions. If yes, find out the following information:
Physical Volumes
	Names of all physical volumes
	Sizes of all physical volumes
Volume Groups
	Names of all volume groups
	Sizes of all volume groups
	Size of the physical extent of each volume group
	How many physical extents are present in each volume group
	How much of free space is left in each volume group
	How many extents are free in each volume group
Logical Volume
	Names of all LVs and the VG that they belong to
	Sizes of all logical volumes
	Mount points for each Logical volume, if mounted

To display how many physical volumes:
#pvdisplay
To know about volume groups:
#vgdisplay
This will show vgname, vgsize, pesize, freePE,vguuid,freeVG size
Now logical volumes information:
#lvdisplay
Will show all the available lv’s one by one.
Lvname, vgname, lv uuid, lvsize, 
In this we cant see mount points of lv. To see the mount points of lv we 
have a command called 
#df –h
To see the last lv of swap the command is :
#swapon –s

Scenario #5
A new project has been started in your organization.  The developers of this 
project need additional disk space for the source code programs related to 
this project to be stored in their respective home directories.  Increase 
the size of /home to 650mb.  If for some reason you are unable to resize it 
to 650mb, any size between 630mb and 660mb will suffice.

Note: While performing the above operation there should not be any data loss 
of existing data in the /home directory.

Commands
df –h (what kind of storage already allocated for home)
Lvextend
Resize2fs
#df –h
Logical volues can be easily resizable
Make sure the vg which contain our lv has space ?
#vgdisplay
There is size
To extend the lv 
#df –h
note down the actual name of our home lv
#lvextend –L 650M /dev/vg/Lv_home
To confirm:
#lvdisplay /dev/vg/Lv_home
To confirm is this space being used or no:
#df –h
Its still showing the old value. To tell it resize yourself:
#resize2fs /dev/vg/Lv_home
Now its resized. To confirm:
#df –h
Now shows the correct value


Scenario #6
For the above mentioned new project, there is a need to keep large 
data files on the server.  You need to create a seperate mount point 
named / sales_data for this purpose.  Create a new volume group and 
a logical volume for this purpose from the remaining free space on 
your disk/s.  The size of physical extent of the volume group should 
be 8MB.  The logical volume should have 50 extents.  This mount point 
should get automatically mounted at the boot time.

commands:
parted
fdisk 
pvcreate
vgcreate
lvcreate
mkfs
mount

Related files
/etc/fstab

the things required in series:
lv - vg - pv -- free disk space
#parted
print free
note the free space
q (to quit)
to create a pv we need a partiton
#fdisk /dev/sda
p (print)
note down how many partitons are already there. so that we can decide the next one will be primary or extended.
n (new)
p (for primary as i have only 2 partitions)
partition number free is 3
accept first available cylinder
Last cylinder (as we need a partition of 1 gb so enter +1G)
now P to see the partition created or not.
to create a pv we need to assign an id to this we need to toggle it.
t
enter partition number 3
we must know the code to be assigned for making LVM.
l to see the hexa decimal code of file system
for lvm its 8e
8e
p to print and see for confirmation
w to write and exit
but kernel is still using the old table. its not reading the new table yet.
#partx -a /dev/sda
first time it may fail. try again. it show reading.
now need to create a pv.
#pvcreate /dev/sda3
now create a volume group
#vgcreate -s 8M volgrp /dev/sda3
-s means physical extent size
now to see the things created already
#pvdisplay /dev/sda3
#vgdisplay volgrp
here we can see the vg size and pe size of 8m
now create the logical volume of 50 extents. means 50*8=400M size.
#lvcreate -l 50 -n data1 volgrp
#lvdisplay (to see it)
now create file system on it and mount
#mkfs.ext4 /dev/volgrp/data1
we need to create mount point now
under root
#mkdir /sales_data
#mount /dev/volgrp/data1 /sales_data/
to confirm its mounted or no
#df -h
ya its mounted
but this is a temporary mount. we need it permanent.
open fstab and enter the following:
#vi /etc/fstab
/dev/volgrp/data1	/sales_data	ext4	defaults	 0 0
to make sure this is working after restart also:
#reboot
#df -h
sales_data folder is mounted properly. job done.



Scenario #7
Resize the file system /opt from its current size of 300 mb to 200mb.  Do not lose any data while performing the resizing.
Commands
#df –h (will show us what kind of storage for /opt, if its lvm there is a chance of resizing, otherwise no chance of resizing)
If /opt mounted on a lvm or have storage on a lvm then we can reduce it.
#lvreduce
#resize2fs
#umount
#fsck (scanning and recovering the corrupted bloks)
Related files:
/etc/fstab 
whenever we deal with partitions we need to deal with this file.
Steps:
/opt current status
#df –h
here in this scenario its mounted on Lv_opt with 291M size
its lv it can be resizable.
here we need to reduce it to 200mb
we need to unmount it. For extending no need but to reduce we must deactivate it first, means unmount it first.
before unmounting check is there any data on to this.
#ls /opt/
There is some data.
#umount /opt/
#df –h
We wont see it now. As we unmounted it.
Before actual reducing the file scan the entire space for corrupted blocks so that they will not create any problem.
#fsck /dev/vg/Lv_opt
Its in good condition, no corrupted blocks.
Now reduce the lv.
#resize2fs /dev/vg/Lv_opt 200M
It says to run e2fsck. Means fsck not done the job.
#e2fsck –f /dev/vg/Lv_opt
#Resize2fs /dev/vg/Lv_opt 200M
#lvreduce –L 200M /dev/vg/Lv_opt
y (dataloss warning)
#mount –a
#df –h
Job done. Its reduced.
We can also fire lvdisplay to see more details
#lvdisplay
Now check weather we have lost the data or not:
#ls /opt/
