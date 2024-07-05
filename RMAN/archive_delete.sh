#!/bin/bash
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export ORACLE_SID=yourSID
export PATH=$ORACLE_HOME/bin:$PATH

rman target sys/password@standby_db <<EOF
CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-3' BACKED UP 1 TIMES TO DEVICE TYPE DISK;
EOF



0 1 * * * /u01/app/oracle/scripts/cleanup_archivelogs.sh >> /u01/app/oracle/scripts/logs/cleanup_archivelogs.log 2>&1
