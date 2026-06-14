--Notes

--Creating databases

--To connect to a database using the psql utility:
psql -h localhost -d postgres –p 5432

--creating a user 
CREATE USER hr with PASSWORD 'hr';

--create database 
--first method
CREATE DATABASE hrdb WITH ENCODING='UTF8' OWNER=hr
CONNECTION LIMIT=25;

--second method
createdb –h localhost –p 5432 –U postgres testdb1


--to create a database a user must be superuser or
--have CREATEDB privilege. 


--to view the list of existing databases 
SELECT datname FROM pg_database WHERE datistemplate = false;

\l


--Creating schemas

A schema is a named collection of tables. A schema may also 
contain views, indexes, sequences, data types, operators, 
and functions. Schemas help organize database objects 
into logical groups, which helps make these objects more manageable.


CREATE SCHEMA employee;

CREATE SCHEMA university AUTHORIZATION bob;

--psql switch to view schemas

\dn


A schema is a logical entity that helps organize objects and data in the database.
By default, if you dont create any schemas, any new objects will be created in the public schema.
In order to create a schema, the user must either be a superuser or must have the CREATE
privilege for the current database.
Once a schema is created, it can be used to create new objects such as tables and views
within that schema.

--to view the current schema:

SELECT current_schema();



While searching for objects in the database, you can define the search schemas preferences
for where those searches should start.

ALTER DATABASE hrd SET search_path TO hr,hrms,public,pg_catalog;


--Creating Users
A user is a login role that is allowed to log in to the PostgreSQL server. The login roles section
is where you define accounts for individual users for the PostgreSQL system. Each database
user should have an individual account to log in to the PostgreSQL system. Each user has an
internal system identifier in PostgreSQL, which is known as a sysid. The users system ID is
used to associate objects in a database with their owner. Users may also have global rights
assigned to them when they are created. These rights determine whether a user is allowed to
create or drop databases and whether the existing user is a superuser or not.


CREATE user hr WITH PASSWORD 'password';

$ createuser -h localhost -p 5432 -S hr
(here -S means created user will not have the superuser privileges)


SELECT * FROM pg_user;

\du 

(will display both users and roles)

SELECT 
    u.usename AS "User Name", 
    u.usesysid AS "User ID",
    CASE 
        WHEN u.usesuper AND u.usecreatedb THEN 
            CAST('superuser, create database' AS pg_catalog.text)
        WHEN u.usesuper THEN
            CAST('superuser' AS pg_catalog.text)
        WHEN u.usecreatedb THEN
            CAST('create database' AS pg_catalog.text)
        ELSE 
            CAST('' AS pg_catalog.text)
    END AS "Attributes" 
FROM 
    pg_catalog.pg_user u 
ORDER BY 
    1; 

SELECT u.usename AS "User Name", u.usesysid AS "User ID" FROM pg_user u;



--Creating groups
A group in the PostgreSQL server is similar to the groups that exist in Unix and Linux. A group
in PostgreSQL serves to simplify the assignment of rights. It simply requires a name and may
be created empty. Once it is created, users who are intended to share common access rights
are added into the group together, and are thus associated by their membership within that
group. Grants on the database objects are then given to the group instead of each individual
group member.

CREATE GROUP dept;

--to assign members/users to the group
ALTER GROUP dept ADD USER agovil,nchabbra;

--It is also possible to create a group and assign users upon its creation
CREATE GROUP admins WITH user agovil,nchabbra;

A group is a system-wide database object that can be assigned privileges and have users
added to it as members. A group is a role that cannot be used to log in to any database.

It is also possible to grant membership in a group to another group, thereby allowing the
member role use of privileges assigned to the group it is a member of.
Database groups are global across a database cluster installation.

SELECT * FROM pg_group;


--Destroying databases
DROP DATABASE hrdb;

$ dropdb hrdb;

The DROP DATABASE statement permanently deletes catalog entries and the data directory.
Only the owner of the database can issue the DROP DATABASE statement.

Also, it is not possible to drop a database to which you are connected. In order to delete the
database, the database owner will have to make a connection to another database of which
he is an owner.

One situation that demands attention is when a user tries to drop a database that has active
connections. The user will get an error when trying to drop such a database.


In order to drop a database that has active connections to it, you will have to follow these steps:

1. Identify all of the active sessions on the database. To identify all of the active
sessions on the database, you need to query the pg_stat_activity catalog
table as follows:

SELECT * from pg_stat_activity where datname='hr';

2. Terminate all of the active connections to the database. To terminate all of the active
connections, you will need to use the pg_terminate_backend function as follows:

SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'hr';

3. Once all of the connections are terminated, you may proceed with dropping the
database using the DROP DATABASE statement.





--Creating and dropping tablespaces
PostgreSQL stores data files consisting of database objects such as tables and indices on the
disk. The tablespace is defined as the location of these objects on the disk. A tablespace is
used to map a logical name to a physical location on the disk.

Before you create the tablespace, the directory location must be physically created and the
directory must be empty:

mkdir –p /var/lib/pgsql/data/dbs

CREATE TABLESPACE data_tbs OWNER hr LOCATION '/var/lib/pgsql/data/dbs';

DROP TABLESPACE data_tbs;

A tablespace allows you to control the disk layout of PostgreSQL. The owner of the tablespace,
by default, would be the user who executed the CREATE TABLESPACE statement. This
statement also gives you the option of assigning the ownership of the tablespace to a new
user. This option is the part of the OWNER clause in the CREATE TABLESPACE statement.

The name of the tablespace should not begin with a pg_ prefix because this is reserved for
the system tablespaces.

Before deleting a tablespace, ensure that it is empty, which means there should be no
database objects inside it. If the user tries to delete the tablespace when it is not empty,
the command will fail.

There are two options that will aid in deleting the tablespace when it is not empty:
1. You may drop the database
2. You may alter the database to move it to a different tablespace

By default, two tablespaces exist in PostgreSQL:
1. pg_default: This is used to store user data
2. pg_global: This is used to store global data

SELECT * FROM pg_tablespace;


--Moving objects between tablespaces
A tablespace can contain both permanent and temporary objects. You will need to define and
create a secondary tablespace to serve as the target destination of objects that might get
moved from the primary tablespace. Moving objects between tablespaces is a mechanism of
copying bulk data in which copying happens sequentially, block by block. Moving a table to
another tablespace locks it for the duration of the move.


--to view existing tables:
SELECT * FROM pg_tablespace;

Here, we will first create a new tablespace, hrms, using the following command:

mkdir –p /var/lib/pgsql/data/hrms

CREATE TABLESPACE HRMS OWNER hr LOCATION '/var/lib/pgsql/data/hrms';



CREATE TABLE EMPLOYEES(id integer PRIMARY KEY , name varchar(40));
INSERT INTO EMPLOYEES VALUES (1, 'Mike Johansson');
INSERT INTO EMPLOYEES VALUES(2, 'Rajat Arora');
CREATE INDEX emp_idx on employees(name);

--Moving a complete database to a different tablespace involves three steps:
1. You will change the tablespace for the given database so that new objects for the
associated database are created in the new tablespace:

ALTER DATABASE testdb1 SET default_tablespace='hrms';

2. You will have to then move all of the existing tables in the corresponding database to
the new tablespace:

ALTER TABLE employee SET TABLESPACE hrms;

3. You will also have to move any existing indexes to the new tablespace:
ALTER INDEX emp_idx SET TABLESPACE hrms;

SELECT * FROM pg_tablespace;

SELECT * FROM pg_tables;

SELECT * FROM pg_indexes;

watch all the available tablespaces, tables and indexes using above 3 commands.
and decide which tables or indexes to move to which tablespace.


--Initializing a database cluster
In terms of a filesystem, a database cluster is a collection of databases that are managed by a
single server instance, and it is the framework upon which PostgreSQL databases are created.

The initdb command is used to initialize or create the database cluster. The –D switch of
the initdb command is used to specify the filesystem location for the database cluster.

$ initdb -D /var/lib/pgsql/data

Another way of initializing the database cluster is by calling the initdb command via the
pg_ctl utility:

$ pg_ctl -D /var/lib/pgsql/data initdb

A database cluster is a collection of databases that are managed by a single server instance.

When the initdb command is triggered, the directories in which the database data will
reside are created, shared catalog tables are generated, and the template1 and postgres
databases are created, out of which the default database is postgres. The initdb
command initializes the database cluster default locale and the character set encoding.


--Starting the server
Before anyone can access the database, the database server must be started. Then you
will be able to start all of the instances of the postgres database in the cluster using the
different commands with options.

The term "server" refers to the database and the associated backend processes. The term
"service" refers to the operating system wrapper through which the server gets invoked. In
normal circumstances, the PostgreSQL server will usually start automatically when the system
boots up. However, there will be situations where you may have to start the server manually
for different reasons.

1. The first method relies on passing the start argument to the pg_ctl utility to get
the postmaster backend process started, which effectively means starting the
PostgreSQL server.

2. The next method relies on using the service commands, which, if supported by the
operating system, can be used as a wrapper to the installed PostgreSQL script.

3. The last method involves invoking the installed PostgreSQL script directly using its
complete path.

On most Unix distributions and Red Hat-based Linux distributions, the pg_ctl utility can be
used as follows:

pg_ctl -D /var/lib/pgsql/data start

service postgresql<version> start
service postgresql-9.3 start

You may also start the server by manually invoking the installed PostgreSQL script using its
complete path:

/etc/rc.d/init.d/postgresql-9.3 start


On Windows-based systems, the PostgreSQL service can be started using the
following command:

NET START postgresql-9.3

The start argument of the pg_ctl utility will first start PostgreSQLs postmaster backend
process using the path of the data directory.

The database system will then start up successfully, report the last time the database system
was shut down, and provide various debugging statements before returning the postgres
user to the shell prompt.

In Ubuntu and Debian Linux distributions, the pg_ctlcluster wrapper can be used with the
start argument to start the postmaster server for a particular cluster. A cluster is a group of
one or more PostgreSQL database servers that may coexist on a single host.


--Stopping the server
There are a couple of ways by which the PostgreSQL server can be stopped.

On Unix distributions and Red Hat-based Linux distributions, we can use the stop argument
of the pg_ctl utility to stop the postmaster:

pg_ctl -D /var/lib/pgsql/data stop -m fast

Using the service command, the PostgreSQL server can be stopped like this:
service postgresql stop

You may also stop the server by manually invoking the installed PostgreSQL script using its
complete path:
/etc/rc.d/init.d/postgresql stop

On Windows-based systems, you may stop the postmaster service in this manner:
NET STOP postgresql-9.3

The pg_ctl utility checks for the running postmaster process, and if the stop argument of
the pg_ctl utility is invoked, then the server is shut down.

By default, the PostgreSQL server will wait for clients to first cancel their connections before
shutting down.

However, with the use of a fast shutdown, there is no wait time involved as all of the user
transactions will be aborted and all connections will be disconnected.


There may be situations where one needs to stop the PostgreSQL server in an emergency
situation, and for this, PostgreSQL provides the immediate shutdown mode.
In case of immediate shutdown, a process will receive a harsher signal and will not be able to
respond to the server anymore.
The consequence of this type of shutdown is that PostgreSQL is not able to finish its disk I/O,
and therefore has to do a crash recovery the next time it is started.
The immediate shutdown mode can be invoked like this:

pg_ctl -D /var/lib/pgsql/data stop -m immediate


Another way to shut down the server would be to send the signal directly using the kill
command. The PID of the postgres process can be found using the ps command or from
the postmaster.pid file in the data directory. In order to initiate a fast shutdown, you can
issue the following command:
$ kill -INT head -1 /usr/local/pgsql/data/postmaster.pid


--Displaying the server status
Many a times, there will be situations where end users complain that the database performance
is sluggish and they are not able to log in to the database. In such situations, it is often helpful
to take a quick glance through the status of the PostgreSQL backend postmaster process and
confirm whether the PostgreSQL server services are up and running.

On Unix and on Red Hat-based Linux distributions, the status argument of the pg_ctl utility
can be used to check the status of a running postmaster backend:
pg_ctl -D /var/lib/pgsql/data status

On Unix-based and Linux-based platforms supporting the service command, the status of a
postgresql process can be checked as follows:
service postgresql status

You may also check the server status by manually invoking the installed PostgreSQL script
using its complete path:
/etc/rc.d/init.d/postgresql status


The status mode of the pg_ctl utility checks whether the postmaster process is running in
the specified data directory.

If the server is running, then the process ID and the command-line options that were used to
invoke it are displayed.

--Reloading the server configuration files
Changes made to certain PostgreSQL configuration parameters come into effect when the
server configuration files, such as postgresql.conf, are reloaded.

On most Unix-based and Linux-based platforms, the command to reload the server
configuration file is as follows:
pg_ctl -D /var/lib/pgsql/data reload

It is also possible to reload the configuration file while being connected to a PostgreSQL
session. However, this can be done by the superuser only:
postgres=# select pg_reload_conf();

On Red Hat and other Linux-based systems that support the service command, the
postgresql command to reload the configuration file is as follows:
service postgresql reload


To ensure that changes made to the parameters in the configuration file take effect, a reload
of the configuration file is needed. Reloading the configuration files requires sending the
sighup signal to the postmaster process, which in turn will forward it to the other connected
backend sessions.


There are some configuration parameters whose changed values can only be reflected by
a server reload. These configuration parameters have a value known as sighup for the
attribute context in the pg_settings catalog table:

SELECT name, setting, unit ,(source = 'default') as is_default FROM
pg_settings WHERE context = 'sighup'
AND (name like '%delay' or name like '%timeout')
AND setting != '0';


--Terminating connections
Every major RDBMS, including PostgreSQL, allows simultaneous and concurrent database
connections in order for users to run transactions. Due to such concurrent processing of
databases, it may be during peak transaction hours that database performance becomes
slow or that there are some blocking sessions. In order to deal with such situations, we might
have to terminate some specific sessions or sessions coming from a particular user so that we
can get database performance back to normal.

PostgreSQL provides the pg_terminate_backend function to kill a specific session. Even
though the pg_terminate_backend function acts on a single connection at a time, we can
embed pg_terminate_backend by wrapping it around the SELECT query to kill multiple
connections, based on the filter criteria specified in the WHERE clause.

To terminate all of the connections from a particular database, we can use the
pg_terminate_backend function as follows:

SELECT pg_terminate_backend(pid) FROM pg_stat_activity
WHERE datname = 'testdb1';

To terminate all of the connections for a particular user, we can use pg_terminate_
backend like this:

SELECT pg_terminate_backend(pid) FROM pg_stat_activity
WHERE usename = 'agovil';


The pg_terminate_backend function requires the pid column or process ID as input.
The value of pid can be obtained from the pg_stat_activity catalog table. Once
pid is passed as input to the pg_terminate_backend function, all running queries will
automatically be canceled and it will terminate a specific connection corresponding to the
process ID as found in the pg_stat_activity table.

Terminating backends is also useful to free memory from idle postgres processes that was
not released for whatever reason and was hogging system resources.


If the requirement is to cancel running queries and not to terminate existing sessions, then
we can use the pg_cancel_backend function to cancel all active queries on a connection.
However, with the pg_cancel_backend function, we can only kill runaway queries issued in
a database or by a specific user. It does not have the ability to terminate connections.

To cancel all of the running queries issued against a database, we can use the pg_cancel_
backend function as follows:

SELECT pg_cancel_backend(pid) FROM pg_stat_activity
WHERE datname = 'testdb1';

To cancel all of the running queries issued by a specific user, we can use the pg_cancel_
backend function like this:

SELECT pg_cancel_backend(pid) FROM pg_stat_activity
WHERE usename = 'agovil';


page27 2nd chapter