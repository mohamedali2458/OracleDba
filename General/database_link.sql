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
