--Addnode
=========
oracleasm scandisks
oracleasm listdisks

as root user 
source grid.env
crsctl stat res -t 
crsctl stat res -t | grep db1 
crsctl stat res -t | grep db2
crsctl stat res -t | grep db3 
(should be no result)

on node3
ps -ef | grep pmon 
cd /dbi/oracle/V19Grid; pwd; ls -l 
(no result in db3 but 1,2 there are files)
(here both grid home and oracle home)


node/host	private_Ip	    Public_ip	    Virtual_ip
db1		    192.168.0.101	192.168.1.101	192.168.1.111
db2		    192.168.0.102	192.168.1.102	192.168.1.112
db3		    192.168.0.103	192.168.1.103	192.168.1.113


scan_ip		192.168.1.121
			192.168.1.122
			192.168.1.123
				
--as root user
vi /etc/hosts
when adding a 3rd node, we need to update /etc/hosts 
file with public ip, private ip and virtual ip

/etc/hosts must be same in all 3 nodes, so add db3 info in all 3

Setup passwordless ssh between Grid and Oracle users

Install cvuqdisk on third Node (db3)

As root user 

on node 1(db1):

cd /dbi/oracle/V19Grid/cv/rpm
scp cvuqdisk-1.0.10-1.rpm:/tmp

on node 3 (db3)

cd /tmp 
CVUQDISK_GRP=dba; export CVUQDISK_GRP
rpm -i cvuqdisk-1.0.10-1.rpm 


Verify Cluster node is ready to join the cluster 
As grid user on db1 
cluvfy stage -pre nodeadd -n db3 


Part 2: Extend Grid Home

As grid user on any one of the existing nodes (db1 or db2)

. oraenv 
ORACLE_SID = +ASM1

olsnodes -n -s 

cd $ORACLE_HOME/addnode 
pwd; ls -l 

. /addnode.sh -silent "CLUSTER_NEW_NODES=db3" "CLUSTER_NEW_VIRTUAL_HOSTNAMES=db3-vip" -ignorePrereq

As root on newly added node (db3)

/dbi/oracle/oraInventory/orainstRoot.sh
/dbi/oracle/V19Grid/root.sh 

to pmon process appearance:
ps -ef | grep pmon 
watch 'ps -ef | grep pmon'


Optionally:
cluvfy stage -post nodeadd -n db3 

Add entry in /etc/oratab 
+ASM3:/dbi/oracle/V19Grid:Y


Part 3: Extend Database Home 

As Oracle user on any one of the existing nodes (db1 or db2)

. oraenv
ORACLE_SID = ora19c1

cd $ORACLE_HOME/addnode 
pwd; ls -l

./addnode.sh -silent "CLUSTER_NEW_NODES=db3" -ignorePrereq

As root on newly added node (db3)
/dbi/oracle/V19Oracle/root.sh 


Part 4: Add Instance 

As oracle user on any one of the existing nodes (db1 or db2)

. oraenv
ORACLE_SID = ora19c1 

cd $ORACLE_HOME/bin 
pwd 

./dbca -silent -addInstance -gdbName ora19c -nodeName db3 


to verify :

SET LINESIZE 32000;
SET PAGESIZE 40000;
SET LONG     50000;

COL instance_name	FOR	A10;
COL host_name		FOR A20;
COL name			FOR A10;
COL status			FOR A10;
COL open_mode		FOR A10;
COL startup_time	FOR A20;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';

SELECT distinct instance_name, host_name, status, name, open_mode, startup_time 
FROM gv$database, gv$instance
ORDER BY instance_name;





https://www.youtube.com/watch?v=eePF-5mDAug
24 min