Export from 11g and import to 19c

Step 1. Create a backup directory

To perform the export/import first we need to create a backup directory at the OS level as well as Database level using the following steps.

$mkdir -p /u01/expdp_bkp

Now login in Database using sys user and create the directory at the database level:

SQL> create directory expdp_bkp as '/u01/expdp_bkp';

We can perform export and import activity with the sys user and using any 
other database schema. If you are performing this activity using a sys 
user then you dont need to grant any privileges because sys user is a 
database supper user. But if you want to perform this activity with 
other Database schema then you must execute the following commands 
from the sys user.

Suppose our schema name is RAHUL.

SQL> grant exp_full_database, imp_full_database to RAHUL;
SQL> grant read,write on directory expdp_bkp to RAHUL;

Step 2. Take Full Export from 11g Database

Now we need to take an export backup from the 11g Database using the following command.

$expdp username/password@dbname full=y directory=expdp_bkp dumpfile=full_db_09-sep-2023.dmp logfile=full_db_09-sep-2023.log

Make sure to replace "username", "password" and "dbname" with the appropriate values. 
The above command will create an export file named "full_db_09-sep-2023.dmp" 
containing the exported data and a log file "full_db_09-sep-2023.log" 
for any error messages.

If you want to move only a single schema then use the following 
command, my schema name is "DIGITAL".

$expdp username/password@dbname schemas=digital directory=expdp_bkp dumpfile=digital_db_09-sep-2023.dmp logfile=digital_db_09-sep-2023.log

Or if you want to move only one table then use the following command:

$expdp username/password@dbname tables=ocp directory=expdp_bkp dumpfile=ocp_db_09-sep-2023.dmp logfile=ocp_db_09-sep-2023.log

Step 3. Check tablespaces 

Before importing the above data in Oracle 19c you must check 
the existing tablespaces detail in the Oracle 11g database, 
and create the same tablespaces in the Oracle 19c Database 
as well otherwise you will face errors related to tablespaces. 
You can check the existing tablespace details using the 
following command:

SQL> select name from v$tablespace;

Step 4. Transfer the export file to the Oracle Database 19c server

Transfer the export file "full_db_09-sep-2023.dmp" from the 11g 
server to the Oracle 19c server and you can use any preferred 
method such as FTP or SCP.

$scp /u01/expdp_bkp/full_db_09-sep-2023.dmp oracle@19c_machine_ip:/u02/expdp_bkp

Step 5. Import 11g Data to 19c oracle

It is time to import the data in Oracle 19c using the "impdp" 
command, but before executing the impdp command you must check 
the backup which you copy from the 11g machine it should be at 
the directory location. For directory creation, you can check 
the step number 1.

$impdp username/password@dbname directory=expdp_bkp dumpfile=full_db_09-sep-2023.dmp logfile=imp_full_db_09-sep-2023.log

