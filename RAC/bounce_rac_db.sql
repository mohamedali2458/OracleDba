Bounce RAC database?
====================
Generally asked question on RAC database: 
How to bounce my RAC database and 
How to configure my RAC database cluster setting. 
We more often perform bounce RAC database for 
patching or any configuration change or any maintenance activity. 

Here are the basic RAC database maintenance & administration commands:

RAC environmental details:
==========================
hostnode1 - +ASM1 & DEVDB1 
hostnode2 - +ASM2 & DEVDB2

Database Level:
===============
Check the RAC database status
srvctl status database -d DEVDB

Check the stop/shutdown database status
srvctl stop database -d DEVDB

Check the start database status
srvctl start database -d DEVDB

Instance Level:
===============
Check the RAC database instance from any cluster nodes
srvctl status instance -i DEVDB1 -d DEVDB
srvctl status instance -i DEVDB2 -d DEVDB

Shutdown RAC database instance from any cluster nodes
srvctl stop instance -i DEVDB1 -d DEVDB
srvctl stop instance -i DEVDB2 -d DEVDB

Start RAC database instance from any cluster nodes
srvctl start instance -i DEVDB1 -d DEVDB
srvctl start instance -i DEVDB2 -d DEVDB

RAC Cluster setting:
====================
Check the RAC Database Configuration
srvctl config database -d DEVDB

Modify the RAC database configuration
Example: 
srvctl modify database -d DEVDB -spfile +DATA/DEVDB/PARAMETERFILE/spfile.268.1174295839
srvctl modify database -d DEVDB -pwfile +DATA/DEVDB/PASSWORD/pwddevdb.256.1174295393
