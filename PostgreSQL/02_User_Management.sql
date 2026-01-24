User Management
===============
Create Users, Groups and Schema Paths for PostgreSQL

1: Create a User

CREATE USER john WITH PASSWORD 'mypassword';

CREATE ROLE john LOGIN PASSWORD 'mypassword';

2: Change User Password
Passwords can be changed by either an admin or the user.

postgres=# ALTER USER john WITH PASSWORD 'newpassword';
