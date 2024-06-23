Convert Physical Standby into Snapshot Standby

One of the most powerful feature of Oracle Data Guard is Snapshot Standby. Let's assume that application team wants to test something 
on production data. Rather than cloning prod, we can convert existing physical standby into snapshot standby, perform the testing and 
convert it back to physical standby.

We can always revert back snapshot standby to the point when we converted it to snapshot standby from physical standby. This way we 
can repeat the cycle any number of times, perform testing, convert back to physical standby and sync back again with production.

Convert physical standby to snapshot standby: We will now convert the physical standby database to snapshot standby

On standby:
===========
SQL> alter database recover managed standby database cancel;
SQL> select name, open_mode from v$database; 		>> make sure its mounted
SQL> alter database convert to snapshot standby;
SQL> alter database open;				>> open the DB
SQL> select name, open_mode, database_role from v$database;

Verifying snapshot standby: Now you must be able to read-write on snapshot standby. Meanwhile, we can even check the standby 
alert log. The archives received from primary are not applied on standby. We can even check that there is a guaranteed restore 
point has been created. So that when you convert snapshot back to physical standby, it will be used. 

Also Note: For this snapshot standby, you do not need Flashback enabled at database level

On standby:
===========
SQL> select name, guarantee_flashback_database from v$restore_point;
SQL> create table student(sno number(2), s_name varchar2(10));
SQL> insert into student values(1,'RAM');
SQL> insert into student values (2,'Max');
SQL> commit;
SQL> select * from student;

Revert back snapshot standby to physical standby: Once application testing is done, you can revert back snapshot standby 
to same point when it was converted from physical standby to snapshot standby

On standby:
===========
SQL> select name, open_mode, database_role from v$database;
SQL> shut immediate;
SQL> startup mount;
SQL> alter database convert to physical standby;
SQL> shutdown immediate;
SQL> startup mount;
SQL> alter database recover managed standby database disconnect;
SQL> select * from student;
