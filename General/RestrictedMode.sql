Start the database in restrict mode
===================================
Restrict Mode in which Oracle database allow making connection with special 
rights such as DBA, SYSDBA to perform the maintenance activity like rebuilding 
index, remove fragmentation etc.  It is very useful for DBA for start database 
in restricted mode for planned maintenance activity.  So, no other user such 
as application users are able to connect with database until they have special rights.

SQL> shutdown immediate;

Start the database in restricted mode, so, no other user able to connect:

SQL> startup restrict;

Check the database in restricted mode

SQL> select logins from v$instance;
LOGINS
--------
RESTRICTED

Disable the session restricted mode or you can normal start the database.

SQL> alter system disable restricted session;

Check the status that restricted mode is disable:

SQL> select logins from v$instance;
LOGINS
------
ALLOWED

Without restart the database, we put it in restricted mode:

SQL> alter system enable restricted session;

Note: If restricted session is blocked by some session.  May need to kill 
them if urgent.  Check from v$session.
