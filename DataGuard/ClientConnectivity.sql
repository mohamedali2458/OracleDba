Client Connectivity in Data Guard Configuration
Configure seamless client connectivity for Oracle Data Guard.

When you have a physical standby, you must make sure client connectivity is set properly 
so that when you perform failover or switchover, client must smoothly connect to the new 
primary in data guard configuration.

Create New Service on Primary 
Create Trigger to Auto Start Service 
Enable Client Connect in Data Guard 

Create New Service on Primary
=============================
This service is created on primary database to connect proddb.

exec DBMS_SERVICE.CREATE_SERVICE (service_name => 'ip7_ha', network_name => 'ip7_ha', 
failover_method => 'BASIC', failover_type => 'SELECT', failover_retries => 30, failover_delay => 10);

Make above service run only on primary: This service should run only on the primary database. Even 
when there is switchover or failover, this service should continue to run on new primary.

create or replace procedure start_ha_service
is
v_role VARCHAR(30);
begin
select DATABASE_ROLE into v_role from V$DATABASE;
if v_role = 'PRIMARY' then
DBMS_SERVICE.START_SERVICE('ip7_ha');
else
DBMS_SERVICE.STOP_SERVICE('ip7_ha');
end if;
end;
/

Create Trigger to Auto Start Service
====================================
We need to create trigger to start above service on database startup and also role change on primary.

TRIGGER TO START SERVICE ON DB STARTUP:
=======================================
create or replace TRIGGER ha_on_startup
after startup on database
begin
start_ha_service;
end;
/

TRIGGER TO START SERVICE ON DB ROLECHANGE:
==========================================
create or replace TRIGGER ha_on_role_change
after db_role_change on database
begin
start_ha_service;
end;
/

Start the new service on primary

SQL> exec start_ha_service;
SQL> alter system archive log current;

Enable Client Connect in Data Guard
===================================
Update client's tns entries to access Oracle Data Guard setup via above service

ip7 =
  (DESCRIPTION =
    (ADDRESS_LIST=
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.2.171)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.2.172)(PORT = 1521))
    )
   (CONNECT_DATA = (SERVICE_NAME = ip7_ha)
     (FAILOVER_MODE=(TYPE=SELECT)(METHOD=BASIC)(RETRIES=30)(DELAY=10))
   )
  )    
