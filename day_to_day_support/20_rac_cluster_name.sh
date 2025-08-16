cluster name of Oracle RAC cluster
==================================
The cluster name is case-insensitive, must be unique 
across environment, must be no more than 15 characters 
in length, must be alphanumeric and may contain 
hyphens (-). Underscore characters (_) are not allowed. 
But installation script/OUI will not fail, even if you 
provide more than 15 characters in cluster name.

1) cemutlo utility
$GRID_HOME/bin/cemutlo -n
$cemutlo -n

Below command will give number of characters in Oracle RAC Cluster name.
cemutlo -n|wc -c

cemutlo -n -w
where:
 -n prints the cluster name
 -w prints the clusterware version in the following format: 
 major_version:minor_version:vendor_info

2) olsnodes utility
olsnodes -c
