create materialized view mv_18 
BUILD IMMEDIATE
REFRESH COMPLETE START WITH SYSDATE 
  NEXT  SYSDATE + 3/24
as
select * from dual;


you want that the first time of your materialized view refresh will be tomorrow at 02:00 am and the next times will be every 1 hour, so your statement will be something like
  
CREATE MATERIALIZED VIEW MV_UT
REFRESH COMPLETE
START WITH TO_DATE('12-SEP-2012 02:00:00','dd-mon-yyyy hh24:mi:ss')
NEXT (SYSDATE +1/24)
AS
SELECT * FROM user_tables;

the following should work for me to start refreshing the view at 12am tomorrow and then every 6 hours afterwards (so that refreshes take place everyday at 12am, 6am, 12pm, 6pm)
CREATE MATERIALIZED VIEW test_mv 
REFRESH COMPLETE 
START WITH TRUNC(SYSDATE+1) 
NEXT sysdate+6/24 as

select owner as view_schema,
       name as view_name,
       referenced_owner as referenced_schema,
       referenced_name as referenced_table
from sys.all_dependencies
where type = 'MATERIALIZED VIEW'
      and referenced_type = 'TABLE'
order by view_schema,
         view_name;

select owner as view_schema,
       name as view_name,
       referenced_owner as referenced_schema,
       referenced_name as referenced_table
from sys.dba_dependencies
where type = 'MATERIALIZED VIEW'
      and referenced_type = 'TABLE'
order by view_schema,
         view_name;


select name as mv, listagg(referenced_name || ' - ' || referenced_type , '|' ) 
 within group ( order by referenced_name ) as list_dep
 from dba_dependencies 
 where name='MV_18' 
 --and name != referenced_name 
 group by name;

 SELECT * FROM SYS.ALL_DEPENDENCIES WHERE NAME='MV_18';

select ROWNER, RNAME, NEXT_DATE, INTERVAL from USER_REFRESH;
select ROWNER, RNAME, NEXT_DATE, INTERVAL from CDB_REFRESH;

If we use refresh group:

select RNAME,INTERVAL,JOB from USER_REFRESH_CHILDREN where name = 'MV_18';
select RNAME,INTERVAL,JOB from CDB_REFRESH_CHILDREN where name = 'MV_18';

select RNAME,INTERVAL,JOB,JOB_NAME from USER_REFRESH_CHILDREN where name = 'MV_18';
select RNAME,INTERVAL,JOB,JOB_NAME from CDB_REFRESH_CHILDREN where name = 'MV_18';
