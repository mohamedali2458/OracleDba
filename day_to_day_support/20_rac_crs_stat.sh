crs_stat commands in Oracle RAC
CRS_STAT commands (till Oracle 11g Release 1)    -- deprecated in Oracle Clusterware 11g release 2

crs_stat [resource_name [...]] [-v] [-l] [-q] [-c cluster_node]
crs_stat [resource_name [...]] -t [-v] [-q] [-c cluster_node]
crs_stat -p [resource_name [...]] [-q]
crs_stat [-a] resource_name -g
crs_stat [-a] resource_name -r [-c cluster_node]
crs_stat -f [resource_name [...]] [-q] [-c cluster_node]
crs_stat -ls resource_name

crs_stat or crs_stat -u or crs_stat -l
crs_stat -t -- tabular format
crs_stat -v -- verbose
crs_stat -p -- more details
AUTO_START = 0 restore
  = 1 always restart
  = 2 never restart
RESTART_ATTEMPTS = n -- How many times Clusterware should attempt to start the resource? 

crs_stat -ls
crs_stat -t/v/p resource_name or crs_stat -t/v/p|grep keyword -- will show the entries with that keyword
crs_stat -p lnx02
crs_stat -v | grep eg6245

crs_stat -p resource_name > filename.cap -- generate resource profile file

This crs_stat command was replaced with crsctl command (options).
