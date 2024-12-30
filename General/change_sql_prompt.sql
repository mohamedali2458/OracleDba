How to change SQL  prompt to show connected user and database name

cd $ORACLE_HOME/sqlplus/admin

[oracle@srv1 admin]$ pwd
/u01/app/oracle/product/19.0.0/db_1/sqlplus/admin

[oracle@srv1 admin]$ ls -ltr
total 20
-rw-r--r--. 1 oracle oinstall  342 Jan 13  2006 glogin.sql
-rw-r--r--. 1 oracle oinstall  813 Mar  7  2006 plustrce.sql
-rw-r--r--. 1 oracle oinstall  226 Apr 29  2015 libsqlplus.def
-rw-r--r--. 1 oracle oinstall 1333 Mar 16  2017 pupdel.sql
-rw-r--r--. 1 oracle oinstall 3035 Mar 16  2017 pupbld.sql
drwxr-xr-x. 2 oracle oinstall   81 Apr 17  2019 help

[oracle@srv1 admin]$ cat glogin.sql
--
-- Copyright (c) 1988, 2005, Oracle.  All Rights Reserved.
--
-- NAME
--   glogin.sql
--
-- DESCRIPTION
--   SQL*Plus global login "site profile" file
--
--   Add any SQL*Plus commands here that are to be executed when a
--   user starts SQL*Plus, or uses the SQL*Plus CONNECT command.
--
-- USAGE
--   This script is automatically run
--

vi glogin.sql
set sqlprompt "_user '@' _connect_identifier > "


[oracle@srv1 admin]$ cat glogin.sql
--
-- Copyright (c) 1988, 2005, Oracle.  All Rights Reserved.
--
-- NAME
--   glogin.sql
--
-- DESCRIPTION
--   SQL*Plus global login "site profile" file
--
--   Add any SQL*Plus commands here that are to be executed when a
--   user starts SQL*Plus, or uses the SQL*Plus CONNECT command.
--
-- USAGE
--   This script is automatically run
--
set sqlprompt "_user '@' _connect_identifier > "


[oracle@srv1 ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Dec 30 19:34:01 2024
Version 19.8.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.8.0.0.0

SYS @ oradb >


SYS @ oradb > select name,open_mode from v$database;

NAME      OPEN_MODE
--------- --------------------
ORADB     READ WRITE

SYS @ oradb > show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO


SYS @ oradb > connect sys@pdb1 as sysdba
Enter password:
Connected.
SYS @ pdb1 > show con_name

CON_NAME
------------------------------
PDB1
SYS @ pdb1 >


