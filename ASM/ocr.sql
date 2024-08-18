Oracle Cluster Registry (OCR) Administration

Verify OCR
    ./ocrcheck
    ./ocrdump ocr.bkp			--> To see the contents of OCR
    ./ocrdump -xml /tmp/ocr.bkp		--> To see the contents of OCR

Check OCR Backups
./ocrconfig -showbackup auto

	- Every 4 hrs backup (3 max) ñ File Names: backup00.ocr, backup01.ocr and backup02.ocr
	- Daily backups (2max) ñ day.ocr and day_.ocr
	- Weekly backups (2 max) ñ week.ocr and week_.ocr

./ocrconfig -manualbackup		--> manual backup of OCR
./ocrconfig -backuploc <new_loc>	--> to change OCR backup location
./ocrconfig -restore <file_name>	--> to restore OCR file from backup file

OLR Management
cat /etc/oracle/olr.loc			--> Default OLR location
$GRID_HOME/cdata/hostname.olr		--> Default OLR configuration file
./ocrcheck -config -local		--> Check OLR configuration file location using ocrcheck

./ocrdump -local /tmp/olr.bkp		--> To see the contents of OLR
./ocrdump -local -xml /tmp/olr.bkp	--> To see the contents of OLR

./ocrconfig -local -manualbackup	--> To take manual backup of OLR


Oracle Clusterware Logs

All the clusterware logs reside under

$GRID_HOME/log/<hostname>
Clusterware alert log

$GRID_HOME/log/<hostname>/alertracn1.log
Other process log files

$GRID_HOME/log/<hostname>/crsd         --> crs log
$GRID_HOME/log/<hostname>/ctssd        --> cts log
$GRID_HOME/log/<hostname>/evmd         --> evmd log
$GRID_HOME/log/<hostname>/ohasd        --> ohasd log
$GRID_HOME/log/<hostname>/diskmon      --> diskmon log
CRSD Oraagent logs

$GRID_HOME/log/<hostname>/agent/crsd/oragent_<crs admin username>
CRSD Ora root agent logs

$GRID_HOME/log/<hostname>/agent/crsd/orarootagent_<crs admin username>

