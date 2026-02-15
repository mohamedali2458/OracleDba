Database Link
=============
Create Database Link

CREATE DATABASE LINK local
CONNECT TO hr IDENTIFIED BY hr
USING 'remotehr';

  • 'Remotehr' is the connection string which points to the remote instance.
  • This entry is in the tnsnames.ora of client

Write SQL using database link
=============================
SELECT * FROM employees@local;

INSERT INTO employees@local (employee_id, last_name,email, hire_date, job_id) 
VALUES (999, 'Claus','sclaus@oracle.com', SYSDATE, 'SH_CLERK');

UPDATE jobs@local SET min_salary = 3000 WHERE job_id = 'SH_CLERK';

DELETE FROM employees@local WHERE employee_id = 999;

Select * from employees
Minus
Select * from employees@local;

Create synonym using remote database
====================================
CREATE SYNONYM emp_table
FOR oe.employees@remote.us.oracle.com;







Day 28 | Oracle DBA Learning Series
===================================
Topic: DB Links in Oracle DBA (With Commands)

A Database Link (DB Link) allows one Oracle database to access objects in another Oracle database.

A DB Link is a bridge between two databases.
📌  How It Works ?
a) Query uses @dblink_name
b) Oracle connects using TNS entry
c) Authentication happens
d) Data is fetched from remote DB

Types of DB Links & Commands
1) Private DB Link
Accessible only to the user who creates it.
SQL>CREATE DATABASE LINK remote_db
CONNECT TO hr IDENTIFIED BY password
USING 'ORCL' ;

2) Public DB Link
Accessible to all users in the database.
SQL> CREATE PUBLIC DATABASE LINK remote_db
CONNECT TO hr IDENTIFIED BY password
USING 'ORCL' ;

Using a DB Link
a) Query remote table:
SQL> SELECT * FROM employees@remote_db;
b) Insert into remote table:
SQL> INSERT INTO employees@remote_db VALUES (...);

Drop a DB Link
PRIVATE 👇 
SQL> DROP DATABASE LINK remote_db;
PUBLIC 👇 
SQL> DROP PUBLIC DATABASE LINK remote_db;

🔹 DBA Best Practices
  a) Avoid hardcoding passwords & Prefer private over public DB links
  b) Monitor performance & Drop unused DB links