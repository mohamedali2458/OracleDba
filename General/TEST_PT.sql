create user test identified by pass default tablespace users;
grant dba to test;

-- Grant a specific amount of space
ALTER USER test QUOTA 50M ON users;

-- Grant unlimited space (most common in development/testing)
ALTER USER test QUOTA UNLIMITED ON users;

-- You can set the quota at the time of creating the user:
CREATE USER newuser IDENTIFIED BY password
DEFAULT TABLESPACE users
QUOTA UNLIMITED ON users
QUOTA 100M ON temp;

-- Check Current Quotas
-- View all users' quotas (as DBA/SYSDBA)
SELECT username, 
       tablespace_name,
       bytes/1024/1024 AS "USED_MB",
       DECODE(max_bytes, -1, 'UNLIMITED', max_bytes/1024/1024) AS "MAX_MB"
FROM dba_ts_quotas
ORDER BY username, tablespace_name;

-- View quotas for a specific user
SELECT * FROM user_ts_quotas;

-- Remove or Reduce Quota
-- Remove quota completely (sets to 0)
ALTER USER username QUOTA 0 ON tablespace_name;

-- Reduce to 200 MB
ALTER USER username QUOTA 200M ON tablespace_name;



desc test.demo;
create table test.demo(
id number,
status varchar2(40),
name varchar2(200));

insert into test.demo select object_id,status,object_name from dba_objects;
commit;

select count(1) from test.demo;

select count(1),status from test.demo group by status;

drop index test.demo_idx;

create index test.demo_idx on test.demo(status);

exec dbms_stats.gather_table_stats('TEST','DEMO');

explain plan for select * from test.demo where status = 'INACTIVE';

select * from table(DBMS_XPLAN.DISPLAY);

set lines 300;
/

https://youtu.be/jByvqkz4Nt8?list=PL7kWCcQSFwpa4w34ciq--YHfpoU-MXtQI