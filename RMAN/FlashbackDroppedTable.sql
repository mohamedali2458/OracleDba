What is Flashback Drop?

The Flashback Drop feature in Oracle Database allows us to recover 
a dropped table from the Recycle Bin. When we drop a table (without 
using the PURGE option), Oracle does not immediately delete it. 
Instead, it renames the table and moves it to the Recycle Bin, 
making it possible to restore it later.

Prerequisites for Using Flashback Drop:-
Recycle Bin Enabled
Table Not Purged

1. Check Recycle Bin Enabled:-
sqlplus / as sysdba
sqlplus "/ as sysdba"
show parameter recyclebin

sqlplus ali/pass@pdb1
show user;
select count(*) from test;

2. Dropping the table:-
drop table test;

When we drop the table without the PURGE option, Oracle moves it to the Recycle Bin instead of permanently
deleting it.

3. Verify the Table in the Recycle Bin:-
show recyclebin;

set linesiize 300
col object_name for a30
col original_name for a30
SELECT object_name, original_name, type, droptime FROM recyclebin;

= > Note that when we drop the table, it will not be moved to FRA or undo tablespace. 
  It will be in the same TABLESPACE, but only the metadata will be changed in the 
  data dictionary – like it will be changing its ORIGINAL NAME with SYSTEM GENERATED NAME.

= > We cannot recover a table dropped from the SYSTEM tablespace 
using the Flashback Drop option.

= > We cannot perform DDL/DML over an object in the recycle bin, but 
we can query the data using its system generated name.

show recyclebin;

select * from "system generated name";

select * from "system generated name" where rownum < 3;


4. Recovering the table using Flashback Drop:-
FLASHBACK TABLE TEST TO BEFORE DROP;
SELECT COUNT(*) FROM TEST;

If we want to recover the table under a different name: (optional)

FLASHBACK TABLE test TO BEFORE DROP RENAME TO test_bkp;

