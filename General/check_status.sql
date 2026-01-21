check_status.sql

SET LINESIZE 32000;
SET PAGESIZE 40000;
SET LONG     50000;
COL instance_name  	FOR A10;
COL host_name		FOR A20;
COL name			FOR A10;
COL status			FOR A10;
COL open_mode		FOR A10;
COL startup_time	FOR A20;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

SELECT distinct instance_name, host_name, status, name, open_mode, startup_time
FROM gv$database, gv$instance 
ORDER BY instance_name;
