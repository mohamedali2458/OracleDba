Convert Physical Standby into Active Data Guard

Active Data Guard is a feature of Oracle Database that allows the physical standby database to be open for read-only 
and reporting operations while continuously applying changes from the primary database in real-time. 

    Enable Active Data Guard 
    Verify MRP is Running 
    Test Active Data Guard 
    Revert Back to Physical Standby 

In very simple terms, when you open Physical Standby in read only mode, it is known as Active Data Guard. But, Active 
Data Guard needs license for and you must check with Oracle for same before implementing it.

Enable Active Data Guard

Let us Open Physical Standby and test active data guard

On standby:
===========
SQL> alter database recover managed standby database cancel;
SQL> alter database open;
SQL> select name, open_mode, database_role from v$database;
SQL> alter database recover managed standby database disconnect;

Verify MRP is Running

Use below query to check if MRP is running in the background or not

On standby (active data guard):
===============================
SQL> select process, status, sequence# from v$managed_standby;

Test Active Data Guard

As our active data guard is open for read only queries and background recover is active, let us create a 
table on primary and see if it is reflected on standby

On primary:
===========
SQL> create table test(sno number(2),sname varchar2(10));
SQL> insert into test values (1, 'John ');
SQL> commit;
SQL> alter system switch logfile;

On standby:
===========
SQL> select * from test;

Revert back to physical standby

If you want to convert active data guard back to physical standby, follow below commands

On standby:
===========
SQL> alter database recover managed standby database cancel;
SQL> shutdown immediate;
SQL> startup mount;
SQL> select name, open_mode, database_role from v$database;
SQL> alter database recover managed standby database disconnect;
SQL> select process, status, sequence# from v$managed_standby;
