Database Roles

What are Roles : Roles are named groups of related privileges to make DBA’s job easier.

How to use Roles

Step 1
Create role hr_users;

Step 2
Grant select on hr.employees to hr_users;
Grant select on hr.jobs to hr_users;
Grant all on hr.regions to hr_users;
Grant delete on hr.departments to hr_users;
Grant create session to hr_users;

Step 3
Grant hr_users to shekhar;
Grant hr_users to alex;


Role Authentication
Create role hr_users identified by hard_password;


Predefined Roles
================
CONNECT : Privilege to connect to the database, to create a cluster, a database link,
a sequence, a synonym, a table, and a view, and to alter a session.

RESOURCE : Privilege to create a cluster, a table, and a sequence, and to create 
programmatic objects such as procedures, functions, packages, indextypes, types,
triggers, and operators.

DBA : All system privileges with the ADMIN option, so the system privileges can be
granted to other users of the database or to roles.

SELECT_CATALOG_ROLE : Ability to query the dictionary views and tables.

EXP_FULL_DATABASE : Ability to make full and incremental exports of the database
using the Export utility.

IMP_FULL_DATABASE : Ability to perform full database imports using the Import utility.
This is a very powerful role.

Guidelines
==========
    • Developers : Connect, resource, select_catalog_role
    • DBAs : DBA
    • Production users : create session & specific roles

ADMIN OPTION
• Roles can be granted with “ADMIN OPTION”
• Grant role hr_app to alex with ADMIN option. --> Now alex can grant hr_app role to other users

Example:
CREATE ROLE APP_QUERY;
CREATE ROLE APP_UPDATE IDENTIFIED BY PWD;

Now, grant SELECT privileges on tables to the APP_QUERY role, and grant INSERT, UPDATE and
DELETE privileges on tables to the APP_UPDATE role.

GRANT APP_QUERY, APP_UPDATE TO CHRIS;

ALTER USER CHRIS DEFAULT ROLE APP_QUERY;

Inside the web application code program this command -->
SET ROLE APP_UPDATE IDENTIFIED BY PWD;

Users using sqlplus, Access will not be able to change
data. But they can change the data when logged in through
web application.

MAX_ENABLED_ROLES --> max number of roles that user can enable

Data Dictionary
===============
    o DBA_ROLES (list of roles in the instance)
    o SESSION_ROLES (currently enabled roles)
    o DBA_ROLE_PRIVS (privileges assigned to roles)
    o ROLE_TAB_PRIVS (table privileges assigned to roles)
