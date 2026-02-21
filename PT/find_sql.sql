select sql_id,sql_text from v$sql where sql_text like '%&1%';


login.sql
set pagesize 300 linesize 400
col report format a400
def _editor=vi
