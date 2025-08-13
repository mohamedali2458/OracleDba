--Oracle Auditing
Types of Auditing 

1. Standard Auditing: Traditional method using audit statements
2. Unified Auditing: Combines all audit data (introduced in 12c)
3. Fine-grained Auditing(FGA): Row-Level Auditing using DBMS_FGA Package

https://www.youtube.com/watch?v=YCY4z26nshQ

--standard auditing 

create table audit_test(
    id DBMS_RANDOM.
    name varchar2(100)
);

AUDIT SELECT, INSERT, DELETE ON audit_test BY ACCESS;

INSERT INTO audit_test VALUES (1, 'Ali');

SELECT * FROM audit_test;

DELETE FROM audit_test WHERE id = 1;

commit;

sqlplus / as sysdba 

SELECT username, action_name, obj_name, timestamp 
FROM dba_audit_trail 
WHERE obj_name = 'AUDIT_TEST';

--FGA 
===
This is row level.

CREATE TABLE fga_test(
    emp_id NUMBER,
    emp_name VARCHAR2(50),
    salary NUMBER
);

INSERT INTO fga_test VALUES(101, 'Ali', 18000);
INSERT INTO fga_test VALUES(102, 'Kumar', 9000);
COMMIT;


--CREATE A POLICY
BEGIN 
    DBMS_FGA.add_policy(
        object_schema       => 'SCOTT',
        object_name         => 'FGA_TEST',
        policy_name         => 'high_salary_audit',
        audit_condition     => 'salary > 10000',
        audit_column        => 'SALARY'
    );

SELECT emp_id, salary FROM fga_test WHERE salary > 15000;

SELECT db_user, object_schema, object_name, sql_text, timestamp 
FROM dba_fga_audit_trail
WHERE object_name = 'FGA_TEST';


--Unified Auditing (OS level)

CREATE AUDIT POLICY user_login_audit 
ACTIONS LOGON, LOGOFF;

AUDIT POLICY user_login_audit BY SCOTT;

--perform few logins and logouts

SELECT dbusername, action_name, event_timestamp, object_name, unified_audit_policies
FROM unified_audit_trail
WHERE dbusername = 'SCOTT'
ORDER BY event_timestamp desc;

