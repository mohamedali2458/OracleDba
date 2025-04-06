export ORACLE_PDB_SID=PDB1

[oracle@srv1 admin]$ env|grep ORA
ORACLE_PDB_SID=PDB1
ORACLE_SID=oradb
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/19.0.0/db_1

sqlplus / as sysdba

SYS @ oradb > show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         3 PDB1                           READ WRITE NO
SYS @ oradb > show con_name

CON_NAME
------------------------------
PDB1



[oracle@srv1 admin]$ unset ORACLE_PDB_SID
[oracle@srv1 admin]$ env|grep ORA
ORACLE_SID=oradb
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/19.0.0/db_1
