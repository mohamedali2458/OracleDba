Oracle Backup

SELECT round(min(sysdate - end_time))
from V$RMAN_BACKUP_JOB_DETAILS
WHERE replace(INPUT_TYPE,' ','') = 'DBINCR'
and STATUS = 'COMPLETED';

select round(min(sysdate - end_time))
from V$RMAN_BACKUP_JOB_DETAILS
where replace(INPUT_TYPE,' ','') = 'ARCHIVELOG'
and status = 'COMPLETED';

set papersize 100
set linesize 300
col STATUS for a20
col hrs for 999.99
select SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'dd/mm/yyyy hh24:mi') start_time,
to_char(END_TIME,'dd/mm/yyyy hh24:mi') end_time,
elapsed_seconds/3600 hrs
from V$RMAN_BACKUP_JOB_DETAILS
order by session_key;

