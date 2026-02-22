Oracle CRSCTL Commands List
===========================
CRSCTL utility allows you to administer cluster resources. 
Here are few quick commands to help you administer Oracle RAC cluster!
    Check Cluster Status 
    Check Cluster Nodes 
    Stop Grid Cluster 
    Start Grid Cluster 

  
Check Cluster Status

Status of upper & lower stack
  ./crsctl check crs

Status of upper stack
./crsctl check cluster

Cluster status on all nodes
./crsctl check cluster -all

Cluster status on specific node
./crsctl check cluster -n rac2

  
Check Cluster Nodes

Check cluster services in table format
./crsctl status resource -t
./crsctl status res -t

Checking status of clusterware nodes / services
./crsctl status server -f

Check cluster nodes
olsnodes    -n
oraracn1    1
oraracn2    2


Stop Grid Cluster

Stop HAS on current node
./crsctl stop has
  
Stop HAS on remote node
./crsctl stop has –n rac2

Stop entire cluster on all nodes
./crsctl stop cluster -all

Stop cluster ( CRS + HAS ) on remote node
./crsctl stop cluster –n rac2 


Start Grid Cluster

Start HAS on current node

./crsctl start has 
Start HAS on remote node

./crsctl start has –n rac2
Start entire cluster on all nodes

./crsctl start cluster –all
Start cluster(CRS + HAS) on remote node

./crsctl start cluster –n rac2
ENABLE – DISABLE CLUSTER AUTO START

crsctl disable has
crsctl enable has
