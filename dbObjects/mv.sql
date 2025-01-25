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
