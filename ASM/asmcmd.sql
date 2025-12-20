ASMCMD USEFUL COMMANDS 
======================
1. Let’s check ASMCMD’s version. 
[oracle@dbnode1 ~]$ asmcmd -V 

Let’s enter into ASMCMD Command-Line utility. 
[oracle@dbnode1 ~]$ asmcmd 
ASMCMD>

Now We are in ASMCMD Command-Line utility. We will now see few asmcmd commands about diskgroups. 

2. To list the diskgroups we have. 
ASMCMD> lsdg 

3. To check details of all the diskgroups, i.e. Mounted and Dismounted, We would use lsdg command with “–– discovery” argument. 
ASMCMD> lsdg –discovery

4. To mount a diskgroup in ASMCMD, we will try mounting FRA diskgroup. 
ASMCMD> mount FRA 
Command executed without an error. 

List diskgroups now 
ASMCMD> lsdg

5. To list a particular diskgroup. 
ASMCMD> lsdg DATA 

6. To list Mounted ASM disks. 
ASMCMD> lsdsk 

7. To check details of ASM disks. 
ASMCMD> lsdsk -k 

8. To check information for a particular disk. 
ASMCMD> lsdsk -k -G DATA 

9. To get Input/Output State details of disks. 
ASMCMD> iostat 

10. To check above details for a particular Disk. 
ASMCMD> iostat -G FRA 

ASMCMD> iostat -e 
Group_Name Dsk_Name Reads Writes Read_Err Write_Err 
DATA DATA01 5450240 13280256 0 0 
FRA FRA01 98304 4096 0 0 
This will show you IO erros of disk. 

12. To get Time Statistics, Read Time & Write Time.
ASMCMD> iostat -e -t 

13. To get information about OracleASM ServerParameter file. 
ASMCMD> spget 

14. To List the current directory. 
ASMCMD> ls -l 
ASMCMD> cd DATA 
ASMCMD> ls -l 

16. To print current directory path in ASMCMD Command-Line utility, connect ASMCMD using -p argument. 
[oracle@dbnode1 ~]$ asmcmd -p 
ASMCMD [+] > 

We can see It is showing ‘+’ that is Root Directory. Let’s navigate to sub-directory. 
ASMCMD [+] > ls 
DATA/ 
FRA/ 

ASMCMD [+] > cd +DATA/PRTDB/DATAFILE 
ASMCMD [+DATA/PRTDB/DATAFILE] > ls 
EXAMPLE.264.986768097 
SYSAUX.257.986767995 
SYSTEM.256.986767993 
TBS.269.986769231 
UNDOTBS1.258.986767995 
UNDOTBS2.265.986768163 
USERS.259.986767995

Here we can see current directory “ASMCMD [+DATA/PRTDB/DATAFILE] >” 

Even after navigating to subdirectory. 

We are now in datafile directory of PRTDB database. 

17. To check permissions on file. 
ASMCMD [+DATA/PRTDB/DATAFILE] > ls –permission 
User Group Permission Name 
rw-rw-rw- EXAMPLE.264.986768097 
rw-rw-rw- SYSAUX.257.986767995 
rw-rw-rw- SYSTEM.256.986767993 
rw-rw-rw- TBS.269.986769231 
rw-rw-rw- UNDOTBS1.258.986767995 
rw-rw-rw- UNDOTBS2.265.986768163 
rw-rw-rw- USERS.259.986767995 

18. To check disk usage. 
ASMCMD [+DATA] > du 
Used_MB Mirror_used_MB 
3154 3154 

19. To find file with name. 
ASMCMD [+DATA] > find + system* 
+DATA/PRTDB/DATAFILE/SYSTEM.256.986767993 

Here we found file containing system in its name. 

20. To list currently open files by all instances in ASM Use Below Command. 
ASMCMD [+] > lsof





`asmcmd` is the command-line utility used to manage **Oracle Automatic Storage Management (ASM)** instances. 
It provides a familiar, shell-like interface (similar to Linux) to navigate and manage ASM disk groups, files, and directories.

Here is a breakdown of the most essential `asmcmd` commands categorized by their function.

---

## 1. Navigation and File Management

Since ASM does not use a standard file system, these commands allow you to browse it like a traditional directory tree.

* **`ls`**: Lists the contents of an ASM directory or disk group. Use `-l` for details.
* **`cd`**: Changes the current directory (e.g., `cd +DATA/ORCL/DATAFILE`).
* **`pwd`**: Displays the current path.
* **`mkdir`**: Creates a new directory within a disk group.
* **`rm`**: Deletes a file or directory.
* **`cp`**: Copies files between ASM and local file systems, or between two ASM locations.

---

## 2. Disk Group Management

These commands are used to monitor the health, capacity, and status of your storage pools.

* **`lsdg`**: Lists all disk groups, their state (MOUNTED/DISMOUNTED), total size, and free space.
* **`lsattr`**: Lists the attributes of a disk group (e.g., `compatible.asm`, `au_size`).
* **`setattr`**: Changes the attribute of a disk group.
* **`mount` / `umount**`: Mounts or dismounts a specific disk group.
* **`rebal`**: Manually starts a rebalance operation on a disk group.

---

## 3. Disk and Device Management

Use these to identify the physical or logical disks associated with ASM.

* **`lsdsk`**: Lists the disks visible to ASM. You can use the `-p` flag for details on the physical path.
* **`chdsk`**: Changes the status of a disk (e.g., bringing it online or offline).
* **`online` / `offline**`: Brings a disk back online or takes it offline for maintenance.

---

## 4. Instance and Cluster Management

These commands interact with the ASM instance itself and the Oracle Restart/Grid Infrastructure.

* **`lsct`**: Lists information about the ASM clients (which database instances are connected to the ASM instance).
* **`showversion`**: Displays the ASM version.
* **`spget`**: Shows the location of the ASM SPFILE.
* **`dsget`**: Displays the disk discovery string (the path ASM searches for disks).

---

## 5. Metadata and Backup

* **`md_backup`**: Creates a backup of the metadata for one or more disk groups. This is critical for disaster recovery of the ASM structure.
* **`md_restore`**: Restores the disk group metadata from a backup file created by `md_backup`.

---

### Pro-Tips for using `asmcmd`

* **Interactive vs. Non-interactive:** You can enter the utility by typing `asmcmd` at the OS prompt, or run commands directly like `asmcmd lsdg`.
* **Help:** Type `help <command>` (e.g., `help lsdg`) inside the utility for a full list of flags and syntax examples.
* **Wildcards:** Most commands support wildcards (e.g., `ls -l *.dbf`).

Would you like me to provide a specific example of how to use one of these commands, such as **copying a file** or **checking disk group redundancy**?
