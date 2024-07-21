login to root
#ps -eaf|grep smon

check any db available ?
cat /etc/oratab

su - oracle
clear

. oraenv
dev1


SQL> startup

select open_mode from v$database;

select instance_name, status from gv$instance;
exit

ssh oracle@rac2

. oraenv
dev2

sqlplus "/ as sysdba"
startup;
select instance_name, status from gv$instance;

shutdown
========
rac2

shutdown immediate;
exit

ps -eaf|grep smon


now what is the status of the cluster ?

$srvctl status database -d dev

we use srvctl to manage db and instance

at rac1 
sqlplus "/ as sysdba"
shutdown immediate;

exit

srvctl status database -d dev

srvctl start database -d dev

srvctl status database -d dev

it will be running on both the nodes

srvctl stop database -d dev

srvctl status database -d dev





Steps for connecting to a RAC database using SCAN Name 
======================================================
ps -eaf|grep smon

dev1 is running

. oraenv
dev1
home

sqlplus "/ as sysdba"

select name,db_unique_name,database_role,open_mode from v$database;

select instance_name,status from gv$instance;

select instance_name,host_name,startup_time from gv$instance;

exit

when we set oraenv then its asking oracle home. 
the reason is when we create a db using dbca it creates an entry in oratab for db not for instance.
to avoid this, with db we must add another line for instance.

vi /etc/oratab
yy - to copy the db line
and press 'p' to paste the same in the next line
:wq
do this with dev2 in rac2 machine


when using . oraenv we always must give instance name in rac.

when we install rac by default a tnsname with dbname will be created.

tnsping dev

we can check this on both the machines


rac1
====
sqlplus system/manager@dev

select instance_name from v$instance;
HOST_NAME
----------------------------------------------------------------
rac2.tzone.com


its showing dev2

when we say cat $ORACLE_HOME/network/admin/tnsnames.ora
here we can see hostname = 'rac-scan'

this is because scan listener connects to random instance based on load at that time.

when we use scan we are not sure where it will get connected.

exit

cd $ORACLE_HOME/network/admin/

ls -altr 

vi tnsnames.ora

8yy
p 
to copy and paste the tnsname DEV entry to another one
remove rac-scan and enter rac1-vip
change the tnsname 'dev' to dev1 so that we can connect to rac1 machine

tnsping dev1

sqlplus system/manager@dev1

select instance_name from v$instance;
dev1


10g type vip connection
=======================
vi tnsnames.ora

8yy 
p
name = dev10g
copy and paste the vip line
use 2nd vip 

tnsnames looks like this
========================
DEV10g =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac1-vip)(PORT = 1521))
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac2-vip)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = dev)
    )
  )

  
  
  
Full file code
==============
DEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = dev)
    )
  )

DEV1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac1-vip)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = dev)
    )
  )

DEV10g =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac1-vip)(PORT = 1521))
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac2-vip)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = dev)
    )
  )



sqlplus system/manager@dev10g
show dev1

basically when the first instance is available it will connect there.

in this way in 10g we mention all the hostnames

instead of that the same thing is replaced with scan entry.


If we use scan listener by default load balance will happen.
oracle will distribute the user connections based on the load.

SCAN is there from 11gR2 onwards.

In 10gR1,10gR2 and 11gR1 we don't have the scan listener concept.

in 10g and 11gR1 we must follow the dev10g type of entries.





SRVCTL commands in Oracle RAC 
-----------------------------
srvctl = Server Control Utility

syntax= srvctl command target [options]

srvctl -help
srvctl -v 

srvctl -V
prints the version


srvctl database related commands
--------------------------------
srvctl add database -d db_name -o ORACLE_HOME 
srvctl add database -d prod -o /u01/oracle/product/102/prod 

srvctl remove database -d db_name [-f]
srvctl remove database -d prod

srvctl start database -d db_name [-o start_options] [-c connect_str|-q]
srvctl start database -d db_name [-o open]
srvctl start database -d db_name -o nomount
srvctl start database -d db_name -o mount

srvctl start db -d prod
srvctl start database -d apps -o open

srvctl stop database -d db_name [-o stop_options] [-c connect_str|-q]
srvctl stop database -d db_name [-o normal]
srvctl stop database -d db_name -o transactional
srvctl stop database -d db_name -o immediate
srvctl stop database -d db_name -o abort
srvctl stop db -d prod -o immediate


srvctl status database -d db_name [-f] [-v] [-S level]
srvctl status database -d db_name -v service_name
srvctl status database -d hrms

srvctl enable database -d db_name
srvctl enable database -d prod 

srvctl disable database -d db_name
srvctl disable db -d prod

srvctl config database -d db_name [-a] [-t]
srvctl config database -d DEV -a
srvctl config database -d DEV

srvctl modify database -d db_name [-n db_name] [-o ORACLE_HOME] [-m domain_name] [-p spfile]
[-r {PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY}] [-s start_options] [-y {AUTOMATIC|MANUAL}]

srvctl modify database -d hrms -r physical_standby
srvctl modify db -d RAC -p /u03/oradata/RAC/spfileRAC.ora -- moves p file
srvctl modify database –d HYD –o /u01/app/oracle/product/11.1/db –s open

srvctl getenv database -d db_name [-t name_list]
srvctl getenv database -d prod

srvctl setenv database -d db_name {-t name=val[,name=val,...]|-T name=val}
srvctl setenv database –d HYD –t “TNS_ADMIN=/u01/app/oracle/product/11.1/asm/network/admin”
srvctl setenv db -d prod -t LANG=en

srvctl unsetenv database -d db_name [-t name_list]
srvctl unsetenv database -d prod -t CLASSPATH





11gR2 
-----
srvctl add database -d db_unique_name -o ORACLE_HOME [-x node_name] [-m domain_name] [-p spfile] [-r {PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY}] [-s start_options] [-t stop_options] [-n db_name] [-y {AUTOMATIC|MANUAL}] [-g server_pool_list] [-a "diskgroup_list"]

srvctl add database -d prod -o /u01/oracle/product/112/prod -m foo.com -p +dg1/prod/spfileprod.ora -r PRIMARY -s open -t normal -n db2 -y AUTOMATIC -g svrpool1,svrpool2 -a "dg1,dg2"



srvctl remove database -d db_unique_name [-f] [-y] [-v]
srvctl remove database -d dev -y

srvctl stop database -d db_unique_name [-o stop_options] [-f]
srvctl stop database -d dev -f

srvctl status database -d db_unique_name [-f] [-v]
srvctl status db -d dev -v

srvctl enable database -d db_unique_name [-n node_name]
srvctl enable database -d dev -n rac1

srvctl disable database -d db_unique_name [-n node_name]
srvctl disable db -d dev -n rac2

srvctl config database [-d db_unique_name [-a]]
srvctl config db -d dev -a




srvctl modify database -d db_unique_name [-n db_name] [-o ORACLE_HOME] [-u oracle_user] [-m domain] [-p spfile] [-r {PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY}] [-s start_options] [-t stop_options] [-y {AUTOMATIC|MANUAL}] [-g "server_pool_list"] [-a "diskgroup_list"|-z]

srvctl modify db -d prod -r logical_standby
srvctl modify database -d racTest -a "SYSFILES,LOGS,OLTP"
srvctl modify database -d ronedb -e rac1,rac2 

srvctl relocate database -d db_unique_name {[-n target_node] [-w timeout] | -a [-r]} [-v]
srvctl relocate database -d rontest -n node2 
srvctl relocate database -d rone2db -n lnxrac2 -w 120 -v 


srvctl convert database -d ....

srvctl convert database -d ronedb -c RAC -n rac1 
srvctl convert database -d ronedb -c RACONENODE -i RoneDB




Instance
--------
srvctl add instance –d db_name –i inst_name -n node_name
srvctl add instance -d prod -i prod01 -n linux01


srvctl remove instance –d db_name –i inst_name [-f]

srvctl remove instance -d prod -i prod01


srvctl start instance -d db_name -i inst_names [-o start_options] [-c connect_str|-q]

srvctl start instance –d db_name –i inst_names [-o open]

srvctl start instance –d db_name –i inst_names -o nomount

srvctl start instance –d db_name –i inst_names -o mount

srvctl start instance –d dev -i dev2


srvctl stop instance -d db_name -i inst_names [-o stop_options] [-c connect_str|-q]

srvctl stop instance –d db_name –i inst_names [-o normal]

srvctl stop instance –d db_name –i inst_names -o transactional

srvctl stop instance –d db_name –i inst_names -o immediate

srvctl stop instance –d db_name –i inst_names -o abort

srvctl stop inst –d vis -i vis


srvctl status instance –d db_name –i inst_names [-f] [-v] [-S level]

srvctl status inst –d racdb -i racdb2


srvctl enable instance –d db_name –i inst_names
srvctl enable instance -d prod -i "prod1,prod2"


srvctl disable instance –d db_name –i inst_names
srvctl disable inst -d prod -i "prod1,prod3"

srvctl modify instance -d db_name -i inst_name {-s asm_inst_name|-r} -- set dependency of instance to ASM
srvctl modify instance -d db_name -i inst_name -n node_name -- move the instance
srvctl modify instance -d db_name -i inst_name -r -- remove the instance

srvctl getenv instance –d db_name –i inst_name [-t name_list]
srvctl setenv instance –d db_name [–i inst_name] {-t "name=val[,name=val,...]" | -T "name=val"}
srvctl unsetenv instance –d db_name [–i inst_name] [-t name_list]



In 11g Release 2, some command's syntax has been changed:
========================================================
srvctl start instance -d db_unique_name {-n node_name -i "instance_name_list"} [-o start_options]

srvctl start instance -d prod -n node2
srvctl start inst -d prod -i "prod2,prod3"

srvctl stop instance -d db_unique_name {[-n node_name]|[-i "instance_name_list"]} [-o stop_options] [-f]

srvctl stop inst -d prod -n node1
srvctl stop instance -d prod -i prod1

srvctl status instance -d db_unique_name {-n node_name | -i "instance_name_list"} [-f] [-v]
srvctl status instance -d prod -i "prod1,prod2" -v

srvctl modify instance -d db_unique_name -i instance_name {-n node_name|-z}
srvctl modify instance -d prod -i prod1 -n mynode
srvctl modify inst -d prod -i prod1 -z




service 
=======

srvctl add service -d db_unique_name -s service_name [-l [PRIMARY][,PHYSICAL_STANDBY][,LOGICAL_STANDBY][,SNAPSHOT_STANDBY]] [-y {AUTOMATIC|MANUAL}] [-q {true|false}] [-j {SHORT|LONG}] [-B {NONE|SERVICE_TIME|THROUGHPUT}][-e {NONE|SESSION|SELECT}] [-m {NONE|BASIC}][-z failover_retries] [-w failover_delay]

srvctl add service -d rac -s rac1 -q TRUE -m BASIC -e SELECT -z 180 -w 5 -j LONG

srvctl add service -d db_unique_name -s service_name -u {-r preferred_list | -a available_list}

srvctl add service -d db_unique_name -s service_name
-g server_pool [-c {UNIFORM|SINGLETON}] [-k network_number]
[-l [PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY]
[-y {AUTOMATIC|MANUAL}] [-q {TRUE|FALSE}] [-j {SHORT|LONG}]
[-B {NONE|SERVICE_TIME|THROUGHPUT}] [-e {NONE|SESSION|SELECT}]
[-m {NONE|BASIC}] [-P {BASIC|NONE|PRECONNECT}] [-x {TRUE|FALSE}]
[-z failover_retries] [-w failover_delay]

srvctl add service -d db_unique_name -s service_name -r preferred_list [-a available_list] [-P {BASIC|NONE|PRECONNECT}]
[-l [PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY]
[-y {AUTOMATIC|MANUAL}] [-q {TRUE|FALSE}] [-j {SHORT|LONG}]
[-B {NONE|SERVICE_TIME|THROUGHPUT}] [-e {NONE|SESSION|SELECT}]
[-m {NONE|BASIC}] [-x {TRUE|FALSE}] [-z failover_retries] [-w failover_delay]

srvctl add serv -d dev -s sales -r dev01,dev02 -a dev03 -P PRECONNECT



srvctl start service -d db_unique_name [-s "service_name_list" [-n node_name | -i instance_name]] [-o start_options]
srvctl start serv -d dev -s dev
srvctl start service -d dev -s dev -i dev2

srvctl stop service -d db_unique_name [-s "service_name_list"] [-n node_name | -i instance_name] [-f]
srvctl stop service -d dev -s dev
srvctl stop serv -d dev -s dev -i dev2

srvctl status service -d db_unique_name [-s "service_name_list"] [-f] [-v]
srvctl status service -d dev -s dev -v

srvctl enable service -d db_unique_name -s "service_name_list" [-i instance_name | -n node_name]
srvctl enable service -d dev -s dev
srvctl enable serv -d dev -s dev -i dev1

srvctl disable service -d db_unique_name -s "service_name_list" [-i instance_name | -n node_name]
srvctl disable service -d dev -s "dev,marketing"
srvctl disable serv -d dev -s dev -i dev1

srvctl config service -d db_unique_name [-s service_name] [-a]
srvctl config service -d dev -s dev


srvctl modify service -d db_unique_name -s service_name
[-c {UNIFORM|SINGLETON}] [-P {BASIC|PRECONNECT|NONE}]
[-l {[PRIMARY]|[PHYSICAL_STANDBY]|[LOGICAL_STANDBY]|[SNAPSHOT_STANDBY]} [-q {TRUE|FALSE}] [-x {TRUE|FALSE}] [-j {SHORT|LONG}] [-B {NONE|SERVICE_TIME|THROUGHPUT}] [-e {NONE|SESSION|SELECT}] [-m {NONE|BASIC}] [-z failover_retries] [-w failover_delay] [-y {AUTOMATIC|MANUAL}]
srvctl modify service -d db_unique_name -s service_name -i old_instance_name -t new_instance_name [-f]
srvctl modify service -d db_unique_name -s service_name -i avail_inst_name -r [-f]
srvctl modify service -d db_unique_name -s service_name -n -i preferred_list [-a available_list] [-f]
srvctl modify service -d dev -s dev -i dev1 -t dev2
srvctl modify serv -d dev -s dev -i dev1 -r
srvctl modify service -d dev -s dev -n -i dev1 -a dev2

srvctl relocate service -d db_unique_name -s service_name {-c source_node -n target_node|-i old_instance_name -t new_instance_name} [-f]
srvctl relocate service -d dev -s dev -i dev1 -t dev3






nodeapps
========
srvctl add nodeapps -n node_name -A {name|ip}/netmask[/if1[|if2|...]] [-m multicast_ip_address] [-p multicast_port_number] [-l ons_local_port] [-r ons_remote-port] [-t host[:port][,host[:port],...]] [-v]
srvctl add nodeapps -S subnet/netmask[/if1[|if2|...]] [-d dhcp_server_type] [-m multicast_ip_address] [-p multicast_port_number] [-l ons_local_port] [-r ons_remote-port] [-t host[:port][,host[:port],...]] [-v]
#srvctl add nodeapps -n devnode1 -A 1.2.3.4/255.255.255.0

srvctl remove nodeapps [-f] [-y] [-v]
srvctl remove nodeapps

srvctl start nodeapps [-n node_name] [-v]
srvctl start nodeapps

srvctl stop nodeapps [-n node_name] [-r] [-v]
srvctl stop nodeapps

srvctl status nodeapps

srvctl enable nodeapps [-g] [-v]
srvctl enable nodeapps -g -v

srvctl disable nodeapps [-g] [-v]
srvctl disable nodeapps -g -v

srvctl config nodeapps [-a] [-g] [-s] [-e]
srvctl config nodeapps -a -g -s -e

srvctl modify nodeapps [-n node_name -A new_vip_address] [-S subnet/netmask[/if1[|if2|...]] [-m multicast_ip_address] [-p multicast_port_number] [-e eons_listen_port] [-l ons_local_port] [-r ons_remote_port] [-t host[:port][,host:port,...]] [-v]
srvctl modify nodeapps -n mynode1 -A 100.200.300.40/255.255.255.0/eth0

srvctl getenv nodeapps [-a] [-g] [-s] [-e] [-t "name_list"] [-v]
srvctl getenv nodeapps -a

srvctl setenv nodeapps {-t "name=val[,name=val][...]" | -T "name=val"} [-v]
srvctl setenv nodeapps -T "CLASSPATH=/usr/local/jdk/jre/rt.jar" -v

srvctl unsetenv nodeapps -t "name_list" [-v]
srvctl unsetenv nodeapps -t "test_var1,test_var2"





ASM
===

srvctl add asm [-l lsnr_name] [-p spfile] [-d asm_diskstring]
srvctl add asm
srvctl add asm -l LISTENERASM -p +dg_data/spfile.ora

srvctl remove asm [-f]
srvctl remove asm -f

srvctl start asm [-n node_name] [-o start_options]
srvctl start asm -n devnode1

srvctl stop asm [-n node_name] [-o stop_options] [-f]
srvctl stop asm -n devnode1 -f

srvctl status asm [-n node_name] [-a]
srvctl status asm -n devnode1 -a

srvctl enable asm [-n node_name]
srvctl enable asm -n devnode1

srvctl disable asm [-n node_name]
srvctl disable asm -n devnode1

srvctl config asm [-a]
srvctl config asm -a

srvctl modify asm [-l lsnr_name] [-p spfile] [-d asm_diskstring]
srvctl modify asm [-n node_name] [-l listener_name] [-d asm_diskstring] [-p spfile_path_name]
srvctl modify asm -l lsnr1

srvctl getenv asm [-t name[, ...]]
srvctl getenv asm

srvctl setenv asm {-t "name=val [,...]" | -T "name=value"}
srvctl setenv asm -t LANG=en

srvctl unsetenv asm -t "name[, ...]"
srvctl unsetenv asm -t CLASSPATH






Listener 
========

srvctl add listener [-l lsnr_name] [-s] [-p "[TCP:]port[, ...][/IPC:key][/NMP:pipe_name][/TCPS:s_port] [/SDP:port]"] [-k network_number] [-o ORACLE_HOME]
srvctl add listener -l LISTENERASM -p "TCP:1522" -o $ORACLE_HOME
srvctl add listener -l listener112 -p 1341 -o /ora/ora112

srvctl remove listener [-l lsnr_name|-a] [-f]
srvctl remove listener -l lsnr01

srvctl stop listener [-n node_name] [-l lsnr_name] [-f]

srvctl status listener [-n node_name] [-l listener_names] -- 11g R1 command
srvctl status listener -n node2

srvctl enable listener [-l lsnr_name] [-n node_name]
srvctl enable listener -l listener_dev -n node5

srvctl disable listener [-l lsnr_name] [-n node_name]
srvctl disable listener -l listener_dev -n node5

srvctl config listener [-l lsnr_name] [-a]
srvctl config listener

srvctl modify listener [-l listener_name] [-o oracle_home] [-u user_name] [-p "[TCP:]port_list[/IPC:key][/NMP:pipe_name][/TCPS:s_port][/SDP:port]"] [-k network_number]
srvctl modify listener -n node1 -p "TCP:1521,1522"

srvctl getenv listener [-l lsnr_name] [-t name[, ...]]
srvctl getenv listener

srvctl setenv listener [-l lsnr_name] {-t "name=val [,...]" | -T "name=value"}
srvctl setenv listener -t LANG=en

srvctl unsetenv listener [-l lsnr_name] -t "name[, ...]"
srvctl unsetenv listener -t "TNS_ADMIN"










New srvctl commands in 11g Release 2
====================================

DISKGROUP
---------
srvctl remove diskgroup -g diskgroup_name [-n node_list] [-f]
srvctl remove diskgroup -g DG1 -f

srvctl start diskgroup -g diskgroup_name [-n node_list]
srvctl start diskgroup -g diskgroup1 -n node1,node2

srvctl stop diskgroup -g diskgroup_name [-n node_list] [-f]
srvctl stop diskgroup -g ASM_FRA_DG
srvctl stop diskgroup -g dg1 -n node1,node2 -f

srvctl status diskgroup -g diskgroup_name [-n node_list] [-a]
srvctl status diskgroup -g dg_data -n node1,node2 -a

srvctl enable diskgroup -g diskgroup_name [-n node_list]
srvctl enable diskgroup -g diskgroup1 -n node1,node2

srvctl disable diskgroup -g diskgroup_name [-n node_list]
srvctl disable diskgroup -g dg_fra -n node1, node2







Home:
=====
srvctl start home -o ORACLE_HOME -s state_file [-n node_name]
srvctl start home -o /u01/app/oracle/product/11.2.0/db_1 -s ~/state.txt

srvctl stop home -o ORACLE_HOME -s state_file [-t stop_options] [-n node_name] [-f]
srvctl stop home -o /u01/app/oracle/product/11.2.0/db_1 -s ~/state.txt

srvctl status home -o ORACLE_HOME -s state_file [-n node_name]
srvctl status home -o /u01/app/oracle/product/11.2.0/db_1 -s ~/state.txt






ONS (Oracle Notification Service):
==================================
srvctl add ons [-l ons-local-port] [-r ons-remote-port] [-t host[:port][,host[:port]...]] [-v]
srvctl add ons -l 6200

srvctl remove ons [-f] [-v]
srvctl remove ons -f

srvctl start ons [-v]
srvctl start ons -v

srvctl stop ons [-v]
srvctl stop ons -v

srvctl status ons

srvctl enable ons [-v]
srvctl enable ons

srvctl disable ons [-v]
srvctl disable ons

srvctl config ons

srvctl modify ons [-l ons-local-port] [-r ons-remote-port] [-t host[:port][,host[:port]...]] [-v]
srvctl modify ons





FileSystem:
===========
srvctl add filesystem -d volume_device -v volume_name -g diskgroup_name [-m mountpoint_path] [-u user_name]
srvctl add filesystem -d /dev/asm/d1volume1 -v VOLUME1 -d RAC_DATA -m /oracle/cluster1/acfs1

srvctl remove filesystem -d volume_device_name [-f]
srvctl remove filesystem -d /dev/asm/racvol1

srvctl start filesystem -d volume_device_name [-n node_name]
srvctl start filesystem -d /dev/asm/racvol3

srvctl stop filesystem -d volume_device_name [-n node_name] [-f]
srvctl stop filesystem -d /dev/asm/racvol1 -f

srvctl status filesystem -d volume_device_name
srvctl status filesystem -d /dev/asm/racvol2

srvctl enable filesystem -d volume_device_name
srvctl enable filesystem -d /dev/asm/racvol9

srvctl disable filesystem -d volume_device_name
srvctl disable filesystem -d /dev/asm/racvol1

srvctl config filesystem -d volume_device_path

srvctl modify filesystem -d volume_device_name -u user_name
srvctl modify filesystem -d /dev/asm/racvol1 -u sysadmin








SrvPool (Server Pool):
======================

srvctl add srvpool -g server_pool [-i importance] [-l min_size] [-u max_size] [-n node_list] [-f]
srvctl add srvpool -g SP1 -i 1 -l 3 -u 7 -n node1,node2

srvctl remove srvpool -g server_pool
srvctl remove srvpool -g srvpool1

srvctl status srvpool [-g server_pool] [-a]
srvctl status srvpool -g srvpool2 -a

srvctl config srvpool [-g server_pool]
srvctl config srvpool -g dbpool

srvctl modify srvpool -g server_pool [-i importance] [-l min_size] [-u max_size] [-n node_name_list] [-f]
srvctl modify srvpool -g srvpool4 -i 0 -l 2 -u 4 -n node3, node4







Server:
=======
srvctl status server -n "server_name_list" [-a]
srvctl status server -n server11 -a

srvctl relocate server -n "server_name_list" -g server_pool_name [-f]
srvctl relocate server -n "linux1, linux2" -g sp2







Scan (Single Client Access Name):
=================================

srvctl add scan -n scan_name [-k network_number] [-S subnet/netmask[/if1[|if2|...]]]
#srvctl add scan -n scan.mycluster.example.com

srvctl remove scan [-f]
srvctl remove scan
srvctl remove scan -f

srvctl start scan [-i ordinal_number] [-n node_name]
srvctl start scan
srvctl start scan -i 1 -n node1

srvctl stop scan [-i ordinal_number] [-f]
srvctl stop scan
srvctl stop scan -i 1

srvctl status scan [-i ordinal_number]
srvctl status scan
srvctl status scan -i 1

srvctl enable scan [-i ordinal_number]
srvctl enable scan
srvctl enable scan -i 1

srvctl disable scan [-i ordinal_number]
srvctl disable scan
srvctl disable scan -i 3

srvctl config scan [-i ordinal_number]
srvctl config scan
srvctl config scan -i 2

srvctl modify scan -n scan_name
srvctl modify scan
srvctl modify scan -n scan1

srvctl relocate scan -i ordinal_number [-n node_name]
srvctl relocate scan -i 2 -n node2

ordinal_number=1,2,3








Scan_listener:
==============

srvctl add scan_listener [-l lsnr_name_prefix] [-s] [-p "[TCP:]port_list[/IPC:key][/NMP:pipe_name][/TCPS:s_port] [/SDP:port]"]
#srvctl add scan_listener -l myscanlistener

srvctl remove scan_listener [-f]
srvctl remove scan_listener
srvctl remove scan_listener -f

srvctl start scan_listener [-n node_name] [-i ordinal_number]
srvctl start scan_listener
srvctl start scan_listener -i 1

srvctl stop scan_listener [-i ordinal_number] [-f]
srvctl stop scan_listener -i 3

srvctl status scan_listener [-i ordinal_number]
srvctl status scan_listener
srvctl status scan_listener -i 1

srvctl enable scan_listener [-i ordinal_number]
srvctl enable scan_listener
srvctl enable scan_listener -i 2

srvctl disable scan_listener [-i ordinal_number]
srvctl disable scan_listener
srvctl disable scan_listener -i 1

srvctl config scan_listener [-i ordinal_number]
srvctl config scan_listener
srvctl config scan_listener -i 3

srvctl modify scan_listener {-p [TCP:]port[/IPC:key][/NMP:pipe_name] [/TCPS:s_port][/SDP:port] | -u }
srvctl modify scan_listener -u

srvctl relocate scan_listener -i ordinal_number [-n node_name]
srvctl relocate scan_listener -i 1

ordinal_number=1,2,3







GNS (Grid Naming Service):
==========================
srvctl add gns -i ip_address -d domain
srvctl add gns -i 192.124.16.96 -d cluster.mycompany.com

srvctl remove gns [-f]
srvctl remove gns

srvctl start gns [-l log_level] [-n node_name]
srvctl start gns

srvctl stop gns [-n node_name [-v] [-f]
srvctl stop gns

srvctl status gns [-n node_name]
srvctl status gns

srvctl enable gns [-n node_name]
srvctl enable gns

srvctl disable gns [-n node_name]
srvctl disable gns -n devnode2

srvctl config gns [-a] [-d] [-k] [-m] [-n node_name] [-p] [-s] [-V] [-q name] [-l] [-v]
srvctl config gns -n lnx03

srvctl modify gns [-i ip_address] [-d domain]
srvctl modify gns -i 192.000.000.007

srvctl relocate gns [-n node_name]
srvctl relocate gns -n node2








VIP (Virtual Internet Protocol):
================================
srvctl add vip -n node_name -A {name|ip}/netmask[/if1[if2|...]] [-k network_number] [-v]
#srvctl add vip -n node96 -A 192.124.16.96/255.255.255.0 -k 2

srvctl remove vip -i "vip_name_list" [-f] [-y] [-v]
srvctl remove vip -i "vip1,vip2,vip3" -f -y -v

srvctl start vip {-n node_name|-i vip_name} [-v]
srvctl start vip -i dev1-vip -v

srvctl stop vip {-n node_name|-i vip_name} [-r] [-v]
srvctl stop vip -n node1 -v

srvctl status vip {-n node_name|-i vip_name}
srvctl status vip -i node1-vip

srvctl enable vip -i vip_name [-v]
srvctl enable vip -i prod-vip -v

srvctl disable vip -i vip_name [-v]
srvctl disable vip -i vip3 -v

srvctl config vip {-n node_name|-i vip_name}
srvctl config vip -n devnode2

srvctl getenv vip -i vip_name [-t "name_list"] [-v]
srvctl getenv vip -i node1-vip

srvctl setenv vip -i vip_name {-t "name=val[,name=val,...]" | -T "name=val"}
srvctl setenv vip -i dev1-vip -t LANG=en

srvctl unsetenv vip -i vip_name -t "name_list" [-v]
srvctl unsetenv vip -i myvip -t CLASSPATH








OC4J (Oracle Container for Java):
=================================

srvctl add oc4j [-v]
srvctl add oc4j

srvctl remove oc4j [-f] [-v]
srvctl remove oc4j

srvctl start ocj4 [-v]
srvctl start ocj4 -v

srvctl stop oc4j [-f] [-v]
srvctl stop oc4j -f -v

srvctl status oc4j [-n node_name]
srvctl status oc4j -n lnx01

srvctl enable oc4j [-n node_name] [-v]
srvctl enable oc4j -n dev3

srvctl disable oc4j [-n node_name] [-v]
srvctl disable oc4j -n dev1

srvctl config oc4j

srvctl modify oc4j -p oc4j_rmi_port [-v]
srvctl modify oc4j -p 5385

srvctl relocate oc4j [-n node_name] [-v]
srvctl relocate oc4j -n lxn06 -v






Administering Database Instances and Cluster Database 
=====================================================
Changing the SQL*Plus Prompt

. rdbms.env
export ORACLE_SID=+ASM1

SQL> SET SQLPROMPT '_CONNECT_IDENTIFIER> '

To change the prompt for all sessions automatically, add an entry similar to the following entry 
in your glogin.sql file, found in the SQL*Plus administrative directory:

SET SQLPROMPT '_CONNECT_IDENTIFIER> '

You may include any other required text or SQL*Plus user variable between the single quotes in the command.

You do not need to run SQL*Plus commands as root on Linux and UNIX systems or as Administrator on Windows 
systems. You need only the proper database account with the privileges that you normally use for a noncluster Oracle database.

ALTER SYSTEM CHECKPOINT LOCAL;
affects only the instance to which you are currently connected

ALTER SYSTEM CHECKPOINT;
 or 
ALTER SYSTEM CHECKPOINT GLOBAL;
affects all instances in the cluster database.

ALTER SYSTEM SWITCH LOGFILE; 
affects only the current instance.

To force a global log switch, use below command:
ALTER SYSTEM ARCHIVE LOG CURRENT;

The INSTANCE option of ALTER SYSTEM ARCHIVE LOG enables you to archive each online redo log file for a specific instance.
