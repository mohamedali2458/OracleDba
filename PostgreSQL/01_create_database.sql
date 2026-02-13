How to Create Database in PostgreSQL?
====================================
How to Find Create Database Syntax in PostgreSQL?
\h CREATE DATABASE

How to List All Databases in PostgreSQL using psql?
\l
\l+

select oid, datname from pg_database;

select * from pg_database;

#How To Create New database in PostgreSQL using psql?

create database test;

SELECT (pg_stat_file('base/'||oid ||'/PG_VERSION')).modification, datname FROM pg_database where datname='test';



How To Create New database With Owner in PostgreSQL using psql?

create user hr with password 'hr';

CREATE DATABASE hrdb OWNER hr;

\l+ test2


How To Create New database With Tablespace in PostgreSQL using psql?

show data_directory;

create directory test3_tbs in C:/Program Files/PostgreSQL/13/data

if Linux

mkdir -p /u01/postgres/data/test3_tbs
chown -R postgres:postgres /u01/postgres
chmod -R 750 /u01/postgres

to view tablespaces:
\db
\db+
SELECT * FROM pg_tablespace;

SELECT spcname AS tablespace_name,
       pg_catalog.pg_get_userbyid(spcowner) AS owner,
       spclocation AS location
FROM pg_tablespace;

CREATE TABLESPACE test3_tbs LOCATION 'C:\Program Files\PostgreSQL\test3_tbs';

CREATE DATABASE test3 TABLESPACE test3_tbs;

How To Create New database With Encoding in PostgreSQL using psql?

CREATE DATABASE test4 ENCODING 'UTF8';
\l+ test4

How To Create New database With Template in PostgreSQL using psql?

\l+ template1
CREATE DATABASE test5 TEMPLATE template1;
\l+ test5


How to Create New Database With Binary Owner in PostgreSQL using Command Line?

id
which createdb
createdb test6
\l+ test6


How to Connect to Database in PostgreSQL using psql?

id
psql
SELECT current_database();
\c test2
SELECT current_database();

[postgres@rac1 ~]$ psql orcl
psql (13.2)
Type "help" for help.

orcl=#  <---- Now we connected to database "orcl"


How to Find the Version of Database in PostgreSQL using psql?

SELECT version();
[postgres@rac1 ~]$ psql
psql (13.2)  <-----
Type "help" for help.

How to Exit from PostgreSQL?
\q
quit

