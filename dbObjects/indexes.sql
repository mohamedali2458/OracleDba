SQL> create table scott.test as select * from dba_objects;
SQL> create index scott.normal_idx on scott.test(object_id);
SQL> create index scott.composite on scott.test(object_id,data_object_id);
SQL> create index scott.functional on scott.test(lower(OBJECT_NAME));

SQL>
set linesize 300
col index_owner for a15;
col index_name for a30;
col index_columns for a60;
select index_owner,index_name,listagg(column_name,',') within group (order by column_position) INDEX_COLUMNS
from dba_ind_columns
where table_name = upper('TEST')
group by index_owner,index_name;

INDEX_OWNER     INDEX_NAME                     INDEX_COLUMNS
--------------- ------------------------------ ------------------------------------------------------------
SCOTT           COMPOSITE                      OBJECT_ID,DATA_OBJECT_ID
SCOTT           FUNCTIONAL                     SYS_NC00027$
SCOTT           NORMAL_IDX                     OBJECT_ID

SCOTT @ pdb1 > alter index scott.normal_idx disable;
alter index scott.normal_idx disable
*
ERROR at line 1:
ORA-02243: invalid ALTER INDEX or ALTER MATERIALIZED VIEW option


SCOTT @ pdb1 > alter index scott.composite disable;
alter index scott.composite disable
*
ERROR at line 1:
ORA-02243: invalid ALTER INDEX or ALTER MATERIALIZED VIEW option


SCOTT @ pdb1 > alter index scott.functional disable;

Index altered.
