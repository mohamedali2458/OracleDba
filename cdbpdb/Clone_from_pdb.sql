
CREATE NEW PDB BY CLONING AN EXISTING PDB - testing
=========================================
create pluggable database pdb2 from pdb1 storage unlimited tempfile reuse file_name_convert=('PDB1','PDB3');

1. Pre-requisites

SQL> select name,open_mode,con_id from v$database;

NAME      OPEN_MODE                CON_ID
--------- -------------------- ----------
ORADB     READ WRITE                    0

SQL> show con_name
CON_NAME
------------------------------
CDB$ROOT

SYS @ oradb > show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO


SYS @ oradb > col name for a60
SYS @ oradb > select name from v$datafile where con_id=3;
NAME
------------------------------------------------------------
/u01/app/oracle/oradata/ORADB/pdb1/system01.dbf
/u01/app/oracle/oradata/ORADB/pdb1/sysaux01.dbf
/u01/app/oracle/oradata/ORADB/pdb1/undotbs01.dbf
/u01/app/oracle/oradata/ORADB/pdb1/users01.dbf


SYS @ oradb > select name from v$tempfile where con_id=3;
NAME
------------------------------------------------------------
/u01/app/oracle/oradata/ORADB/pdb1/temp01.dbf


2. Close existing PLUGGABLE DATABASE PDB1

SYS @ oradb > show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO

SYS @ oradb > alter pluggable database PDB1 close immediate;
Pluggable database altered.

SYS @ oradb > show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           MOUNTED

3. Open existing PLUGGABLE DATABASE PDB1 in Read-Only

SYS @ oradb > alter pluggable database PDB1 open read only;
Pluggable database altered.

SYS @ oradb > show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ ONLY  NO

4. Create new directory at OS level

SQL> !mkdir -p /u01/app/oracle/oradata/ORADB/pdb2

5. CREATE NEW PDB (PDB2) BY CLONING AN EXISTING PDB (PDB1)

SQL> 
CREATE PLUGGABLE DATABASE PDB2 FROM PDB1
FILE_NAME_CONVERT=('/u01/app/oracle/oradata/ORADB/PDB1','/u01/app/oracle/oradata/ORADB/PDB2/');

Pluggable database created.  

SQL>
SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ ONLY  NO
         4 PDB2                           MOUNTED  <-----

SQL> 

6. OPEN NEW PLUGGABLE DATABASE PDB2

SQL> alter pluggable database PDB2 open;

Pluggable database altered.

SQL>

7. Close existing PLUGGABLE DATABASE PDB1 FROM RO MODE

SQL> alter pluggable database PDB1 close immediate;

Pluggable database altered.

SQL>

8. Open existing PLUGGABLE DATABASE PDB1 in RW MODE

SQL> alter pluggable database PDB1 open;

Pluggable database altered.

SQL> 

9. Verification

SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO  
         4 PDB2                           READ WRITE NO  <----
		 
SQL> select name from v$datafile where con_id=4;

NAME
------------------------------------------------------------
/home/oracle/oradata/PDB2/system01.dbf
/home/oracle/oradata/PDB2/sysaux01.dbf
/home/oracle/oradata/PDB2/undotbs01.dbf
/home/oracle/oradata/PDB2/pdb1_users01.dbf

SQL> select name from v$tempfile where con_id=4;

NAME
------------------------------------------------------------
/home/oracle/oradata/PDB2/temp01.dbf

SQL>
