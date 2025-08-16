cluvfy commands in Oracle RAC
=============================
CLUVFY: Cluster Verification Utility commands in Oracle 11g / 12c RAC

cluvfy [-help] or cluvfy -h

cluvfy stage {-pre|-post} stage_name stage_specific_options [-verbose]


Valid stage options and stage names are:
        -post hwos    :  post-check for hardware and operating system
        -pre  cfs       :  pre-check for CFS setup
        -post cfs       :  post-check for CFS setup
        -pre  crsinst  :  pre-check for CRS installation
        -post crsinst  :  post-check for CRS installation
        -pre  hacfg   :  pre-check for HA configuration
        -post hacfg   :  post-check for HA configuration
        -pre  dbinst   :  pre-check for database installation
        -pre  acfscfg  :  pre-check for ACFS Configuration.
        -post acfscfg  :  post-check for ACFS Configuration.
        -pre  dbcfg   :  pre-check for database configuration
        -pre  nodeadd :  pre-check for node addition.
        -post nodeadd :  post-check for node addition.
        -post nodedel  :  post-check for node deletion.

cluvfy stage -post hwos -n node_list [-verbose]
./runcluvfy.sh stage -post hwos -n node1,node2 -verbose
-- Installation checks after hwos - Hardware and Operating system installation

cluvfy stage -pre cfs -n node_list [-verbose]
cluvfy stage -post cfs -n node_list [-verbose]
-- Installation checks before/after Cluster File System

cluvfy stage -pre crsinst -n node_list [-c ocr_location] [-r {10gR1|10gR2|11gR1|11gR2}] [-q voting_disk] [-osdba osdba_group] [-orainv orainventory_group] [-verbose]
cluvfy stage -pre crsinst -n node1,node2,node3
./runcluvfy.sh stage -pre crsinst -n all -verbose
cluvfy stage -post crsinst -n node_list [-verbose]
-- Installation checks before/after CRS installation

cluvfy stage -pre dbinst -n node_list [-r {10gR1|10gR2|11gR1|11gR2}] [-osdba osdba_group] [-orainv orainventory_group] [-verbose]
cluvfy stage -pre dbcfg -n node_list -d oracle_home [-verbose]
-- Installation checks before/after DB installation/configuration




====================================

cluvfy comp component_name component_specific_options [-verbose]

Valid components are:
        nodereach : checks reachability between nodes
        nodecon    : checks node connectivity
        cfs         : checks CFS integrity
        ssa        : checks shared storage accessibility
        space     : checks space availability
        sys        : checks minimum system requirements
        clu         : checks cluster integrity
        clumgr   : checks cluster manager integrity
        ocr        : checks OCR integrity
        olr        : checks OLR integrity
        ha        : checks HA integrity
        crs        : checks CRS integrity
        nodeapp   : checks node applications existence
        admprv    : checks administrative privileges
        peer        : compares properties with peers
        software  : checks software distribution
        asm        : checks ASM integrity
        acfs        : checks ACFS integrity
        gpnp       : checks GPnP integrity
        gns         : checks GNS integrity
        scan        : checks SCAN configuration
        ohasd      : checks OHASD integrity
        clocksync  : checks Clock Synchronization
        vdisk        : check Voting Disk Udev settings

cluvfy comp nodereach -n node_list [-srcnode node] [-verbose]
cluvfy comp nodecon -n node_list [-i interface_list] [-verbose]
cluvfy comp nodecon -n node1,node2,node3 –i eth0 -verbose
cluvfy comp nodeapp [-n node_list] [-verbose]

cluvfy comp peer [-refnode node] -n node_list [-r {10gR1|10gR2|11gR1|11gR2}] [-orainv orainventory_group] [-osdba osdba_group] [-verbose]
cluvfy comp peer -n node1,node2 -r 10gR2 -verbose

cluvfy comp crs [-n node_list] [-verbose]
cluvfy comp cfs [-n node_list] -f file_system [-verbose]
cluvfy comp cfs -f /oradbshare –n all -verbose

cluvfy comp ocr [-n node_list] [-verbose]
cluvfy comp clu -n node_list -verbose
cluvfy comp clumgr [-n node_list] [-verbose]

cluvfy comp sys [-n node_list] -p {crs|database} [-r {10gR1|10gR2|11gR1|11gR2}] [-osdba osdba_group] [-orainv orainventory_group] [-verbose]
cluvfy comp sys -n node1,node2 -p crs -verbose

cluvfy comp admprv [-n node_list] [-verbose] |-o user_equiv [-sshonly] |-o crs_inst [-orainv orainventory_group] |-o db_inst [-orainv orainventory_group] [-osdba osdba_group] |-o db_config -d oracle_home

cluvfy comp ssa [-n node_list] [-s storageID_list] [-verbose]
cluvfy comp space [-n node_list] -l storage_location -z disk_space{B|K|M|G} [-verbose]
cluvfy comp space -n all -l /home/dbadmin/products –z 2G -verbose

cluvfy comp olr
