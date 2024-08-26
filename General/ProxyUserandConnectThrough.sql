Proxy User
==========
1. Overview
-- We want to login to database with user scott, but i don't the password.
-- We can change the scott's user password, but i don't want to do this,
   becuase some apps jobs might be  interrupted
-- It is possible using Proxy User and Connect Through


2. Grant Proxy authentication

CONN / AS SYSDBA

CREATE USER test_raj IDENTIFIED BY raj; <-- create dummy user

ALTER USER scott GRANT CONNECT THROUGH test_raj;

CONN test_raj[scott]/raj

SHOW USER


Output

SQL> CONN / AS SYSDBA
Connected.
SQL> CREATE USER test_raj IDENTIFIED BY raj;

User created.

SQL> ALTER USER scott GRANT CONNECT THROUGH test_raj;

User altered.

SQL> CONN test_raj[scott]/raj
Connected.
SQL> SHOW USER
USER is "SCOTT"
SQL> select count(*) from emp;

  COUNT(*)
----------
        14

SQL>


3. List Proxy Users

SQL> conn / as sysdba
Connected.
SQL> SELECT * FROM proxy_users;

PROXY     CLIENT  AUT FLAGS
--------- ------- --- -----------------------------------
TEST_RAJ  SCOTT   NO  PROXY MAY ACTIVATE ALL CLIENT ROLES

SQL>


4. Revoke Proxy authentication

SQL> conn / as sysdba
Connected.
SQL> ALTER USER scott REVOKE CONNECT THROUGH test_raj;

User altered.

SQL> SELECT * FROM proxy_users;

no rows selected

SQL>

SQL> CONN test_raj[scott]/raj
ERROR:
ORA-28150: proxy not authorized to connect as client


Warning: You are no longer connected to ORACLE.
SQL>


