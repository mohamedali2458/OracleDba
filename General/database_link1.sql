https://www.br8dba.com/database-link/

Database link
1. Overview
2. Environment
3. Add TNS Entry
4. List db links
5. Create PUBLIC db link
6. Create PRIVATE db link
7. List db links again
8. Verify the db link results
9. Drop Public Database link
10. Drop Private Database link


1. Overview

A database link (DBlink) is a definition of how to establish a connection from one Oracle database to another.

Type of Database Links:
Private database link - belongs to a specific schema of a database. Only the owner of a private database link can use it.
Public database link - all users in the database can use it.
Global database link - defined in an OID or Oracle Names Server. Anyone on the network can use it.

How to find Global name? 
set linesize 300
col global_name for a200
SELECT * FROM global_name;


2. Environment

Source Details

Hostname: rac1.rajasekhar.com

DB Name: w148p

Schema name/password: scott/tiger

TNS Entry: 

w148p =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac1.rajasekhar.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = w148p)
    )
  )


Target Details

Hostname: rac2.rajasekhar.com

DB Name: CAT

Schema name/password: test/test

TNS Entry: 

CAT =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac2.rajasekhar.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cat)
    )
  )


3. Add TNS Entry

Add target db TNS entry in source database tnsnames.ora

CAT =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac2.rajasekhar.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cat)
    )
  )


4. List db links

SQL> select * from dba_db_links;
no rows selected


5. Create PUBLIC database link

-- create public db link On Source db W148P 

We want to access the TEST schema objects (resides on CAT database) from source db (w148p Database) 

SQL> select name, open_mode from v$database;
NAME      OPEN_MODE
--------- ----------
W148P     READ WRITE

SQL> show user
USER is "SYS"


CREATE PUBLIC DATABASE LINK link_name
CONNECT TO remote_user_name
IDENTIFIED BY remote_user_password
USING 'remote_service_name';

SQL> CREATE PUBLIC DATABASE LINK test_remote
   CONNECT TO test IDENTIFIED BY test
   USING 'CAT';
Database link created.


--- OR ---

-- Create Public db link without modify TNS entry

CREATE PUBLIC DATABASE LINK test_remote1
 CONNECT TO test IDENTIFIED BY test
 using
 '(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac2.rajasekhar.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cat)
    )
  )'
  /

SQL> show user
USER is "SYS"

SQL> CREATE PUBLIC DATABASE LINK test_remote1
 CONNECT TO test IDENTIFIED BY test
   using
   '(DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = rac2.rajasekhar.com)(PORT = 1521))
      (CONNECT_DATA =
        (SERVER = DEDICATED)
        (SERVICE_NAME = cat)
      )
    )'
    /
Database link created.


-- OR --

-- Create PUBLIC DB Link Using EASY CONNECT

SQL> CREATE PUBLIC DATABASE LINK test_remote2
CONNECT TO test IDENTIFIED BY test
USING 'rac2.rajasekhar.com:1521/CAT';
Database link created.


6. Create PRIVATE database Link

Private database link belongs to a specific schema of a database. 

Only the owner of a private database link can use it.

CREATE DATABASE LINK link_name
CONNECT TO remote_user_name
IDENTIFIED BY remote_user_password
USING 'remote_service_name';

SQL> grant create database link to scott;
Grant succeeded.

SQL> conn scott/tiger; <-- If you don't know password then use proxy user . PROXY USER
Connected.

SQL> CREATE DATABASE LINK REMOTE_PRIVATE1
   CONNECT TO test IDENTIFIED BY test
   USING 'CAT';
Database link created.


-- OR --

-- Create PRIVATE db link without modify TNS entry

CREATE DATABASE LINK REMOTE_PRIVATE2
 CONNECT TO test IDENTIFIED BY test
 using
 '(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = rac2.rajasekhar.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cat)
    )
  )'
  /

SQL> CREATE DATABASE LINK REMOTE_PRIVATE2
 CONNECT TO test IDENTIFIED BY test
   using
   '(DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = rac2.rajasekhar.com)(PORT = 1521))
      (CONNECT_DATA =
        (SERVER = DEDICATED)
        (SERVICE_NAME = cat)
      )
    )'
    /
Database link created.

  
-- OR --
-- Create DB Link Using EASY CONNECT

SQL> CREATE DATABASE LINK REMOTE_PRIVATE3
CONNECT TO test IDENTIFIED BY test
USING 'rac2.rajasekhar.com:1521/CAT';
Database link created.


SQL> conn / as sysdba
Connected.

SQL> revoke create database link from scott; <----
Revoke succeeded.


7. List database links again

SQL> set lines 180 pages 999
SQL> col owner for a15
SQL> col DB_LINK for a15
SQL> col USERNAME for a15
SQL> col HOST for a39
SQL> col CREATION_DATE for a20
SQL> select owner, db_link, username, host , to_char(created,'MM/DD/YYYY HH24:MI:SS') creation_date from dba_db_links;

OWNER           DB_LINK         USERNAME        HOST                                    CREATION_DATE
--------------- --------------- --------------- --------------------------------------- --------------------
PUBLIC          TEST_REMOTE     TEST            CAT                                     11/06/2016 21:02:22

PUBLIC          TEST_REMOTE1    TEST            (DESCRIPTION =                          11/06/2016 21:37:58
                                                    (ADDRESS = (PROTOCOL = TCP)(HOST =
                                                rac2.rajasekhar.com)(PORT = 1521))
                                                    (CONNECT_DATA =
                                                      (SERVER = DEDICATED)
                                                      (SERVICE_NAME = cat)
                                                    )
                                                  )

PUBLIC          TEST_REMOTE2    TEST            rac2.rajasekhar.com:1521/CAT            11/06/2016 21:43:00

SCOTT           REMOTE_PRIVATE1 TEST            CAT                                     11/06/2016 22:10:47

SCOTT           REMOTE_PRIVATE2 TEST            (DESCRIPTION =                          11/06/2016 22:11:25
                                                    (ADDRESS = (PROTOCOL = TCP)(HOST =
                                                rac2.rajasekhar.com)(PORT = 1521))
                                                    (CONNECT_DATA =
                                                      (SERVER = DEDICATED)
                                                      (SERVICE_NAME = cat)
                                                    )
                                                  )

SCOTT           REMOTE_PRIVATE3 TEST            rac2.rajasekhar.com:1521/CAT            11/06/2016 22:12:13

6 rows selected.


8. Verify the db link results

-- Since it is public db link any user in source database can access the TEST schema objects of targert db

-- Even new user can access. eg.... create new user <----

--- verfiy public db links ---

SQL> create user one identified by one; <----

User created.

SQL> grant connect to one;

Grant succeeded.

SQL> conn one/one; <----
Connected.
SQL> select count(*) from sales@TEST_REMOTE; <-- with TNS entry

  COUNT(*)
----------
    918843

SQL> select count(*) from sales@TEST_REMOTE1; <-- with TNS Connect String

  COUNT(*)
----------
    918843

SQL> select count(*) from sales@TEST_REMOTE2; <-- Easy connect string

  COUNT(*)
----------
    918843

SQL>

--- verfiy private db links ---

Private database link belongs to a specific schema of a database. 

Please note only the owner of a private database link can use it.

SQL> conn scott/tiger;
Connected.
SQL> select count(*) from sales@REMOTE_PRIVATE1; <-- With TNS Entry

  COUNT(*)
----------
    918843

SQL> select count(*) from sales@REMOTE_PRIVATE2;<-- TNS connect string

  COUNT(*)
----------
    918843

SQL> select count(*) from sales@REMOTE_PRIVATE3; <-- Easy connect

  COUNT(*)
----------
    918843

SQL>



9. Drop Public Database link

-- Please login as owner of db link

SQL> drop public database link TEST_REMOTE;

Database link dropped.

SQL> drop public database link TEST_REMOTE1;

Database link dropped.

SQL> drop public database link TEST_REMOTE2;

Database link dropped.

SQL>



10. Drop Private Database link

-- Please login as owner of db link

SQL> conn scott/tiger; <----
Connected.
SQL> drop database link REMOTE_PRIVATE1;

Database link dropped.

SQL> drop database link REMOTE_PRIVATE2;

Database link dropped.

SQL> drop database link REMOTE_PRIVATE3;

Database link dropped.

SQL>

SQL> conn / as sysdba
Connected.
SQL> select * from dba_db_links;

no rows selected <----

SQL>



