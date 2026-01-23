How to Create Database in PostgreSQL?
====================================
How to Find Create Database Syntax in PostgreSQL?
\h CREATE DATABASE

How to List All Databases in PostgreSQL using psql?
\l
\l+

select oid, datname from pg_database;

select * from pg_database;

How To Create New database in PostgreSQL using psql?

create database test;

SELECT (pg_stat_file('base/'||oid ||'/PG_VERSION')).modification, datname FROM pg_database where datname='test';



How To Create New database With Owner in PostgreSQL using psql?

create user ali with password 'ali';

CREATE DATABASE test2 OWNER ali;

\l+ test2


How To Create New database With Tablespace in PostgreSQL using psql?

show data_directory;

create directory test3_tbs in C:/Program Files/PostgreSQL/13/data

if Linux

mkdir -p /u01/postgres/data/test3_tbs
chown -R postgres:postgres /u01/postgres
chmod -R 750 /u01/postgres

CREATE TABLESPACE test3_tbs LOCATION 'C:\Program Files\PostgreSQL\test3_tbs';
