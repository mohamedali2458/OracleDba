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

