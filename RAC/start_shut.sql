Startup & Shutdown RAC Instances

Start Stop via SQL*PLUS

Connect to individual node DBs via SQLPLUS and use normal startup/shutdown commands



Start & Stop RAC Databases
  
srvctl status database -d RAC

srvctl stop database -d RAC -o immediate

srvctl start database -d RAC -o nomount | mount | open

srvctl config database -d RAC

srvctl status service -d RAC

srvctl status asm -n oraracn1 -a

srvctl status asm -a

srvctl stop asm -n oraracn1 -f

srvctl start asm -n oraracn1

srvctl status nodeapps -n oraracn1

srvctl config nodeapps -n oraracn1



Start and Stop RAC Instances
  
srvctl start instance -d RAC -i instancename

srvctl stop instance -d RAC -i instancename

srvctl status scan

srvctl config scan

srvctl status scan_listener

srvctl config scan_listener
