Tablespace Usage Monitoring in Oracle

SELECT table_name 
FROM dict 
WHERE table_name LIKE '%TABLESPACE%';

This query lists all dictionary views related to 
tablespace management, such as DBA_TABLESPACES, 
CDB_TABLESPACES, and DBA_TABLESPACE_USAGE_METRICS.

Then I used the following query:

SELECT * FROM DBA_TABLESPACE_USAGE_METRICS;

This view helps DBAs monitor tablespace storage usage. It displays:
TABLESPACE_NAME – Name of the tablespace
USED_SPACE – Amount of space currently used
TABLESPACE_SIZE – Total allocated size
USED_PERCENT – Percentage of space used

From the output we can see tablespaces like SYSTEM, SYSAUX, 
USERS, TEMP, etc., and how much storage each is consuming.

📌 Real-world use case:
DBAs regularly monitor this view to prevent tablespaces from 
becoming full. If the usage percentage becomes high, they can 
add datafiles or enable autoextend to avoid database downtime.

This is an important daily monitoring activity for an Oracle DBA 
to maintain database performance and availability.

SELECT table_name FROM dict WHERE table_name like '%TABLESPACE%';

SELECT * FROM DBA_TABLESPACE_USAGE_METRICS;


