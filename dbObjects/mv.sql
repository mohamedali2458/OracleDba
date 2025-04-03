Oracle Materialized Views
=========================
set linesize 300
col owner for a20
col mview_name for a30
select owner,mview_name, to_char(last_refresh_end_time, 'HH24:MI:SS') tim
from user_mviews
order by 1,2;

variable n number
exec dbms_mview.refresh_all_mviews(number_of_failures=>:n);

drop materialized view mv;
select * from user_mviews;

variable n number
exec dbms_mview.refresh_all_mviews(number_of_failures=>:n);

--this will take same amount of time even though mv is no more

https://www.youtube.com/watch?v=jKJiGHqM56E

DBA_MVIEWS
==========
select owner,mview_name,container_name,query from dba_mviews
where mview_name='MV1';

col owner for a20
col mview_name for a20
select owner,mview_name,updatable,refresh_mode,refresh_method,build_mode,
fast_refreshable,last_refresh_type,last_refresh_date,last_refresh_end_time,
staleness,compile_state,stale_since
from dba_mviews;

select owner, JOB_NAME, JOB_ACTION, START_DATE, REPEAT_INTERVAL, STATE, LAST_RUN_DURATION 
from dba_scheduler_jobs 
where job_name='MVIEW_REFRESH';

need to test
============
See if this helps!!
WITH interval_to_minutes AS (
    SELECT 
        mvview_name,
        refresh_type,
        interval,
        CASE 
            WHEN interval LIKE '%DAYS%' 
                THEN TO_NUMBER(REGEXP_SUBSTR(interval, '\d+')) * 24 * 60
            WHEN interval LIKE '%HOURS%' 
                THEN TO_NUMBER(REGEXP_SUBSTR(interval, '\d+')) * 60
            WHEN interval LIKE '%MINUTES%' 
                THEN TO_NUMBER(REGEXP_SUBSTR(interval, '\d+'))
            WHEN interval LIKE '%SYSDATE%' 
                THEN 24 * 60  -- Assuming daily refresh for SYSDATE
            ELSE NULL
        END AS refresh_freq_in_minutes
    FROM cdb_snapshots
)
SELECT 
    mv.mvview_name,
    mv.refresh_type,
    mv.interval AS original_interval,
    mv.refresh_freq_in_minutes,
    CASE 
        WHEN refresh_freq_in_minutes IS NOT NULL THEN
            CASE 
                WHEN refresh_freq_in_minutes >= 24*60 
                    THEN ROUND(refresh_freq_in_minutes/(24*60), 1) || ' days'
                WHEN refresh_freq_in_minutes >= 60 
                    THEN ROUND(refresh_freq_in_minutes/60, 1) || ' hours'
                ELSE refresh_freq_in_minutes || ' minutes'
            END
        ELSE 'Unknown interval format'
    END AS readable_refresh_interval
FROM interval_to_minutes mv
ORDER BY 
    COALESCE(refresh_freq_in_minutes, 999999),
    mvview_name;
