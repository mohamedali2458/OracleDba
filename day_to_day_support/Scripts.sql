--How to check users, roles and privileges in Oracle

--Query to check the granted roles to a user

SELECT *
FROM DBA_ROLE_PRIVS
WHERE GRANTEE = '&USER';

--Query to check privileges granted to a user

SELECT *
FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'USER';

--Privileges granted to a role which is granted to a user

SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE IN
(SELECT granted_role FROM DBA_ROLE_PRIVS WHERE GRANTEE = '&USER') order by 3;

--Query to check if user is having system privileges

SELECT *
FROM DBA_SYS_PRIVS
WHERE GRANTEE = '&USER';

--Query to check permissions granted to a role

select * from ROLE_ROLE_PRIVS where ROLE = '&ROLE_NAME';
select * from ROLE_TAB_PRIVS where ROLE = '&ROLE_NAME';
select * from ROLE_SYS_PRIVS where ROLE = '&ROLE_NAME';

