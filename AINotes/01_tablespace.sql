To add space to a tablespace in Oracle, you typically have three options: 
adding a new datafile, 
resizing an existing datafile, or 
enabling autoextend on a datafile.

Here is the syntax for each method.

1. Add a New Datafile
This is the most common method. You add a distinct new file to the tablespace.

sql

ALTER TABLESPACE tablespace_name
ADD DATAFILE '/path/to/new_file.dbf'
SIZE 1G;

Replace /path/to/new_file.dbf with the actual path where you want the file created.

2. Resize an Existing Datafile
If you have an existing datafile that isnt at its maximum size 
limit and you have disk space available, you can strictly resize 
it to be larger.

First, identify the file name:

sql

SELECT file_name, bytes/1024/1024 AS size_mb 
FROM dba_data_files 
WHERE tablespace_name = 'YOUR_TABLESPACE_NAME';

Then resize it:

sql

ALTER DATABASE DATAFILE '/path/to/existing_file.dbf' 
RESIZE 2G;

3. Enable Autoextend
You can set a datafile to automatically grow as needed, up to a specific limit (or unlimited).

sql

ALTER DATABASE DATAFILE '/path/to/existing_file.dbf'
AUTOEXTEND ON
NEXT 100M
MAXSIZE 10G; -- Or use UNLIMITED

Summary of Differences
Method	        Best Used When...
Add Datafile	You want to spread I/O across different disks or the current file is excessively large.
Resize	        You want to manually control space allocation without adding more file handles.
Autoextend	    You want to minimize maintenance ("set it and forget it"), but keep an eye on underlying disk space.




Key Tablespace Management Tasks:
1. View Tablespace Information
-- List all tablespaces
SELECT tablespace_name, status, contents FROM dba_tablespaces;

-- Check tablespace size and free space
SELECT tablespace_name, 
       SUM(bytes)/1024/1024 AS total_mb,
       SUM(free_space)/1024/1024 AS free_mb,
       ROUND((SUM(free_space)/SUM(bytes))*100, 2) AS free_percent
FROM dba_free_space
GROUP BY tablespace_name;

-- View datafiles in a tablespace
SELECT file_name, bytes/1024/1024 AS size_mb, autoextensible
FROM dba_data_files 
WHERE tablespace_name = 'USERS';

2. Create a Tablespace
CREATE TABLESPACE ts_name
DATAFILE '/u01/oradata/ts_name01.dbf' SIZE 1G
AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;

3. Add Space (As in your file)
Add datafile (for distribution across disks)
Resize existing datafile
Enable autoextend (automated growth)

4. Shrink Tablespace Space
-- Reclaim unused space from a datafile
ALTER DATABASE DATAFILE '/path/to/file.dbf' RESIZE 500M;

5. Drop Tablespace
DROP TABLESPACE ts_name INCLUDING CONTENTS AND DATAFILES;

6. Monitor Growth
SELECT tablespace_name, 
       MAX(bytes)/1024/1024/1024 AS maxsize_gb,
       SUM(bytes)/1024/1024/1024 AS current_gb
FROM dba_data_files
GROUP BY tablespace_name;
