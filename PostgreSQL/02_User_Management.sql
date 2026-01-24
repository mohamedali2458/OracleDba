User Management
===============
Create Users, Groups and Schema Paths for PostgreSQL

1: Create a User

CREATE USER john WITH PASSWORD 'mypassword';

CREATE ROLE john LOGIN PASSWORD 'mypassword';

2: Change User Password
  
Passwords can be changed by either an admin or the user.

postgres=# ALTER USER john WITH PASSWORD 'newpassword';

postgres=# \password john
Enter new password for user "john":
Enter it again:

By User (self-service): From the psql prompt:

[postgres@pg17 ~]$ psql -h 192.168.2.31 -U john -d mydb -W
Password:

\conninfo

\password


3: Grant Database Access

To allow a user to connect to a database:
postgres=# GRANT CONNECT ON DATABASE mydb TO john;

Verify user login:
-- Connect as user
[postgres@pg17 ~]$ psql -h 192.168.2.31 -U john -d mydb -W
Password:

-- Check current user
mydb=> SELECT CURRENT_USER;
mydb=> select session_user;
mydb=> \conninfo


4: Expire User Password
ALTER USER john VALID UNTIL '2025-09-11';

\du+

5: Set Password to Never Expire
\du

-- Without changing existing password
postgres=# ALTER USER john VALID UNTIL 'infinity';

-- With changing existing password
postgres=# ALTER USER john WITH PASSWORD 'newpassword' VALID UNTIL 'infinity';
postgres=# \du

-- Set to future date
postgres=# ALTER USER john VALID UNTIL '2025-12-31';

6: Lock User Account
postgres=# ALTER USER john NOLOGIN;

7: Unlock User Account
postgres=# ALTER USER john LOGIN;
\du+

8: Create Schema
postgres=# \c mydb
mydb=# CREATE SCHEMA BLP;
mydb=# \dn

9: Create Roles & Users
postgres=# CREATE USER "BLP" WITH PASSWORD 'blp';
postgres=# CREATE ROLE blp_rw NOLOGIN;
postgres=# CREATE ROLE blp_ro NOLOGIN;

postgres=# CREATE USER alice WITH PASSWORD 'alice123';
postgres=# CREATE USER bob WITH PASSWORD 'bob123';
postgres=# CREATE USER charlie WITH PASSWORD 'charlie123';

postgres=# \du+

10: Assign Ownership on Schema

-- Please do NOT grant this privillege, Owner can drop the schema, change privileges, and has full control over all objects inside.
postgres=# \c mydb
mydb=# \dn
mydb=# ALTER SCHEMA BLP OWNER TO "BLP";
mydb=# \dn+

11: Grant Schema Privileges to Owner
  
-- Full control on schema: usage + create
GRANT USAGE, CREATE ON SCHEMA blp TO "BLP";

mydb=# \dn+
mydb=# GRANT USAGE, CREATE ON SCHEMA blp TO "BLP";
mydb=# \dn+

12: Grant RW Privileges

USAGE → allows the role to see the schema and its objects.
-- Grant schema access without CREATE
GRANT USAGE ON SCHEMA BLP TO blp_rw;

-- Grant DML on all existing tables
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA BLP TO blp_rw;

-- Future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA BLP GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO blp_rw;

mydb=# GRANT USAGE ON SCHEMA BLP TO blp_rw;
mydb=# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA BLP TO blp_rw;
mydb=# ALTER DEFAULT PRIVILEGES IN SCHEMA BLP GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO blp_rw;
mydb=# \dn+

13: Grant RO Privileges

-- Grant schema access without CREATE
GRANT USAGE ON SCHEMA BLP TO BLP_RO;

-- Grant SELECT on all existing tables
GRANT SELECT ON ALL TABLES IN SCHEMA BLP TO BLP_RO;

-- Future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA BLP GRANT SELECT ON TABLES TO BLP_RO;

mydb=# GRANT USAGE ON SCHEMA BLP TO BLP_RO;
GRANT
mydb=# GRANT SELECT ON ALL TABLES IN SCHEMA BLP TO BLP_RO;
GRANT
mydb=# ALTER DEFAULT PRIVILEGES IN SCHEMA BLP GRANT SELECT ON TABLES TO BLP_RO;
ALTER DEFAULT PRIVILEGES
mydb=#
mydb=# \dn+

14: Assign Roles to Users

mydb=# GRANT BLP_RW TO ALICE;
GRANT ROLE
mydb=# 
mydb=# GRANT BLP_RO TO BOB,CHARLIE;
GRANT ROLE

mydb=# \du+

15: Testing

-- Login to BLP user on mydb database and create table on blp schema. 

[postgres@pg17 ~]$ psql -h 192.168.2.31 -U BLP -d mydb -W
Password:

mydb=> \conninfo

mydb=> CREATE TABLE blp.employees (
mydb(>     emp_id SERIAL PRIMARY KEY,
mydb(>     first_name VARCHAR(50),
mydb(>     last_name VARCHAR(50),
mydb(>     hire_date DATE,
mydb(>     salary NUMERIC(10,2)
mydb(> );

mydb=> INSERT INTO blp.employees (first_name, last_name, hire_date, salary) VALUES
mydb-> ('John', 'Doe', '2023-01-15', 5000.00),
mydb-> ('Jane', 'Smith', '2022-11-20', 6000.00),
mydb-> ('Alice', 'Johnson', '2024-03-01', 5500.00);

mydb=> select * from blp.employees;

mydb=> drop table blp.employees;

-- Login to alice user on mydb database and update table on blp schema. 
[root@pg17 ~]# psql -h 192.168.2.31 -U alice -d mydb -W
Password:

mydb=> \conninfo

mydb=> \du+ alice

mydb=> \dt+ blp.*

mydb=> select * from blp.employees;

mydb=> UPDATE blp.employees
SET salary = CASE
                WHEN first_name = 'John' THEN 7000.00
                WHEN first_name = 'Alice' THEN 6500.00
             END
WHERE first_name IN ('John', 'Alice');

mydb=> select * from blp.employees;

mydb=>

-- Note, we have granted only DML privilleges, hence create and alter table command failing

mydb=> CREATE TABLE blp.departments (
mydb(>     dept_id SERIAL PRIMARY KEY,
mydb(>     dept_name VARCHAR(100) NOT NULL,
mydb(>     location VARCHAR(100)
mydb(> );
ERROR:  permission denied for schema blp
LINE 1: CREATE TABLE blp.departments (
                     ^

mydb=> ALTER TABLE blp.employees
mydb-> ADD COLUMN department VARCHAR(50);
ERROR:  must be owner of table employees

-- Login to bob user on mydb database and select table on blp schema. 

[postgres@pg17 ~]$ psql -h 192.168.2.31 -U bob -d mydb -W
Password:

mydb=> \conninfo

mydb=>
mydb=> \du+ bob
mydb-> \dt+ blp.*
  
