All_file_location_info
======================
System Parameter File:------
SQL> show parameter spfile
NAME   TYPE   VALUE
spfile string /u01/app/oracle/product/19.0.0

/dbhome_1/dbs/spfileprod.ora

[oracle@localhost ~]$ cd /u01/app/oracle/product/19.0.0/dbhome_1/dbs/

[oracle@localhost dbs]$ ll
total 18328
-rw-rw----. 1 oracle oinstall 1544 Jan 18 03:00 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14 2015 init.ora
-rw-r-----. 1 oracle oinstall 24 Aug 17 13:47 lkPROD
-rw-r-----. 1 oracle oinstall 2048 Aug 17 13:50 orapwprod
-rw-r-----. 1 oracle oinstall 3584 Jan 18 03:00 spfileprod.ora

SQL> create pfile from spfile;
File created.

[oracle@localhost ~]$ cd /u01/app/oracle/product/19.0.0/dbhome_1/dbs/

[oracle@localhost dbs]$ ll

total 18328
-rw-rw----. 1 oracle oinstall 1544 Jan 18 03:00 hc_prod.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14 2015 init.ora
-rw-r--r--. 1 oracle oinstall 1113 Jan 18 03:17 initprod.ora
-rw-r-----. 1 oracle oinstall 24 Aug 17 13:47 lkPROD
-rw-r-----. 1 oracle oinstall 2048 Aug 17 13:50 orapwprod
-rw-r-----. 1 oracle oinstall 3584 Jan 18 03:00 spfileprod.ora

[oracle@localhost dbs]$ cat initprod.ora

prod.__data_transfer_cache_size=0
prod.__db_cache_size=889192448
prod.__inmemory_ext_roarea=0
prod.__inmemory_ext_rwarea=0
prod.__java_pool_size=0
prod.__large_pool_size=16777216
prod.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
prod.__pga_aggregate_target=436207616
prod.__sga_target=1308622848
prod.__shared_io_pool_size=67108864
prod.__shared_pool_size=318767104
prod.__streams_pool_size=0
prod.__unified_pga_pool_size=0
*.audit_file_dest='/u01/app/oracle/admin/prod/adump'
*.audit_trail='db'
*.compatible='19.0.0'
*.control_files='/u01/app/oracle/oradata/PROD/control01.ctl','/u01/app/oracle/fast_recovery_area/PROD/control02.ctl'
*.db_block_size=8192
*.db_name='prod'
*.db_recovery_file_dest='/u01/app/oracle/fast_recovery_area'
*.db_recovery_file_dest_size=8256m
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=prodXDB)'
*.log_archive_format='%t_%s_%r.dbf'
*.nls_language='AMERICAN'
*.nls_territory='AMERICA'
*.open_cursors=300
*.pga_aggregate_target=415m
*.processes=300
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=1242m
*.undo_tablespace='UNDOTBS1'


DATFILE :-----------
SQL> select name from v$datafile;
NAME
--------------------------------------------------------------------------------
/u01/app/oracle/oradata/PROD/system01.dbf
/u01/app/oracle/oradata/PROD/sysaux01.dbf
/u01/app/oracle/oradata/PROD/undotbs01.dbf
/u01/app/oracle/oradata/PROD/users01.dbf

SQL> select name from v$tempfile;
NAME
--------------------------------------------------------------------------------
/u01/app/oracle/oradata/PROD/temp01.dbf

SQL> select * from v$logfile;

  **GROUP# STATUS TYPE**

---------- ------- -------
MEMBER

--------------------------------------------------------------------------------
IS_ CON_ID

--- ----------

 **3 ONLINE**

/u01/app/oracle/oradata/PROD/redo03.log

NO 0

 **2 ONLINE**

/u01/app/oracle/oradata/PROD/redo02.log

NO 0

  **GROUP# STATUS TYPE**

---------- ------- -------

MEMBER

--------------------------------------------------------------------------------

IS_ CON_ID

--- ----------

 **1 ONLINE**

/u01/app/oracle/oradata/PROD/redo01.log

NO 0


SQL> col MEMBER for a50
SQL> set line 200 pages 200

SQL> /

  **GROUP# STATUS TYPE MEMBER IS\_ CON\_ID**

---------- ------- ------- -------------------------------------------------- --- ----------
 **3 ONLINE /u01/app/oracle/oradata/PROD/redo03.log NO 0**
 \*\*2 ONLINE /u01/app/oracle/oradata/PROD/redo02.log NO 0\*\*
 \\\*\\\*1	   ONLINE  /u01/app/oracle/oradata/PROD/redo01.log	      NO	   0\\\*\\\*


[oracle@localhost ~]$ cd /u01/app/oracle/oradata/PROD/

[oracle@localhost PROD]$ ll
total 2453700
-rw-r-----. 1 oracle oinstall 10600448 Jan 18 03:39 control01.ctl
-rw-r-----. 1 oracle oinstall 209715712 Jan 18 03:39 redo01.log
-rw-r-----. 1 oracle oinstall 209715712 Jan 18 03:32 redo02.log
-rw-r-----. 1 oracle oinstall 209715712 Jan 18 03:32 redo03.log
-rw-r-----. 1 oracle oinstall 576724992 Jan 18 03:37 sysaux01.dbf
-rw-r-----. 1 oracle oinstall 943726592 Jan 18 03:37 system01.dbf
-rw-r-----. 1 oracle oinstall 33562624 Aug 25 01:45 temp01.dbf
-rw-r-----. 1 oracle oinstall 346038272 Jan 18 03:37 undotbs01.dbf
-rw-r-----. 1 oracle oinstall 5251072 Jan 18 03:32 users01.dbf

SQL> select * from v$controlfile;
STATUS NAME IS_ BLOCK_SIZE FILE_SIZE_BLKS CON_ID
------- ----------------------------------------------------- --- ---------- -------------- ----------
**/u01/app/oracle/oradata/PROD/control01.ctl NO 16384 646 0**
\*\*/u01/app/oracle/fast\\\_recovery\\\_area/PROD/control02.ctl NO 16384 646 0\*\*

[oracle@localhost ~]$ cd /u01/app/oracle/oradata/PROD/

[oracle@localhost PROD]$ ll
total 2453700
-rw-r-----. 1 oracle oinstall 10600448 Jan 18 03:39 control01.ctl
-rw-r-----. 1 oracle oinstall 209715712 Jan 18 03:39 redo01.log
-rw-r-----. 1 oracle oinstall 209715712 Jan 18 03:32 redo02.log
-rw-r-----. 1 oracle oinstall 209715712 Jan 18 03:32 redo03.log
-rw-r-----. 1 oracle oinstall 576724992 Jan 18 03:37 sysaux01.dbf
-rw-r-----. 1 oracle oinstall 943726592 Jan 18 03:37 system01.dbf
-rw-r-----. 1 oracle oinstall 33562624 Aug 25 01:45 temp01.dbf
-rw-r-----. 1 oracle oinstall 346038272 Jan 18 03:37 undotbs01.dbf
-rw-r-----. 1 oracle oinstall 5251072 Jan 18 03:32 users01.dbf

[oracle@localhost PROD]$ cd /u01/app/oracle/fast_recovery_area/PROD/

[oracle@localhost PROD]$ ll
total 10352
drwxr-x---. 6 oracle oinstall 78 Jan 18 03:00 archivelog
-rw-r-----. 1 oracle oinstall 10600448 Jan 18 03:52 control02.ctl
drwxr-x---. 2 oracle oinstall 6 Aug 17 13:50 onlinelog


PASSWORD FILE:-------
SQL> select * from v$pwfile_users;

SQL> col USERNAME for a10
SQL> col PASSWORD_PROFILE for a20
SQL> col LAST_LOGIN for a14
SQL> col EXTERNAL_NAME for a20
SQL> /

USERNAME SYSDB SYSOP SYSAS SYSBA SYSDG SYSKM ACCOUNT_STATUS PASSWORD_PROFILE LAST_LOGIN LOCK_DATE EXPIRY_DA EXTERNAL_NAME AUTHENTI COM CON_ID

---------- ----- ----- ----- ----- ----- ----- -------------- ---------------- ---------- --------- --------- ------------- -------- --- -------

SYS TRUE TRUE FALSE FALSE FALSE FALSE OPEN PASSWORD NO 0

{CHECK PWSSWORD FILE MISING OR NOT}

[oracle@localhost dbs]$ pwd

/u01/app/oracle/product/19.0.0/dbhome_1/dbs

[oracle@localhost dbs]$ ll
total 18348
-rw-rw----. 1 oracle oinstall 1544 Jan 18 02:55 hc_orcl.dat
-rw-rw----. 1 oracle oinstall 1544 Jan 18 04:08 hc_prod.dat
-rw-rw----. 1 oracle oinstall 1544 Jan 18 03:30 hc_sha.dat
-rw-r--r--. 1 oracle oinstall 3079 May 14 2015 init.ora
-rw-r--r--. 1 oracle oinstall 1129 Jan 19 2026 initorcl.ora
-rw-r--r--. 1 oracle oinstall 1113 Jan 18 03:17 initprod.ora
-rw-r-----. 1 oracle oinstall 24 Aug 3 14:14 lkORCL
-rw-r-----. 1 oracle oinstall 24 Aug 17 13:47 lkPROD
-rw-r-----. 1 oracle oinstall 24 Jan 18 03:31 lkSHA
-rw-r-----. 1 oracle oinstall 2048 Aug 3 14:18 orapworcl
-rw-r-----. 1 oracle oinstall 2048 Aug 17 13:50 orapwprod
-rw-r-----. 1 oracle oinstall 2048 Jan 18 03:36 orapwsha
-rw-r-----. 1 oracle oinstall 18726912 Aug 3 15:11 snapcf_orcl.f
-rw-r-----. 1 oracle oinstall 3584 Jan 18 02:55 spfileorcl.ora
-rw-r-----. 1 oracle oinstall 3584 Jan 18 04:07 spfileprod.ora
-rw-r-----. 1 oracle oinstall 3584 Jan 18 03:18 spfilesha.ora

[oracle@localhost dbs]$ . oraenv

ORACLE_SID = [oracle] ? sha

The Oracle base has been set to /u01/app/oracle

[oracle@localhost dbs]$ orapwd file=orapwsha password=sha entries=5 force=y {CREATE PASSWORD FILE}

OPW-00029: Password complexity failed for SYS user : Password must contain at least 8 characters.