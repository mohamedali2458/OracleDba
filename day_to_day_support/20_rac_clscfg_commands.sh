clscfg commands in Oracle RAC
=============================
CLSCFG: -- Oracle cluster configuration tool, commands in 
Oracle Real Application Cluster(RAC) 11g / 12c

clscfg -help or clscfg -h

clscfg -install -- creates a new configuration
clscfg -add     -- adds a node to the configuration
clscfg -delete -- deletes a node from the configuration
clscfg -upgrade     -- upgrades an existing configuration
clscfg -downgrade -- downgrades an existing configuration

clscfg -local       -- creates a special single-node configuration for ASM
clscfg -concepts -- brief listing of terminology used in the other modes
clscfg -trace       -- may be used in conjunction with any mode above for tracing
