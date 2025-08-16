SRVCTL and CRSCTL Tool
======================

https://www.youtube.com/watch?v=AI8uM9mjgeE&list=PLeuOyCXQUMxchd4p8eNBxHQ3QvwaWSIFi

What is SRVCTL and CRSCTL tool?
Global Dynamic Performance View
SQL with Global Dynamic Performance view - Practical
SRVCTL Command - Practical
CRSCTL Command - Practical
SRVCTL RAC Administration Basic Activity - Practical
CRSCTL RAC Administration Basic Activity - Practical

What is SRVCTL and CRSCTL tool?

CRSCTL stands for Clusterware Control. 

CRSCTL provides cluster-ware commands which are basically
to perform check, start and stop operations on the cluster.

These commands can be run from any node in the cluster, 
or on all nodes in the cluster, depending on the operations. 

You can perform following operations on Oracle Clusterware
using CRSCTL commands:
 - Starting and stopping Oracle Clusterware resources
 - Enabling and disabling Oracle Clusterware daemons
 - Checking the health of the cluster

SRVCTL stands for Server Control.

It basically manages various components and applications
in your cluster like database, instances, listeners
and services. 

Oracle strongly discourages directly manipulating 
Oracle-Supplied resources (resources whose names
begin with ora) using CRSCTL. This could adversely
impact the cluster configuration. 

If resource name begins with ora then use SRVCTL. 


Global Dynamic Performance View

Dynamic Performance View (V$) contains database
statistics and its basically used for performance
monitoring and DB tuning activity. 

In Oracle RAC environment, a global (GV$) view
corresponds to each V$ view.

V$ views contain statistics for one instance,
whereas GV$ views contains information from all
the active instances. 

Each GV$ view contains an INST_ID column of type 
NUMBER, which can be used to identify the instance 
associated with the data. 

SQL with Global Dynamic Performance view (Practical)

Get Instance Information

Connect to Node 1 DB Instance with SYSDBA

column host_name for a30
select instance_name, host_name, status from gv$instance;

select instance_name, host_name, status from v$instance;


Connect to Node 2 DB Instance with SYSDBA. 

. oraenv
dev2

sqlplus / as sysdba
column host_name for a30
select instance_name, host_name, status from gv$instance;

select instance_name, host_name, status from v$instance;


Get SGA Information
SQL> show parameter sga_

Get DataFiles Information

set linesize 200
column tablespace_name format a20
column file_name format a40
select tablespace_name, file_name, bytes/1024/1024 "Mb"
from dba_data_files;

There will be 2 undo tablespaces for 2 nodes. 

show parameter undo_tablespace;

run this command in both the nodes. 


Logfiles Information
====================
set linesize 200
column member format a40
select group#, type, member from v$logfile order by group#;

select distinct group#, thread# from gv$log 
order by group#,thread#;

show parameter thread;
(this value is different in each node)



ASM Information - Node 1 / Node 2
=================================
. oraenv
+ASM1

sqlplus / as sysasm

col name for a30
select group_number, name, state from v$asm_diskgroup;

column path format a40
select name, path from v$asm_disk;

select group_number, file_number, bytes/1024/1024/1024 "Gb"
from v$asm_file;

SRVCTL Command on Node 1 / Node 2
=================================
. oraenv

dev1

srvctl status database -d dev 

srvctl status database -d dev -v

srvctl status instance -d dev -i dev1 -v

srvctl status instance -d dev -i dev2 -v

srvctl status nodeapps

srvctl status diskgroup -g DATA -a

srvctl status listener

srvctl status scan_listener

srvctl status asm 

CRSCTL Command on Node 1 / Node 2
=================================
. oraenv

+ASM1

crsctl -h

crsctl status resource -t
crsctl stat res -t

crsctl check crs 

crsctl check cluster

crsctl check cluster -all

crsctl query css votedisk

crsctl getif
oifcfg getif

The crsctl getif command does not exist. 
The command to get network interface information 
in an Oracle Clusterware environment is oifcfg getif.

The Oracle Interface Configuration Tool (OIFCFG) 
is a utility used in Oracle Clusterware to manage 
and configure network interfaces for cluster 
components like public networks, the private 
cluster interconnect, and Oracle ASM.

The oifcfg getif command is used to display 
the interfaces for which an interface type 
has been defined. This is a very useful 
command to verify your network configuration 
after installing or modifying Oracle Clusterware.


SRVCTL RAC Administration Basic Activity
========================================
Bring Down Instance 2
srvctl stop instance -d dev -i dev2

to confirm
crsctl stat res -t
(look for ora.racdb)

Bring Up Instance 2
srvctl start instance -d dev -i dev2

to confirm
crsctl stat res -t

srvctl status database -d dev -v

Bring Down Instance 2 in abort mode
srvctl stop instance -d dev -i dev2 -o abort

Bring up Instance 2 in mount mode
srvctl start instance -d dev -i dev2 -o mount (nomount also)

srvctl status database -d dev -v

sqlplus / as sysdba

alter database open;

srvctl status database -d dev -v


CRSCTL RAC Administration Basic Activity
========================================
Stop Clusterware services on Node 1
su - 
. oraenv
+ASM1

crsctl stop cluster

Monitor Node 2
crsctl status resource -t
(if scan is working on node1 it will move to node 2)
(all services node1 status showing as stopping)

crsctl check cluster
crsctl check cluster -all

Start Clusterware services on Node 1
====================================
crsctl start cluster

Monitor Node 1/2
crsctl stat res -t

crsctl start cluster
