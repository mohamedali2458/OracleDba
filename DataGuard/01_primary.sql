[oracle@localhost ~]$ ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 08:00:27:3e:11:79  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 76  bytes 12700 (12.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.99.10  netmask 255.255.255.0  broadcast 192.168.99.255
        inet6 fe80::9ce9:33df:5ddb:b980  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:24:f3:a9  txqueuelen 1000  (Ethernet)
        RX packets 34  bytes 5016 (4.8 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 66  bytes 9117 (8.9 KiB)
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

[oracle@localhost ~]$ ping 192.168.99.10
PING 192.168.99.10 (192.168.99.10) 56(84) bytes of data.
64 bytes from 192.168.99.10: icmp_seq=1 ttl=64 time=0.142 ms
64 bytes from 192.168.99.10: icmp_seq=2 ttl=64 time=0.054 ms
^C
--- 192.168.99.10 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1028ms
rtt min/avg/max/mdev = 0.054/0.098/0.142/0.044 ms
[oracle@localhost ~]$ ping 192.168.99.11
PING 192.168.99.11 (192.168.99.11) 56(84) bytes of data.
64 bytes from 192.168.99.11: icmp_seq=1 ttl=64 time=1.97 ms
64 bytes from 192.168.99.11: icmp_seq=2 ttl=64 time=1.60 ms
^C
--- 192.168.99.11 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1005ms
rtt min/avg/max/mdev = 1.603/1.786/1.970/0.188 ms
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
orcl:/u01/app/oracle/product/19.0.0/dbhome_1:N
prod:/u01/app/oracle/product/19.0.0/dbhome_1:N


[oracle@localhost ~]$ . oraenv
ORACLE_SID = [oracle] ? orcl 
The Oracle base has been set to /u01/app/oracle

[oracle@localhost ~]$ netmgr
[oracle@localhost ~]$ 

[oracle@localhost ~]$ sqlplus / as sysdba
SQL*Plus: Release 19.0.0.0.0 - Production on Sun Jan 4 18:32:15 2026
Version 19.3.0.0.0
Copyright (c) 1982, 2019, Oracle.  All rights reserved.
Connected to an idle instance.

SQL> startup
ORACLE instance started.
Total System Global Area 1191181696 bytes
Fixed Size		    8895872 bytes
Variable Size		  738197504 bytes
Database Buffers	  436207616 bytes
Redo Buffers		    7880704 bytes
Database mounted.
Database opened.

SQL> !
[oracle@localhost ~]$ lsnrctl start
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:37:23
Copyright (c) 1991, 2019, Oracle.  All rights reserved.
Starting /u01/app/oracle/product/19.0.0/dbhome_1/bin/tnslsnr: please wait...
TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/listener.ora
Log messages written to /u01/app/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.99.10)(PORT=1521)))
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.99.10)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                04-JAN-2026 18:37:24
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.99.10)(PORT=1521)))
Services Summary...
Service "orcl" has 1 instance(s).
  Instance "orcl", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully


[oracle@localhost ~]$ tnsping orcl
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:38:08
Copyright (c) 1997, 2019, Oracle.  All rights reserved.
Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcl)))
OK (10 msec)


[oracle@localhost ~]$ netmgr
[oracle@localhost ~]$ tnsping orcl
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:46:37
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcl)))
OK (0 msec)

[oracle@localhost ~]$ tnsping orcls
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:46:42
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192..168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
TNS-12545: Connect failed because target host or object does not exist


[oracle@localhost ~]$ tnsping orcls
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:47:29
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192..168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
TNS-12545: Connect failed because target host or object does not exist

[oracle@localhost ~]$ tnsping orcl
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:48:09
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcl)))
OK (0 msec)


[oracle@localhost ~]$ tnsping orcls
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:48:14
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192..168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
TNS-12545: Connect failed because target host or object does not exist


[oracle@localhost ~]$ tnsping orcls
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 18:49:54
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192..168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
TNS-12545: Connect failed because target host or object does not exist


[oracle@localhost ~]$ netmgr
[oracle@localhost ~]$ cd /u01/app/oracle/product/19.0.0/dbhome_1/dbs
[oracle@localhost dbs]$ ll
total 18324
-rw-rw----. 1 oracle oinstall     1544 Jan  4 18:32 hc_orcl.dat
-rw-rw----. 1 oracle oinstall     1544 Dec 30 09:48 hc_prod.dat
-rw-r--r--. 1 oracle oinstall     3079 May 14  2015 init.ora
-rw-r-----. 1 oracle oinstall       24 Dec 25 04:29 lkORCL
-rw-r-----. 1 oracle oinstall       24 Dec 25 04:38 lkPROD
-rw-r-----. 1 oracle oinstall     2048 Dec 25 04:36 orapworcl
-rw-r-----. 1 oracle oinstall     2048 Dec 25 04:44 orapwprod
-rw-r-----. 1 oracle oinstall 18726912 Dec 27 06:14 snapcf_prod.f
-rw-r-----. 1 oracle oinstall     3584 Jan  4 18:32 spfileorcl.ora
-rw-r-----. 1 oracle oinstall     3584 Dec 30 09:49 spfileprod.ora

[oracle@localhost dbs]$ scp orapworcl oracle@192.168.99.11:/u01/app/oracle/product/19.0.0/dbhome_1/dbs
oracle@192.168.99.11's password: 
orapworcl                                                                                                       100% 2048   114.2KB/s   00:00    
[oracle@localhost dbs]$ scp orapworcl oracle@192.168.99.11:/u01/app/oracle/product/19.0.0/dbhome_1/dbs
oracle@192.168.99.11's password: 
orapworcl                                                                                                       100% 2048   167.8KB/s   00:00    

[oracle@localhost dbs]$ sqlplus / as sysdba
SQL*Plus: Release 19.0.0.0.0 - Production on Sun Jan 4 19:47:18 2026
Version 19.3.0.0.0
Copyright (c) 1982, 2019, Oracle.  All rights reserved.
Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> startup 
ORA-01081: cannot start already-running ORACLE - shut it down first

SQL> select name, open_mode, database_role from v$database;
NAME	  OPEN_MODE	       DATABASE_ROLE
--------- -------------------- ----------------
ORCL	  READ WRITE	       PRIMARY

SQL> SELECT log_mode FROM v$database;
LOG_MODE
------------
ARCHIVELOG

SQL> ALTER DATABASE FORCE LOGGING;
Database altered.

SQL> ALTER SYSTEM SWITCH LOGFILE;
System altered.

SQL> select name, open_mode, database_role from v$database;
NAME	  OPEN_MODE	           DATABASE_ROLE
--------- -------------------- ----------------
ORCL	  READ WRITE	       PRIMARY

SQL> ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=MANUAL scope=both;
System altered.

SQL> !
[oracle@localhost dbs]$ lsnrctl reload
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 20:05:08
Copyright (c) 1991, 2019, Oracle.  All rights reserved.
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.99.10)(PORT=1521)))
The command completed successfully


[oracle@localhost dbs]$ tnsping orcl
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 20:05:16
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcl)))
OK (0 msec)


[oracle@localhost dbs]$ tnsping orcls
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 20:05:19
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192..168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
TNS-12545: Connect failed because target host or object does not exist


[oracle@localhost dbs]$ netmgr
[oracle@localhost dbs]$ cd /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/
[oracle@localhost admin]$ ll
total 12
-rw-r--r--. 1 oracle oinstall  468 Jan  4 18:29 listener.ora
drwxr-xr-x. 2 oracle oinstall   64 Apr 17  2019 samples
-rw-r--r--. 1 oracle oinstall 1536 Feb 14  2018 shrept.lst
-rw-r--r--. 1 oracle oinstall  515 Jan  4 18:31 tnsnames.ora

[oracle@localhost admin]$ cat tnsnames.ora 
# tnsnames.ora Network Configuration File: /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

ORCLS =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192..168.99.11)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcls)
    )
  )

ORCL =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.10)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl)
    )
  )



[oracle@localhost admin]$ netmgr
[oracle@localhost admin]$ tnsping orcls
TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 04-JAN-2026 20:08:37
Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.11)(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = orcls)))
OK (20 msec)


[oracle@localhost admin]$ sqlplus / as sysdba
SQL*Plus: Release 19.0.0.0.0 - Production on Sun Jan 4 20:18:47 2026
Version 19.3.0.0.0
Copyright (c) 1982, 2019, Oracle.  All rights reserved.
Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> def
DEFINE _DATE	       = "04-JAN-26" (CHAR)
DEFINE _CONNECT_IDENTIFIER = "orcl" (CHAR)
DEFINE _USER	       = "SYS" (CHAR)
DEFINE _PRIVILEGE      = "AS SYSDBA" (CHAR)
DEFINE _SQLPLUS_RELEASE = "1903000000" (CHAR)
DEFINE _EDITOR	       = "vi" (CHAR)
DEFINE _O_VERSION      = "Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0" (CHAR)
DEFINE _O_RELEASE      = "1903000000" (CHAR)


SQL> select name, open_mode, database_role from v$database;
NAME	  OPEN_MODE	       DATABASE_ROLE
--------- -------------------- ----------------
ORCL	  READ WRITE	       PRIMARY

SQL> SELECT log_mode FROM v$database;
LOG_MODE
------------
ARCHIVELOG

SQL> select a.GROUP#, a.THREAD#, a.BYTES/1024/1024, a.MEMBERS, a.SEQUENCE#, a.STATUS, b.TYPE, b.MEMBER 
     from v$log a, v$logfile b 
     where a.GROUP# = b.GROUP#;

    GROUP#    THREAD# A.BYTES/1024/1024    MEMBERS  SEQUENCE# STATUS
---------- ---------- ----------------- ---------- ---------- ----------------
TYPE
-------
MEMBER
--------------------------------------------------------------------------------
	 3	    1		    200 	 1	    6 INACTIVE
ONLINE
/u01/app/oracle/oradata/ORCL/redo03.log

	 2	    1		    200 	 1	    8 CURRENT
ONLINE
/u01/app/oracle/oradata/ORCL/redo02.log

    GROUP#    THREAD# A.BYTES/1024/1024    MEMBERS  SEQUENCE# STATUS
---------- ---------- ----------------- ---------- ---------- ----------------
TYPE
-------
MEMBER
--------------------------------------------------------------------------------

	 1	    1		    200 	 1	    7 INACTIVE
ONLINE
/u01/app/oracle/oradata/ORCL/redo01.log


SQL> ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 4 ('/u01/app/oracle/oradata/ORCL/standby_redo04.log') SIZE 200M;
     ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 5 ('/u01/app/oracle/oradata/ORCL/standby_redo05.log') SIZE 200M;
     ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 6 ('/u01/app/oracle/oradata/ORCL/standby_redo06.log') SIZE 200M;

Database altered.

SQL> SQL> 
Database altered.

SQL> SQL> 
Database altered.

SQL> SQL> SQL> 
SQL>  ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO scope=both;
System altered.

SQL> show parameter db_name;
NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
db_name 			     string	 orcl
SQL> 