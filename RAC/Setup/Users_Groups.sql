Create users, groups and Paths for Oracle RAC

Step 1: Create groups

[root@testbox ~]# /usr/sbin/groupadd -g 3001 oinstall
[root@testbox ~]# /usr/sbin/groupadd -g 3002 dba
[root@testbox ~]# /usr/sbin/groupadd -g 3003 asmadmin
[root@testbox ~]# /usr/sbin/groupadd -g 3004 asmdba
[root@testbox ~]# /usr/sbin/groupadd -g 3005 asmoper
[root@testbox ~]#

Step 2: Create users

[root@testbox ~]# /usr/sbin/useradd -u 3000 -g oinstall -G asmdba,dba,asmadmin,asmoper grid
[root@testbox ~]# /usr/sbin/useradd -u 3001 -g oinstall -G asmdba,dba,asmadmin oracle
[root@testbox ~]#

Step 3: Verify users and groups

[root@testbox ~]# id oracle
uid=3001(oracle) gid=3001(oinstall) groups=3001(oinstall),3002(dba),3003(asmadmin),3004(asmdba)
[root@testbox ~]#
[root@testbox ~]# id grid
uid=3000(grid) gid=3001(oinstall) groups=3001(oinstall),3002(dba),3003(asmadmin),3004(asmdba),3005(asmoper)
[root@testbox ~]#

[root@testbox ~]# grep oracle /etc/passwd
oracle:x:3001:3001::/home/oracle:/bin/bash
[root@testbox ~]#

[root@testbox ~]# grep grid /etc/passwd
grid:x:3000:3001::/home/grid:/bin/bash
[root@testbox ~]#

[root@testbox ~]# ls -ld /home/grid
drwx------. 3 grid oinstall 78 Apr  2 02:06 /home/grid
[root@testbox ~]#
[root@testbox ~]# ls -ld /home/oracle
drwx------. 3 oracle oinstall 78 Apr  2 02:06 /home/oracle
[root@testbox ~]#

Step 4: Create directory Paths for grid and oracle installation

# mkdir -p /u01/app/grid ( ORACLE_BASE for GRID HOME )
# mkdir -p /u01/app/19.0.0/grid         ( GRID_HOME )
# chown -R grid:oinstall /u01

# mkdir -p /u01/app/oracle              ( ORACLE_BASE for ORACLE HOME ) 
# mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1 ( ORACLE HOME )
# chown -R oracle:oinstall /u01/app/oracle

# chmod -R 775 /u01/

[root@testbox ~]# mkdir -p /u01/app/19.0.0/grid
[root@testbox ~]# mkdir -p /u01/app/grid
[root@testbox ~]# chown -R grid:oinstall /u01
[root@testbox ~]#
[root@testbox ~]# mkdir -p /u01/app/oracle
[root@testbox ~]# mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1
[root@testbox ~]# chown -R oracle:oinstall /u01/app/oracle
[root@testbox ~]# chmod -R 775 /u01/
[root@testbox ~]#

Step 5: Verify ownership and permissions

[root@testbox ~]# ls -ld /u01/app/19.0.0/grid
drwxrwxr-x. 2 grid oinstall 4096 Apr  2 03:08 /u01/app/19.0.0/grid
[root@testbox ~]# ls -ld /u01/app/grid
drwxrwxr-x. 2 grid oinstall 4096 Apr  2 03:08 /u01/app/grid
[root@testbox ~]#

[root@testbox ~]# ls -ld /u01/app/oracle
drwxrwxr-x. 3 oracle oinstall 4096 Apr  2 03:10 /u01/app/oracle
[root@testbox ~]# ls -ld /u01/app/oracle/product/19.0.0/dbhome_1
drwxrwxr-x. 2 oracle oinstall 4096 Apr  2 03:10 /u01/app/oracle/product/19.0.0/dbhome_1
[root@testbox ~]#

