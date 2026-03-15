How to connect to postgres db:

set PATH if not done:

postgres$ export PATH=/Library/PostgreSQL/10/bin:$PATH
postgres$ which psql
/Library/PostgreSQL/10/bin/psql

connect to db using SYNTAX - psql -d -U

postgres$ psql -d edb -U postgres
Password for user postgres:
psql (10.13)
Type "help" for help.

postgres=#

Find current connection info:

postgres=# \conninfo
You are connected to database "edb" as user "postgres" via socket in "/tmp" at port "5432".

 

postgres=# select current_schema,current_user,session_user,current_database();
current_schema  | current_user | session_user | current_database
----------------+--------------+--------------+------------------
public         | postgres.     | postgres     | edb

 

Switch to another database:

postgres-# \c dbaclass
You are now connected to database "dbaclass" as user "postgres".