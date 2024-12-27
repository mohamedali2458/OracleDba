select username from v$session;

--blank users are related to background processes

select sid,serial# from v$session where username='SCOTT';

alter system kill session 'SID,SERIAL#';

select status from v$session where username='SCOTT';

--status must be killed

--user still logged on 
select table_name from user_tables;
--ora-01012

alter system kill session 'SID,SERIAL#' immediate;
select status from v$session where username='SCOTT';
--its gone completely. nothing comes in this query
