Drop database from psql

Note - while dropping a database, you need to connect to a database 
other than the db you are trying to drop.

postgres=# \conninfo
You are connected to database "postgres" as user "postgres" on host "localhost" at port "5432".

postgres#drop database "DBACLASS";

-- Drop database using dropdb os utility

postgres$ pwd
/Library/PostgreSQL/10/bin

postgres$ ./dropdb -e "DBACLASS"
Password:
SELECT pg_catalog.set_config('search_path', '', false)
DROP DATABASE "DBACLASS";
