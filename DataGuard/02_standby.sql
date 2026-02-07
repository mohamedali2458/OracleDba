[oracle@localhost ~]$ ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 08:00:27:ac:a7:b0  txqueuelen 1000  (Ethernet)
        RX packets 13  bytes 4446 (4.3 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.99.11  netmask 255.255.255.0  broadcast 192.168.99.255
        inet6 fe80::4949:2007:abd8:a723  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:71:e5:71  txqueuelen 1000  (Ethernet)
        RX packets 7  bytes 620 (620.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 47  bytes 5971 (5.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:0a:ce:d5  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[oracle@localhost ~]$ ping 192.168.99.11
PING 192.168.99.11 (192.168.99.11) 56(84) bytes of data.
64 bytes from 192.168.99.11: icmp_seq=1 ttl=64 time=0.435 ms
64 bytes from 192.168.99.11: icmp_seq=2 ttl=64 time=0.104 ms
64 bytes from 192.168.99.11: icmp_seq=3 ttl=64 time=0.053 ms
64 bytes from 192.168.99.11: icmp_seq=4 ttl=64 time=0.058 ms
64 bytes from 192.168.99.11: icmp_seq=5 ttl=64 time=0.097 ms
^C64 bytes from 192.168.99.11: icmp_seq=6 ttl=64 time=0.062 ms
64 bytes from 192.168.99.11: icmp_seq=7 ttl=64 time=0.058 ms
^C
--- 192.168.99.11 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6182ms
rtt min/avg/max/mdev = 0.053/0.123/0.435/0.129 ms
[oracle@localhost ~]$ ping 192.168.99.10
PING 192.168.99.10 (192.168.99.10) 56(84) bytes of data.
64 bytes from 192.168.99.10: icmp_seq=1 ttl=64 time=4.01 ms
64 bytes from 192.168.99.10: icmp_seq=2 ttl=64 time=0.950 ms
^C
--- 192.168.99.10 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.950/2.482/4.015/1.533 ms
[oracle@localhost ~]$ cat /etc/oratab
#



# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by either Database Configuration Assistant while creating
# a database or ASM Configuration Assistant while creating ASM instance.

# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third field indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same $ORACLE_SID are not allowed.
#
#
[oracle@localhost ~]$ vi /etc/oratab
[oracle@localhost ~]$ cat /etc/o
oddjob/         oddjobd.conf.d/ openldap/       openwsman/      oracle-release  oratab          
oddjobd.conf    opa/            openlmi/        opt/            oraInst.loc     os-release      
[oracle@localhost ~]$ cat /etc/oratab 
#



# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by either Database Configuration Assistant while creating
# a database or ASM Configuration Assistant while creating ASM instance.

# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third field indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same $ORACLE_SID are not allowed.
#
#
#
#
#
#
#
#

orcls:/u01/app/oracle/product/19.0.0/dbhome_1:N
[oracle@localhost ~]$ . oraenv
ORACLE_SID = [oracle] ? orcls
The Oracle base has been set to /u01/app/oracle
[oracle@localhost ~]$ netmgr
[oracle@localhost ~]$ lsnrctl start

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:47:10

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Starting /u01/app/oracle/product/19.0.0/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/listener.ora
Log messages written to /u01/app/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.99.11)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.99.11)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                04-JAN-2026 18:47:11
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.99.11)(PORT=1521)))
Services Summary...
Service "orcls" has 1 instance(s).
  Instance "orcls", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully
[oracle@localhost ~]$ tnsping orcl

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:49:42

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcl)))
OK (40 msec)
[oracle@localhost ~]$ tnsping orcls

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:49:46

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
OK (20 msec)
[oracle@localhost ~]$ tnsping orcl

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:58:46

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcl)))
OK (110 msec)
[oracle@localhost ~]$ cd /u01/app/oracle/product/19.0.0/dbhome_1/dbs
[oracle@localhost dbs]$ ll
total 12
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:46 hc_orcl.dat
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:53 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14  2015 init.ora
[oracle@localhost dbs]$ vi initorcls.ora
[oracle@localhost dbs]$ cat initorcls.ora 
*.db_name='orcl'
[oracle@localhost dbs]$ ll
total 20
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:46 hc_orcl.dat
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:53 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14  2015 init.ora
-rw-r--r--. 1 oracle oinstall   17 Jan  4 19:07 initorcls.ora
-rw-r-----. 1 oracle oinstall 2048 Jan  4 19:34 orapworcl
[oracle@localhost dbs]$ rm orapworcl orapworcls
rm: cannot remove ‘orapworcls’: No such file or directory
[oracle@localhost dbs]$ ll
total 16
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:46 hc_orcl.dat
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:53 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14  2015 init.ora
-rw-r--r--. 1 oracle oinstall   17 Jan  4 19:07 initorcls.ora
[oracle@localhost dbs]$ cp orapworcl orapworcls
[oracle@localhost dbs]$ ll
total 24
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:46 hc_orcl.dat
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:53 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14  2015 init.ora
-rw-r--r--. 1 oracle oinstall   17 Jan  4 19:07 initorcls.ora
-rw-r-----. 1 oracle oinstall 2048 Jan  4 19:36 orapworcl
-rw-r-----. 1 oracle oinstall 2048 Jan  4 19:36 orapworcls

[oracle@localhost dbs]$ mkdir -p /u01/app/oracle/admin/orcl/adump
[oracle@localhost dbs]$ mkdir -p /u01/app/oracle/oradata/ORCL
[oracle@localhost dbs]$ mkdir -p /u01/app/oracle/fast_recovery_area/ORCL
[oracle@localhost dbs]$ mkdir -p /u01/app/oracle/fast_recovery_area/ORCLS
[oracle@localhost dbs]$ vi /etc/oratab
[oracle@localhost dbs]$ cat /etc/oratab
#
# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by either Database Configuration Assistant while creating
# a database or ASM Configuration Assistant while creating ASM instance.

# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third field indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same $ORACLE_SID are not allowed.
#
#
#
#
#
#
#
#
orcls:/u01/app/oracle/product/19.0.0/dbhome_1:N
orcl:/u01/app/oracle/product/19.0.0/dbhome_1:N

[oracle@localhost dbs]$ ll
total 24
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:46 hc_orcl.dat
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:53 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14  2015 init.ora
-rw-r--r--. 1 oracle oinstall   17 Jan  4 19:07 initorcls.ora
-rw-r-----. 1 oracle oinstall 2048 Jan  4 19:36 orapworcl
-rw-r-----. 1 oracle oinstall 2048 Jan  4 19:36 orapworcls
[oracle@localhost dbs]$ cp initorcls.ora initorcl.ora 
[oracle@localhost dbs]$ ll
total 28
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:46 hc_orcl.dat
-rw-rw----. 1 oracle oinstall 1544 Jan  2 09:53 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14  2015 init.ora
-rw-r--r--. 1 oracle oinstall   17 Jan  4 19:43 initorcl.ora
-rw-r--r--. 1 oracle oinstall   17 Jan  4 19:07 initorcls.ora
-rw-r-----. 1 oracle oinstall 2048 Jan  4 19:36 orapworcl
-rw-r-----. 1 oracle oinstall 2048 Jan  4 19:36 orapworcls
[oracle@localhost dbs]$ . oraen
bash: oraen: No such file or directory
[oracle@localhost dbs]$ . oraenv
ORACLE_SID = [orcls] ? orcls
The Oracle base remains unchanged with value /u01/app/oracle
[oracle@localhost dbs]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sun Jan 4 19:44:39 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> !
[oracle@localhost dbs]$ . oraenv
ORACLE_SID = [orcls] ? orcl
The Oracle base remains unchanged with value /u01/app/oracle

[oracle@localhost dbs]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sun Jan 4 19:45:56 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup nomount
ORACLE instance started.

Total System Global Area  285211696 bytes
Fixed Size		    8895536 bytes
Variable Size		  218103808 bytes
Database Buffers	   50331648 bytes
Redo Buffers		    7880704 bytes
SQL> !
[oracle@localhost dbs]$ rman target sys/oracle@orcl auxiliary sys/oracle@orcls

Recovery Manager: Release 19.0.0.0.0 - Production on Sun Jan 4 19:51:10 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: ORCL (DBID=1748542883)
connected to auxiliary database (not started)

RMAN>   run
{
DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE
SPFILE
PARAMETER_VALUE_CONVERT='orcl','orcls'
SET DB_NAME='orcl'
SET DB_UNIQUE_NAME='orcls'
SET STANDBY_FILE_MANAGEMENT='AUTO'
set audit_file_dest ='/u01/app/oracle/admin/orcl/adump'
set db_recovery_file_dest='/u01/app/oracle/fast_recovery_area'
set fal_server='orcl'
set control_files='/u01/app/oracle/oradata/ORCL/control01.ctl','/u01/app/oracle/fast_recovery_area/ORCL/control02.ctl'
NOFILENAMECHECK;
}2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> 14> 

Starting Duplicate Db at 04-JAN-26
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of Duplicate Db command at 01/04/2026 19:51:48
RMAN-05501: aborting duplication of target database
RMAN-06403: could not obtain a fully authorized session
RMAN-04006: error from auxiliary database: ORA-01034: ORACLE not available
ORA-27101: shared memory realm does not exist
Linux-x86_64 Error: 2: No such file or directory
Additional information: 4376
Additional information: 964975255

RMAN> EXIT


Recovery Manager complete.
[oracle@localhost dbs]$ . oraenv
ORACLE_SID = [orcl] ? orcls
The Oracle base remains unchanged with value /u01/app/oracle
[oracle@localhost dbs]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sun Jan 4 19:56:39 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup nomunt
SP2-0714: invalid combination of STARTUP options
SQL> startup nomount
ORACLE instance started.

Total System Global Area  285211696 bytes
Fixed Size		    8895536 bytes
Variable Size		  218103808 bytes
Database Buffers	   50331648 bytes
Redo Buffers		    7880704 bytes
SQL> !
[oracle@localhost dbs]$   run
bash: run: command not found...
[oracle@localhost dbs]$ {
> DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE
> SPFILE
> PARAMETER_VALUE_CONVERT='orcl','orcls'
> SET DB_NAME='orcl'
> SET DB_UNIQUE_NAME='orcls'
> SET STANDBY_FILE_MANAGEMENT='AUTO'
> set audit_file_dest ='/u01/app/oracle/admin/orcl/adump'
> set db_recovery_file_dest='/u01/app/oracle/fast_recovery_area'
> set fal_server='orcl'
> set control_files='/u01/app/oracle/oradata/ORCL/control01.ctl','/u01/app/oracle/fast_recovery_area/ORCL/control02.ctl'
> NOFILENAMECHECK;
> 
> 
> ^C
[oracle@localhost dbs]$ rman target sys/oracle@orcl auxiliary sys/oracle@orcls

Recovery Manager: Release 19.0.0.0.0 - Production on Sun Jan 4 19:59:58 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: ORCL (DBID=1748542883)
connected to auxiliary database: ORCL (not mounted)

RMAN>   run
{
DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE
SPFILE
PARAMETER_VALUE_CONVERT='orcl','orcls'
SET DB_NAME='orcl'
SET DB_UNIQUE_NAME='orcls'
SET STANDBY_FILE_MANAGEMENT='AUTO'
set audit_file_dest ='/u01/app/oracle/admin/orcl/adump'
set db_recovery_file_dest='/u01/app/oracle/fast_recovery_area'
set fal_server='orcl'
set control_files='/u01/app/oracle/oradata/ORCL/control01.ctl','/u01/app/oracle/fast_recovery_area/ORCL/control02.ctl'
NOFILENAMECHECK;
}2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> 14> 

Starting Duplicate Db at 04-JAN-26
using target database control file instead of recovery catalog
allocated channel: ORA_AUX_DISK_1
channel ORA_AUX_DISK_1: SID=163 device type=DISK

contents of Memory Script:
{
   backup as copy reuse
   passwordfile auxiliary format  '/u01/app/oracle/product/19.0.0/dbhome_1/dbs/orapworcls'   ;
   restore clone from service  'orcl' spfile to 
 '/u01/app/oracle/product/19.0.0/dbhome_1/dbs/spfileorcls.ora';
   sql clone "alter system set spfile= ''/u01/app/oracle/product/19.0.0/dbhome_1/dbs/spfileorcls.ora''";
}
executing Memory Script

Starting backup at 04-JAN-26
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=179 device type=DISK
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of Duplicate Db command at 01/04/2026 20:00:32
RMAN-05501: aborting duplication of target database
RMAN-03015: error occurred in stored script Memory Script
RMAN-03009: failure of backup command on ORA_DISK_1 channel at 01/04/2026 20:00:32
ORA-17627: ORA-12545: Connect failed because target host or object does not exist
ORA-17629: Cannot connect to the remote database server

RMAN> exit


Recovery Manager complete.
[oracle@localhost dbs]$ lsnrctl reload

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 20:04:27

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.99.11)(PORT=1521)))
The command completed successfully
[oracle@localhost dbs]$ tnsping orcls

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 20:04:43

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
OK (0 msec)
[oracle@localhost dbs]$ tnsping orcl

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 20:04:48

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcl)))
OK (20 msec)
[oracle@localhost dbs]$ rman target sys/oracle@orcl auxiliary sys/oracle@orcls

Recovery Manager: Release 19.0.0.0.0 - Production on Sun Jan 4 20:08:49 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: ORCL (DBID=1748542883)
connected to auxiliary database: ORCL (not mounted)

RMAN>   run
{
DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE
SPFILE
PARAMETER_VALUE_CONVERT='orcl','orcls'
SET DB_NAME='orcl'
SET DB_UNIQUE_NAME='orcls'
SET STANDBY_FILE_MANAGEMENT='AUTO'
set audit_file_dest ='/u01/app/oracle/admin/orcl/adump'
set db_recovery_file_dest='/u01/app/oracle/fast_recovery_area'
set fal_server='orcl'
set control_files='/u01/app/oracle/oradata/ORCL/control01.ctl','/u01/app/oracle/fast_recovery_area/ORCL/control02.ctl'
NOFILENAMECHECK;
}2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> 14> 

Starting Duplicate Db at 04-JAN-26
using target database control file instead of recovery catalog
allocated channel: ORA_AUX_DISK_1
channel ORA_AUX_DISK_1: SID=161 device type=DISK

contents of Memory Script:
{
   backup as copy reuse
   passwordfile auxiliary format  '/u01/app/oracle/product/19.0.0/dbhome_1/dbs/orapworcls'   ;
   restore clone from service  'orcl' spfile to 
 '/u01/app/oracle/product/19.0.0/dbhome_1/dbs/spfileorcls.ora';
   sql clone "alter system set spfile= ''/u01/app/oracle/product/19.0.0/dbhome_1/dbs/spfileorcls.ora''";
}
executing Memory Script

Starting backup at 04-JAN-26
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=182 device type=DISK
Finished backup at 04-JAN-26

Starting restore at 04-JAN-26
using channel ORA_AUX_DISK_1

channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: using network backup set from service orcl
channel ORA_AUX_DISK_1: restoring SPFILE
output file name=/u01/app/oracle/product/19.0.0/dbhome_1/dbs/spfileorcls.ora
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:00:02
Finished restore at 04-JAN-26

sql statement: alter system set spfile= ''/u01/app/oracle/product/19.0.0/dbhome_1/dbs/spfileorcls.ora''

contents of Memory Script:
{
   sql clone "alter system set  dispatchers = 
 ''(PROTOCOL=TCP) (SERVICE=orclsXDB)'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_name = 
 ''orcl'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_unique_name = 
 ''orcls'' comment=
 '''' scope=spfile";
   sql clone "alter system set  STANDBY_FILE_MANAGEMENT = 
 ''AUTO'' comment=
 '''' scope=spfile";
   sql clone "alter system set  audit_file_dest = 
 ''/u01/app/oracle/admin/orcl/adump'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_recovery_file_dest = 
 ''/u01/app/oracle/fast_recovery_area'' comment=
 '''' scope=spfile";
   sql clone "alter system set  fal_server = 
 ''orcl'' comment=
 '''' scope=spfile";
   sql clone "alter system set  control_files = 
 ''/u01/app/oracle/oradata/ORCL/control01.ctl'', ''/u01/app/oracle/fast_recovery_area/ORCL/control02.ctl'' comment=
 '''' scope=spfile";
   shutdown clone immediate;
   startup clone nomount;
}
executing Memory Script

sql statement: alter system set  dispatchers =  ''(PROTOCOL=TCP) (SERVICE=orclsXDB)'' comment= '''' scope=spfile

sql statement: alter system set  db_name =  ''orcl'' comment= '''' scope=spfile

sql statement: alter system set  db_unique_name =  ''orcls'' comment= '''' scope=spfile

sql statement: alter system set  STANDBY_FILE_MANAGEMENT =  ''AUTO'' comment= '''' scope=spfile

sql statement: alter system set  audit_file_dest =  ''/u01/app/oracle/admin/orcl/adump'' comment= '''' scope=spfile

sql statement: alter system set  db_recovery_file_dest =  ''/u01/app/oracle/fast_recovery_area'' comment= '''' scope=spfile

sql statement: alter system set  fal_server =  ''orcl'' comment= '''' scope=spfile

sql statement: alter system set  control_files =  ''/u01/app/oracle/oradata/ORCL/control01.ctl'', ''/u01/app/oracle/fast_recovery_area/ORCL/control02.ctl'' comment= '''' scope=spfile

Oracle instance shut down

connected to auxiliary database (not started)
Oracle instance started

Total System Global Area    1191181696 bytes

Fixed Size                     8895872 bytes
Variable Size                721420288 bytes
Database Buffers             452984832 bytes
Redo Buffers                   7880704 bytes
duplicating Online logs to Oracle Managed File (OMF) location

contents of Memory Script:
{
   restore clone from service  'orcl' standby controlfile;
}
executing Memory Script

Starting restore at 04-JAN-26
allocated channel: ORA_AUX_DISK_1
channel ORA_AUX_DISK_1: SID=329 device type=DISK

channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: using network backup set from service orcl
channel ORA_AUX_DISK_1: restoring control file
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:00:13
output file name=/u01/app/oracle/oradata/ORCL/control01.ctl
output file name=/u01/app/oracle/fast_recovery_area/ORCL/control02.ctl
Finished restore at 04-JAN-26

contents of Memory Script:
{
   sql clone 'alter database mount standby database';
}
executing Memory Script

sql statement: alter database mount standby database
RMAN-05538: warning: implicitly using DB_FILE_NAME_CONVERT
RMAN-05158: WARNING: auxiliary (datafile) file name /u01/app/oracle/oradata/ORCL/system01.dbf conflicts with a file used by the target database
RMAN-05158: WARNING: auxiliary (datafile) file name /u01/app/oracle/oradata/ORCL/sysaux01.dbf conflicts with a file used by the target database
RMAN-05158: WARNING: auxiliary (datafile) file name /u01/app/oracle/oradata/ORCL/undotbs01.dbf conflicts with a file used by the target database
RMAN-05158: WARNING: auxiliary (datafile) file name /u01/app/oracle/oradata/ORCL/users01.dbf conflicts with a file used by the target database
RMAN-05158: WARNING: auxiliary (tempfile) file name /u01/app/oracle/oradata/ORCL/temp01.dbf conflicts with a file used by the target database

contents of Memory Script:
{
   set newname for tempfile  1 to 
 "/u01/app/oracle/oradata/ORCL/temp01.dbf";
   switch clone tempfile all;
   set newname for datafile  1 to 
 "/u01/app/oracle/oradata/ORCL/system01.dbf";
   set newname for datafile  3 to 
 "/u01/app/oracle/oradata/ORCL/sysaux01.dbf";
   set newname for datafile  4 to 
 "/u01/app/oracle/oradata/ORCL/undotbs01.dbf";
   set newname for datafile  7 to 
 "/u01/app/oracle/oradata/ORCL/users01.dbf";
   restore
   from  nonsparse   from service 
 'orcl'   clone database
   ;
   sql 'alter system archive log current';
}
executing Memory Script

executing command: SET NEWNAME

renamed tempfile 1 to /u01/app/oracle/oradata/ORCL/temp01.dbf in control file

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

Starting restore at 04-JAN-26
using channel ORA_AUX_DISK_1

channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: using network backup set from service orcl
channel ORA_AUX_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_AUX_DISK_1: restoring datafile 00001 to /u01/app/oracle/oradata/ORCL/system01.dbf
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:03:00
channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: using network backup set from service orcl
channel ORA_AUX_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_AUX_DISK_1: restoring datafile 00003 to /u01/app/oracle/oradata/ORCL/sysaux01.dbf
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:00:56
channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: using network backup set from service orcl
channel ORA_AUX_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_AUX_DISK_1: restoring datafile 00004 to /u01/app/oracle/oradata/ORCL/undotbs01.dbf
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:00:07
channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: using network backup set from service orcl
channel ORA_AUX_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_AUX_DISK_1: restoring datafile 00007 to /u01/app/oracle/oradata/ORCL/users01.dbf
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:00:01
Finished restore at 04-JAN-26

sql statement: alter system archive log current

contents of Memory Script:
{
   switch clone datafile all;
}
executing Memory Script

datafile 1 switched to datafile copy
input datafile copy RECID=1 STAMP=1221682559 file name=/u01/app/oracle/oradata/ORCL/system01.dbf
datafile 3 switched to datafile copy
input datafile copy RECID=2 STAMP=1221682559 file name=/u01/app/oracle/oradata/ORCL/sysaux01.dbf
datafile 4 switched to datafile copy
input datafile copy RECID=3 STAMP=1221682559 file name=/u01/app/oracle/oradata/ORCL/undotbs01.dbf
datafile 7 switched to datafile copy
input datafile copy RECID=4 STAMP=1221682559 file name=/u01/app/oracle/oradata/ORCL/users01.dbf
Finished Duplicate Db at 04-JAN-26

RMAN> 

RMAN> 

RMAN> 

RMAN> exit


Recovery Manager complete.
[oracle@localhost dbs]$ sqlplus

SQL*Plus: Release 19.0.0.0.0 - Production on Sun Jan 4 20:16:55 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Enter user-name: /as sysdba

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> show user
USER is "SYS"
SQL> def
DEFINE _DATE	       = "04-JAN-26" (CHAR)
DEFINE _CONNECT_IDENTIFIER = "orcls" (CHAR)
DEFINE _USER	       = "SYS" (CHAR)
DEFINE _PRIVILEGE      = "AS SYSDBA" (CHAR)
DEFINE _SQLPLUS_RELEASE = "1903000000" (CHAR)
DEFINE _EDITOR	       = "vi" (CHAR)
DEFINE _O_VERSION      = "Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0" (CHAR)
DEFINE _O_RELEASE      = "1903000000" (CHAR)
SQL> select name,open_mode,database_role,protection_mode from v$database;

NAME	  OPEN_MODE	       DATABASE_ROLE	PROTECTION_MODE
--------- -------------------- ---------------- --------------------
ORCL	  MOUNTED	       PHYSICAL STANDBY MAXIMUM PERFORMANCE

SQL> SELECT log_mode FROM v$database;

LOG_MODE
------------
ARCHIVELOG

SQL> recover managed  standby database disconnect from session;
Media recovery complete.
SQL> select name,open_mode,database_role,protection_mode from v$database;

NAME	  OPEN_MODE	       DATABASE_ROLE	PROTECTION_MODE
--------- -------------------- ---------------- --------------------
ORCL	  MOUNTED	       PHYSICAL STANDBY MAXIMUM PERFORMANCE

SQL> 