Oracle Datapump - Export Full Database 

su - oracle
1. make directory 
$mkdir -p /u01/datapump

2. connect to database and create dump directory
create directory dump_dir as '/u01/datapump'
grant read, write on directory dump_dir to system;

3. export full database
vi expdp_full_dbname.par
full=y
directory=dump_dir
dumpfile=full_dbname%U.dmp
filesize=5G
logfile=full_dbname_date.log
parallel=4
flashback_time=systimestamp
exclude=statistics

4. run the export job as nohup
nohup expdp \'/ as sysdba\' parfile=expdp_full_dbname.par &

tail -100f nohup.out

5. check export job status
set linesize 150
column owner_name format a20
column job_name format a30
column operation format a10
column job_mode format a10
column state format a12
select owner_name,job_name,trim(operation) as operation,
trim(job_mode) as job_mode,state,degree,
attached_sessions,datapump_sessions
from dba_datapump_jobs
order by 1,2;

attach export job
expdp \'/ as sysdba\' attach=SYS_EXPORT_SCHEMA_02
