--Parameter file Management
--There are two types of parameter files:-pfile and spfile.
--pfile and spfile
  
--Default location for both parameter files is $ORACLE_HOME/dbs

--To Change the parameter value in pfile :-
--Dynamic parameter (sga_target)
SQL> alter system set sga_target=3g;
--The above parameter value gets changed only in memory, to permanently change do the following:-
/*
	1. open the parameter file
	2. then specify the value in parameter file
	Exp:-
	$cd $ORACLE_HOME/dbs
	vi inittest.ora
	sga_target=3g
	:wq (to save and exit)
    */

--Static Prameter (sga_max_size)
--The static parameter (sga_max_size) can be changed only in parameter file. 
--And to make the value effective the instance must be bounced back.

  
--How to change parameter value in spfile ?
The SCOPE parameter can be set to SPFILE, MEMORY or BOTH.
Memory:- Value is set for the current instance only.
Spfile:- Update the SPFILE, the parameter will take effect with next database startup.
Both:- value is affect the current instance and persist to the SPFILE.
  
--Dynamic Parameter
alter system set sga_target = 300m;
alter system set sga_target = 500m scope=memory;
alter system set sga_target = 500m scope=both;

--Static Parameter
alter system set sga_max_size = 1g scope=spfile;
alter system set sga_max_size = 500m comment='max size is 1GB' scope=spfile;

--Converting between PFILES and SPFILES
Execute the following commands from a user with SYSDBA or SYSOPER privileges:-
Create pfile from spfile;
Create spfile from pfile;
Create pfile from memory;

set linesize 300
col name for a30
col value for a20
SELECT name,type,value FROM V$PARAMETER WHERE ISDEPRECATED='TRUE';

SELECT NAME, VALUE, ISDEFAULT, ISSES_MODIFIABLE, ISSYS_MODIFIABLE, ISMODIFIED
FROM V$PARAMETER
WHERE UPPER(NAME) LIKE 'SGA%';

--Views for parameter file management:
v$parameter
V$PARAMETER displays information about the initialization parameters that are currently in effect for the session. A new session inherits parameter values from the instance-wide values displayed by the V$SYSTEM_PARAMETER view.

v$parameter2
V$PARAMETER2 displays information about the initialization parameters that are currently in effect for the session, with each list parameter value appearing as a row in the view. A new session inherits parameter values from the instance-wide values displayed in the V$SYSTEM_PARAMETER2 view.


v$spparameter
V$SPPARAMETER displays information about the contents of the server parameter file. If a server parameter file was not used to start the instance, then each row of the view will contain FALSE in the ISSPECIFIED column.
