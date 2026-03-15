postgres=# create database DBATEST;
CREATE DATABASE

postgres=# create database DBATEST with tablespace ts_postgres;
CREATE DATABASE

postgres#CREATE DATABASE "DBATEST"
WITH TABLESPACE ts_postgres
OWNER "postgres"
ENCODING 'UTF8'
LC_COLLATE = 'en_US.UTF-8'
LC_CTYPE = 'en_US.UTF-8'
TEMPLATE template0;

 

-- View database information:

postgres=# \l

postgres# select * from pg_database;


<< Note - alternatively database can be created using pgadmin GUI tool also >>>