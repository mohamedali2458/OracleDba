How to Find Out VIP of an Oracle RAC Cluster
Login clusterware owner (oracle) and execute the below command to find out the VIP hostname used in Oracle RAC
$ olsnodes -i

1. srvctl
$ srvctl config nodeapps -viponly

srvctl config database
srvctl config database -db TEST -all
srvctl config service -db TEST

srvctl config nodeapps

srvctl config vip -node node1
srvctl config vip -node node2
srvctl config vip -node node3
srvctl config vip -node node4

srvctl config vip -vip -node node1-vip
srvctl config vip -vip -node node2-vip
srvctl config vip -vip -node node3-vip
srvctl config vip -vip -node node4-vip

srvctl config network
srvctl config asm -detail
srvctl config listener -all
srvctl config scan
srvctl config scan_listener
srvctl config srvpool
srvctl config oc4j
srvctl config rhpserver
srvctl config havip
srvctl config exportfs
srvctl config rhpclient
srvctl config filesystem
srvctl config volume
srvctl config gns -detail
srvctl config cvu
srvctl config mgmtdb -all
srvctl config mgmtlsnr -all
srvctl config mountfs
srvctl config all

2. crsctl
crsctl status resource -t

3. script
runsrv.sh
#!/bin/bash
input="/home/oracle/jt/srvline.txt"
while IFS=read -r line
do
  echo "++++++++++++++++++++++++++++++++++++++"
  echo "$line"
  echo "--------------------------------------"
  $line
done < "$input"




srvctl config database -d orcl
srvctl status database -d orcl
srvctl start database -d orcl
srvctl stop database -d orcl

srvctl stop instance -d orcl -i orcl2
srvctl start instance -d orcl -i orcl2

NodeApps
srvctl config listener
srvctl stop listener -listener LISTENER
srvctl start listener -listener LISTENER

crsctl stat res -t

srvctl status vip -vip rhl-1
srvctl status vip -vip rhl-2
srvctl stop vip -vip rhl-1 -f
srvctl start vip -vip rhl-1
