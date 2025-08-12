--Online Redologs
  
set linesize 300
select * from v$log order by group#;

set linesize 300
col member for a80
select * from v$logfile order by group#;

SELECT A.GROUP#,B.MEMBER,THREAD#,SEQUENCE#,ROUND(BYTES/1024/1024/1024) "GB",MEMBERS,ARCHIVED,A.STATUS
FROM V$LOG A, V$LOGFILE B
WHERE A.GROUP# = B.GROUP#
ORDER BY A.GROUP#;

