3. Backup and Recovery

Backups are divided into two components: 1. Physical Backups, and 2. Logical Backups.

Logical backups: A logical backup refers to the dump file that is created by the
pg_dump utility and which might be used to restore the database in the case of
a data loss or an accidental deletion of a database object, such as a table.

Physical backups: A physical backup refers to the OS level backup of a database
directory and its associated files.

--A logical backup of a single PostgreSQL database

The pg_dump utility is used to back up a PostgreSQL database. It does make consistent
backups even if the database is being used by other transactions. Dumps can be created
in script or in archive file formats. Script dumps are usually plain text files that contain the
SQL commands required to reconstruct the database to the state it was in at the time it
was saved. Script dumps can also be used to reconstruct the database on other machines
and architectures.

pg_dump -U username -W -F t database_name > [Backup Location Path]

U switch: The -U switch specifies the database user initiating the connection. As
pg_dump is a command-line utility, we need to specify the username via which the
pg_dump utility can make a database connection.

W switch: This option is not mandatory. This option forces pg_dump to prompt for
the password before connecting to the PostgreSQL database server. After you press
Enter, pg_dump will prompt for the password of the database user from which the
connection is initiated.

F switch: The -F switch specifies the output file format that will be used.
We specified the t option with the -F switch because the output file will be
implemented as a tar format archive file.

method - 1

pg_dump -U postgres -W -F t dvdrental > /home/abcd/dvdrental.tar

pg_dump -U postgres -W -F t dvdrental > C:\Program Files\PostgreSQL\backup\dvdrental.tar

method - 2

using pgadmin gui tool


pg_dump -u postgres -h 192.168.16.54 -F c -f
dvdrental.sql.tar.gz dvdrental


--A logical backup of all PostgreSQL databases

\l --note down the db to take logical backup
pg_dump --on each database
pg_dumpall --single command for all databases

--pg_dump doesnot dump the roles and tablespaces, so we need to use pg_dumpall to dump the roles and tablespaces.
pg_dumpall -g

pg_dumpall -U postgres > c:\pgbackup\all.sql

pg_dumpall -U postgres > /home/pgbackup/all.sql

pg_dumpall --schema-only > c:\pgdump\definitiononly.sql

pg_dumpall --roles-only > c:\pgdump\myroles.sql

pg_dumpall --tablespaces-only > c:\pgdump\mytablespaces.sql


--A logical backup of specific objects
pg_dump -h localhost -p 5432 -U agovil -F c -b -v -f "C:\pgbak\testdb_test.backup" -t case.test postgres

page-60