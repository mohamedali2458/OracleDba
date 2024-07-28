Finding Out Oracle RAC Cluster Name and Version
===============================================
Option 1
execute below command from CRS_HOME/bin
$cemutlo -n
rac11

Option 2
execute below command from CRS_HOME/bin
$olsnodes -c
rac11

Option 3
navigate to the directory $CRS_HOME/cdata. Under this directory you will find a directory with the name of cluster which includes the OCR backup
cd $CRS_HOME/cdata
ls
localhost  node1 node1.olr  rac11


How to Find the Clusterware (CRS) version in Oracle RAC
=======================================================
follow the steps below to find the clusterware version (Grid infrastructure) of your RAC cluster
to see on current node

$crsctl query crs softwareversion
Oracle Clusterware version on node [node1] is [12.1.0.2.0]

to see on all the nodes
$ crsctl query crs softwareversion -all
Oracle Clusterware version on node [node1] is [12.1.0.2.0]
Oracle Clusterware version on node [node2] is [12.1.0.2.0]

to see on a particular node
$ crsctl query crs softwareversion node2
Oracle Clusterware version on node [node2] is [12.1.0.2.0]

You can check the active version from below command
$ crsctl query crs activeversion
Oracle Clusterware active version on the cluster is [12.1.0.2.0]

