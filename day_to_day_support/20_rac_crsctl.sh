crsctl commands in Oracle RAC
crsctl - Cluster Ready Service Control - commands in 11g Oracle RAC

$crsctl -- to get help
$crsctl query crs activeversion
$crsctl query crs softwareversion [node_name]

#crsctl start crs
#crsctl stop crs
(or)
#/etc/init.d/init.crs start
#/etc/init.d/init.crs stop

#crsctl enable crs
#crsctl disable crs
(or)
#/etc/init.d/init.crs enable
#/etc/init.d/init.crs disable

$crsctl check crs
$crsctl check cluster [-node node_name] -- Oracle RAC 11g command, checks the viability of CSS across nodes
#crsctl start cluster -n HostName -- 11g R2
#crsctl stop cluster -n HostName -- 11g R2
#crsctl stop cluster -all  -- 11g R2

$crsctl check cssd
$crsctl check crsd
$crsctl check evmd
$crsctl check oprocd
$crsctl check ctss

#/etc/init.d/init.cssd stop
#/etc/init.d/init.cssd start

#/etc/rc.d/init.d/init.evmd
#/etc/rc.d/init.d/init.cssd
#/etc/rc.d/init.d/init.crsd

#mv /etc/rc3.d/S96init.cssd /etc/rc3.d/_S96init.cssd -- to stop cssd from autostarting after reboot

#crsctl check css votedisk
#crsctl query css votedisk -- lists the voting disks used by CSS

#crsctl add css votedisk PATH
#crsctl add css votedisk PATH -force -- if Clusterware is not running
#crsctl delete css votedisk PATH
#crsctl delete css votedisk PATH -force -- if Clusterware is not running

#crsctl set css parameter_name value -- set parameters on OCR
#crsctl set css misscount 100
#crsctl unset css parameter_name -- sets CSS parameter to its default
#crsctl unset css misscount
#crsctl get css parameter_name -- gets the value of a CSS parameter
#crsctl get css disktimeout
#crsctl get css misscount
#crsctl get css reboottime

#crsctl start resources -- starts Clusterware resources
./crsctl start resource ora.DATA.dg
#crsctl stop resources -- stops Clusterware resources


$crsctl status resource
$crsctl status resource -t
$crsctl stat res -t

$crsctl lsmodules crs -- lists CRS modules that can be used for debugging
CRSUI
CRSCOMM
CRSRTI
CRSMAIN
CRSPLACE
CRSAPP
CRSRES
CRSCOMM
CRSOCR
CRSTIMER
CRSEVT
CRSD
CLUCLS
CSSCLNT
COMMCRS
COMMNS

$crsctl lsmodules css -- lists CSS modules that can be used for debugging
CSSD
COMMCRS
COMMNS

$crsctl lsmodules evm -- lists EVM modules that can be used for debugging
EVMD
EVMDMAIN
EVMCOMM
EVMEVT
EVMAPP
EVMAGENT
CRSOCR
CLUCLS
CSSCLNT
COMMCRS
COMMNS

$crsctl start has   (HAS - High Availability Services)
$crsctl stop has
$crsctl check has

OCR Modules -- cannot be listed with crsctl lsmodules command
OCRAPI
OCRCLI
OCRSRV
OCRMAS
OCRMSG
OCRCAC
OCRRAW
OCRUTL
OCROSD

#crsctl debug statedump crs -- dumps state info for crs objects
#crsctl debug statedump css -- dumps state info for css objects
#crsctl debug statedump evm -- dumps state info for evm objects

#crsctl debug log crs [module:level]{,module:level} ...
-- Turns on debugging for CRS
#crsctl debug log crs CRSEVT:5,CRSAPP:5,CRSTIMER:5,CRSRES:5,CRSRTI:1,CRSCOMM:2
#crsctl debug log css [module:level]{,module:level} ...
-- Turns on debugging for CSS
#crsctl debug log css CSSD:1
#crsctl debug log evm [module:level]{,module:level} ...
-- Turns on debugging for EVM
#crsctl debug log evm EVMCOMM:1

#crsctl debug trace crs -- dumps CRS in-memory tracing cache
#crsctl debug trace css -- dumps CSS in-memory tracing cache
#crsctl debug trace evm -- dumps EVM in-memory tracing cache

#crsctl debug log res resource_name:level -- turns on debugging for resources
#crsctl debug log res "ora.lnx04.vip:1"

#crsctl trace all_the_above_commands -- tracing by adding a "trace" argument.
#crsctl trace check css


#crsctl backup -h
#crsctl backup css votedisk

Here is the list of the options for CRSCTL in 11gR2:
       crsctl add       - add a resource, type or other entity
       crsctl backup    - back up voting disk for CSS
       crsctl check     - check a service, resource or other entity
       crsctl config    - output autostart configuration
       crsctl debug     - obtain or modify debug state
       crsctl delete    - delete a resource, type or other entity
       crsctl disable   - disable autostart
       crsctl discover  - discover DHCP server
       crsctl enable    - enable autostart
       crsctl get       - get an entity value
       crsctl getperm   - get entity permissions
       crsctl lsmodules - list debug modules
       crsctl modify    - modify a resource, type or other entity
       crsctl query     - query service state
       crsctl pin       - Pin the nodes in the nodelist
       crsctl relocate  - relocate a resource, server or other entity
       crsctl replace   - replaces the location of voting files
       crsctl release   - release a DHCP lease
       crsctl request   - request a DHCP lease
       crsctl setperm   - set entity permissions
       crsctl set       - set an entity value
       crsctl start     - start a resource, server or other entity
       crsctl status    - get status of a resource or other entity
       crsctl stop      - stop a resource, server or other entity
       crsctl unpin     - unpin the nodes in the nodelist
       crsctl unset     - unset a entity value, restoring its default


crsctl add resource resource_name -type resource_type [-file file_path | -attr "attribute_name=attribute_value,attribute_name=attribute_value,..."] [-i] [-f]
crsctl add resource r1 -type test_type1 -attr "PATH_NAME=/tmp/r1.txt"
crsctl add resource app.appvip -type app.appvip.type -attr "RESTART_ATTEMPTS=2, START_TIMEOUT=100,STOP_TIMEOUT=100,CHECK_INTERVAL=10,USR_ORA_VIP=172.16.0.0, START_DEPENDENCIES=hard(ora.net1.network)pullup(ora.net1.network), STOP_DEPENDENCIES=hard(ora.net1.network)"
crsctl add type type_name -basetype base_type_name {-attr "ATTRIBUTE=attribute_name | -file file_path,TYPE={string | int} [,DEFAULT_VALUE=default_value][,FLAGS=[READONLY][|REQUIRED]]"}
crsctl add type test_type1 -basetype cluster_resource -attr "ATTRIBUTE=FOO,TYPE=integer,DEFAULT_VALUE=0"
crsctl add crs administrator -u user_name [-f]
crsctl add crs administrator -u scott
crsctl add css votedisk path_to_voting_disk [path_to_voting_disk ...] [-purge]
crsctl add css votedisk /stor/grid/ -purge
crsctl add serverpool server_pool_name {-file file_path | -attr "attr_name=attr_value[,attr_name=attr_value[,...]]"} [-i] [-f]
crsctl add serverpool testsp -attr "MAX_SIZE=5"
crsctl add serverpool sp1 -file /tmp/sp1_attr

crsctl check cluster [-all | [-n server_name [...]]
crsctl check cluster -all
crsctl check crs
crsctl check css
crsctl check ctss    -- Cluster Time Synchronization services
crsctl check evm
crsctl check resource {resource_name [...] | -w "filter" } [-n node_name] [-k cardinality_id] [-d degree_id] }
crsctl check resource appsvip

crsctl config crs

crsctl delete crs administrator -u user_name [-f]
crsctl delete crs administrator -u scott
crsctl delete resource resource_name [-i] [-f]
crsctl delete resource myResource
crsctl delete type type_name [-i]
crsctl delete type app.appvip.type
crsctl delete css votedisk voting_disk_GUID [voting_disk_GUID [...]]
crsctl delete css votedisk 61f4273ca8b34fd0bfadc2531605581d
crsctl delete node -n node_name
crsctl delete node -n node06
crsctl delete serverpool server_pool_name [server_pool_name [...]] [-i]
crsctl delete serverpool sp1

crsctl disable crs

crsctl discover dhcp -clientid clientid [-port port]
crsctl discover dhcp -clientid dsmjk252clr-dtmk01-vip

crsctl enable crs

crsctl get hostname
crsctl get clientid dhcp -cluname cluster_name -viptype vip_type [-vip vip_res_name] [-n node_name]
crsctl get clientid dhcp -cluname dsmjk252clr -viptype HOSTVIP -n tmjk01
crsctl get css parameter
crsctl get css disktimeout
crsctl get css ipmiaddr
crsctl get nodename
crsctl getperm resource resource_name [ {-u user_name | -g group_name} ]
crsctl getperm resource app.appvip
crsctl getperm resource app.appvip -u oracle
crsctl getperm resource app.appvip -g dba
crsctl getperm type resource_type [-u user_name] | [-g group_name]
crsctl getperm type app.appvip.type
crsctl getperm serverpool server_pool_name [-u user_name | -g group_name]
crsctl getperm serverpool sp1

crsctl lsmodules {mdns | gpnp | css | crf | crs | ctss | evm | gipc}
crsctl lsmodules evm
 mdns: Multicast domain name server 
 gpnp: Grid Plug and Play service 
 css: Cluster Synchronization Services 
 crf: Cluster Health Monitor
 crs: Cluster Ready Services
 ctss: Cluster Time Synchronization Service 
 evm: Event Manager
 gipc: Grid Interprocess Communication 

crsctl modify resource resource_name -attr "attribute_name=attribute_value" [-i] [-f] [-delete]
crsctl modify resource appsvip -attr USR_ORA_VIP=10.1.220.17 -i
crsctl modify type type_name -attr "ATTRIBUTE=attribute_name,TYPE={string | int} [,DEFAULT_VALUE=default_value [,FLAGS=[READONLY][| REQUIRED]]" [-i] [-f]]
crsctl modify type myType.type -attr "ATTRIBUTE=FOO,DEFAULT_VALUE=0 ATTRIBUTE=BAR,DEFAULT_VALUE=baz"
crsctl modify serverpool server_pool_name -attr "attr_name=attr_value [,attr_name=attr_value[, ...]]" [-i] [-f]
crsctl modify serverpool sp1 -attr "MAX_SIZE=7"

crsctl pin css -n node_name [ node_name [..]]
crsctl pin css -n node2

crsctl query crs administrator
crsctl query crs activeversion
crsctl query crs releaseversion
crsctl query crs softwareversion node_name
crsctl query css ipmiconfig
crsctl query css ipmidevice
crsctl query css votedisk
crsctl query dns {-servers | -name name [-dnsserver DNS_server_address] [-port port] [-attempts number_of_attempts] [-timeout timeout_in_seconds] [-v]}

crsctl release dhcp -clientid clientid [-port port]
crsctl release dhcp -clientid spmjk662clr-spmjk03-vip

crsctl relocate resource {resource_name | resource_name | -all -s source_server | -w "filter"} [-n destination_server] [-k cid] [-env "env1=val1,env2=val2,..."] [-i] [-f]
crsctl relocate resource myResource1 -s node1 -n node3
crsctl relocate server server_name [...] -c server_pool_name [-i] [-f]
crsctl relocate server node6 node7 -c sp1

crsctl replace discoverystring 'absolute_path[,...]'
crsctl replace discoverystring "/oracle/css1/*,/oracle/css2/*"
crsctl replace votedisk [+asm_disk_group | path_to_voting_disk [...]]
crsctl replace votedisk +diskgroup1
crsctl replace votedisk /mnt/nfs/disk1 /mnt/nfs/disk2

crsctl request dhcp -clientid clientid [-port port]
crsctl request dhcp -clientid tmj0462clr-tmjk01-vip

crsctl set css parameter value
crsctl set css ipmiaddr ip_address
crsctl set css ipmiaddr 192.0.2.244
crsctl set css ipmiadmin ipmi_administrator_name
crsctl set css ipmiadmin scott

crsctl set log {[crs | css | evm "component_name=log_level, [...]"] | [all=log_level]}
crsctl set log crs "CRSRTI=1,CRSCOMM=2"
crsctl set log evm all=2
crsctl set log res "myResource1=3"
crsctl set {log | trace} module_name "component:debugging_level [,component:debugging_level][,...]"
crsctl set log crs "CRSRTI:1,CRSCOMM:2"
crsctl set log crs "CRSRTI:1,CRSCOMM:2,OCRSRV:4"
crsctl set log evm "EVMCOMM:1"
crsctl set log res "resname:1"
crsctl set log res "resource_name=debugging_level"
crsctl set log res "ora.node1.vip:1"
crsctl set log crs "CRSRTI:1,CRSCOMM:2" -nodelist node1,node2
crsctl set trace "component_name=tracing_level,..."
crsctl set trace "css=3"

crsctl setperm resource resource_name {-u acl_string | -x acl_string | -o user_name | -g group_name}
crsctl setperm resource myResource -u user:scott:rwx
crsctl setperm type resource_type_name {-u acl_string | -x acl_string | -o user_name | -g group_name}
crsctl setperm type resType -u user:scott:rwx
crsctl setperm serverpool server_pool_name {-u acl_string | -x acl_string | -o user_name | -g group_name}
crsctl setperm serverpool sp3 -u user:scott.tiger:rwx

crsctl start cluster [-all | -n server_name [...]]
crsctl start cluster -n node1 node2
crsctl start crs
crsctl start ip -A {IP_name | IP_address}/netmask/interface_name
crsctl start ip -A 192.168.29.220/255.255.252.0/eth0
crsctl start resource {resource_name [...] | -w filter | -all} [-n server_name] [-k cid] [-d did] [-env "env1=val1,env2=val2,..."] [-i] [-f]
crsctl start resource myResource -n server1
crsctl start testdns [-address address [-port port]] [-once] [-v]
crsctl start testdns -address 192.168.29.218 -port 63 -v

crsctl status resource {resource_name [...] | -w "filter"} [-p | -v [-e]] | [-f | -l | -g] [[-k cid | -n server_name] [-d did]] | [-s -k cid [-d did]] [-t]
crsctl status resource ora.stai14.vip
crsctl stat res -w "TYPE = ora.scan_listner.type"
crsctl status type resource_type_name [...]] [-g] [-p] [-f]
crsctl status type ora.network.type
crsctl status ip -A {IP_name | IP_address}
crsctl status server [-p | -v | -f]
crsctl status server { server_name [...] | -w "filter"} [-g | -p | -v | -f]
crsctl status server node2 -f
crsctl status serverpool [-p | -v | -f]
crsctl status serverpool [server_pool_name [...]] [-w] [-g | -p | -v | -f]
crsctl status serverpool sp1 -f
crsctl status serverpool
crsctl status serverpool -p
crsctl status serverpool -w "MAX_SIZE > 1"
crsctl status testdns [-server DNS_server_address] [-port port] [-v]

crsctl stop cluster [-all | -n server_name [...]] [-f]
crsctl stop cluster -n node1
crsctl stop crs [-f]
crsctl stop crs
crsctl stop resource {resource_name [...] | -w "filter" | -all} [-n server_name] [-k cid] [-d did] [-env "env1=val1,env2=val2,..."] [-i] [-f]
crsctl stop resource -n node1 -k 2
crsctl stop ip -A {IP_name | IP_address}/interface_name
crsctl stop ip -A MyIP.domain.com/eth0
crsctl stop testdns [-address address [-port port]] [-domain GNS_domain] [-v]

crsctl unpin css -n node_name [node_name [...exit]]
crsctl unpin css -n node1 node4

crsctl unset css parameter
crsctl unset css reboottime
crsctl unset css ipmiconfig

HAS (High Availability Service)
crsctl check has
crsctl config has
crsctl disable has
crsctl enable has
crsctl query has releaseversion
crsctl query has softwareversion
crsctl start has
crsctl stop has [-f]


How do I identify the voting disk/file location?
#crsctl query css votedisk

How to take backup of voting file/disk?
crsctl backup css votedisk
