Parameter file Management
=========================
There are two types of parameter files:-pfile and spfile.

Pfile - pfile is a static, client-side text file that must be updated with a standard text editor like "notepad" or "vi".

SPfile - As SPFILE (Server Parameter File), on the other hand, is a persistent server side binary file that can only be modified with the "ALTER SYSTEM" command.

Note: Default location for both parameter files is $ORACLE_HOME/dbs

To Change the parameter value in pfile :-

Dynamic parameter (sga_target)

SQL> alter system set sga_target=3g;

The above parameter value gets changed only in memory, to permanently change do the following:-
	1. open the parameter file
	2. then specify the value in parameter file

	Exp:-
	$cd $ORACLE_HOME/dbs
	vi inittest.ora
	sga_target=3g
	:wq (to save and exit)

Static Prameter (sga_max_size)
The static parameter (sga_max_size) can be changed only in parameter file. 
And to make the value effective the instance must be bounced back.


How to change parameter value in spfile ?

The SCOPE parameter can be set to SPFILE, MEMORY or BOTH.

Memory:- Value is set for the current instance only.

Spfile:- Update the SPFILE, the parameter will take effect with next database startup.

Both:- value is affect the current instance and persist to the SPFILE.

Dynamic Parameter
alter system set sga_target = 300m;
alter system set sga_target = 500m scope=memory;
alter system set sga_target = 500m scope=both;

Static Parameter
alter system set sga_max_size = 1g scope=spfile;
alter system set sga_max_size = 500m comment='max size is 1GB' scope=spfile;

Converting between PFILES and SPFILES
Execute the following commands from a user with SYSDBA or SYSOPER privileges:-
Create pfile from spfile;
Create spfile from pfile;
Create pfile from memory;

SELECT * FROM V$PARAMETER WHERE ISDEPRECATED='TRUE';

SELECT NUM, NAME, VALUE, DISPLAY_VALUE,ISDEFAULT, 
ISSES_MODIFIABLE, ISSYS_MODIFIABLE, ISINSTANCE_MODIFIABLE,
ISMODIFIED,DESCRIPTION,UPDATE_COMMENT
FROM V$PARAMETER
WHERE UPPER(NAME) LIKE 'SGA%';

Views for parameter file management:
v$parameter
V$PARAMETER displays information about the initialization parameters that are currently in 
effect for the session. A new session inherits parameter values from the instance-wide 
values displayed by the V$SYSTEM_PARAMETER view.

Column	Datatype	Description
NUM	NUMBER	Parameter number
NAME	VARCHAR2(80)	Name of the parameter
TYPE	NUMBER	Parameter type:
•	1 - Boolean
•	2 - String
•	3 - Integer
•	4 - Parameter file
•	5 - Reserved
•	6 - Big integer
VALUE	VARCHAR2(512)	Parameter value for the session (if modified within the session); otherwise, the instance-wide parameter value
DISPLAY_VALUE	VARCHAR2(512)	Parameter value in a user-friendly format. For example, if the VALUE column shows the value 262144 for a big integer parameter, then the DISPLAY_VALUE column will show the value 256K.
ISDEFAULT	VARCHAR2(9)	Indicates whether the parameter is set to the default value (TRUE) or the parameter value was specified in the parameter file (FALSE)
ISSES_MODIFIABLE	VARCHAR2(5)	Indicates whether the parameter can be changed with ALTER SESSION (TRUE) or not (FALSE)
ISSYS_MODIFIABLE	VARCHAR2(9)	Indicates whether the parameter can be changed with ALTER SYSTEM and when the change takes effect:
•	IMMEDIATE - Parameter can be changed with ALTER SYSTEM regardless of the type of parameter file used to start the instance. The change takes effect immediately.
•	DEFERRED - Parameter can be changed with ALTER SYSTEM regardless of the type of parameter file used to start the instance. The change takes effect in subsequent sessions.
•	FALSE - Parameter cannot be changed with ALTER SYSTEM unless a server parameter file was used to start the instance. The change takes effect in subsequent instances.
ISINSTANCE_MODIFIABLE	VARCHAR2(5)	For parameters that can be changed with ALTER SYSTEM, indicates whether the value of the parameter can be different for every instance (TRUE) or whether the parameter must have the same value for all Real Application Clusters instances (FALSE). If the ISSYS_MODIFIABLE column is FALSE, then this column is always FALSE.
ISMODIFIED	VARCHAR2(10)	Indicates whether the parameter has been modified after instance startup:
•	MODIFIED - Parameter has been modified with ALTER SESSION
•	SYSTEM_MOD - Parameter has been modified with ALTER SYSTEM (which causes all the currently logged in sessions' values to be modified)
•	FALSE - Parameter has not been modified after instance startup
ISADJUSTED	VARCHAR2(5)	Indicates whether Oracle adjusted the input value to a more suitable value (for example, the parameter value should be prime, but the user input a non-prime number, so Oracle adjusted the value to the next prime number)
ISDEPRECATED	VARCHAR2(5)	Indicates whether the parameter has been deprecated (TRUE) or not (FALSE)
DESCRIPTION	VARCHAR2(255)	Description of the parameter
UPDATE_COMMENT	VARCHAR2(255)	Comments associated with the most recent update
HASH	NUMBER	Hash value for the parameter name


v$parameter2
V$PARAMETER2 displays information about the initialization parameters that are currently in effect for the session, with each list parameter value appearing as a row in the view. A new session inherits parameter values from the instance-wide values displayed in the V$SYSTEM_PARAMETER2 view.
Presenting the list parameter values in this format enables you to quickly determine the values for a list parameter. For example, if a parameter value is a, b, then the V$PARAMETER view does not tell you if the parameter has two values (both a and b) or one value (a, b). V$PARAMETER2 makes the distinction between the list parameter values clear.
Column	Datatype	Description
NUM	NUMBER	Parameter number
NAME	VARCHAR2(80)	Name of the parameter
TYPE	NUMBER	Parameter type:
•	1 - Boolean
•	2 - String
•	3 - Integer
•	4 - Parameter file
•	5 - Reserved
•	6 - Big integer
VALUE	VARCHAR2(512)	Parameter value for the session (if modified within the session); otherwise, the instance-wide parameter value
DISPLAY_VALUE	VARCHAR2(512)	Parameter value in a user-friendly format. For example, if the VALUE column shows the value 262144 for a big integer parameter, then the DISPLAY_VALUE column will show the value 256K.
ISDEFAULT	VARCHAR2(6)	Indicates whether the parameter is set to the default value (TRUE) or the parameter value was specified in the parameter file (FALSE)
ISSES_MODIFIABLE	VARCHAR2(5)	Indicates whether the parameter can be changed with ALTER SESSION (TRUE) or not (FALSE)
ISSYS_MODIFIABLE	VARCHAR2(9)	Indicates whether the parameter can be changed with ALTER SYSTEM and when the change takes effect:
•	IMMEDIATE - Parameter can be changed with ALTER SYSTEM regardless of the type of parameter file used to start the instance. The change takes effect immediately.
•	DEFERRED - Parameter can be changed with ALTER SYSTEM regardless of the type of parameter file used to start the instance. The change takes effect in subsequent sessions.
•	FALSE - Parameter cannot be changed with ALTER SYSTEM unless a server parameter file was used to start the instance. The change takes effect in subsequent instances.
ISINSTANCE_MODIFIABLE	VARCHAR2(5)	For parameters that can be changed with ALTER SYSTEm, indicates whether the value of the parameter can be different for every instance (TRUE) or whether the parameter must have the same value for all Real Application Clusters instances (FALSE). If the ISSYS_MODIFIABLE column is FALSE, then this column is always FALSE.
ISMODIFIED	VARCHAR2(10)	Indicates whether the parameter has been modified after instance startup:
•	MODIFIED - Parameter has been modified with ALTER SESSION
•	SYSTEM_MOD - Parameter has been modified with ALTER SYSTEM (which causes all the currently logged in sessions' values to be modified)
•	FALSE - Parameter has not been modified after instance startup
ISADJUSTED	VARCHAR2(5)	Indicates whether Oracle adjusted the input value to a more suitable value (for example, the parameter value should be prime, but the user input a non-prime number, so Oracle adjusted the value to the next prime number)
ISDEPRECATED	VARCHAR2(5)	Indicates whether the parameter has been deprecated (TRUE) or not (FALSE)
DESCRIPTION	VARCHAR2(255)	Description of the parameter
ORDINAL	NUMBER	Position (ordinal number) of the parameter value. Useful only for parameters whose values are lists of strings.
UPDATE_COMMENT	VARCHAR2(255)	Comments associated with the most recent update


v$spparameter
V$SPPARAMETER displays information about the contents of the server parameter file. If a server parameter file was not used to start the instance, then each row of the view will contain FALSE in the ISSPECIFIED column.
Column	Datatype	Description
SID	VARCHAR2(80)	SID for which the parameter is defined
NAME	VARCHAR2(80)	Name of the parameter
VALUE	VARCHAR2(255)	Parameter value (null if a server parameter file was not used to start the instance)
DISPLAY_VALUE	VARCHAR2(255)	Parameter value in a user-friendly format. For example, if the VALUE column shows the value 262144 for a big integer parameter, then the DISPLAY_VALUE column will show the value 256K.
ISSPECIFIED	VARCHAR2(6)	Indicates whether the parameter was specified in the server parameter file (TRUE) or not (FALSE)
ORDINAL	NUMBER	Position (ordinal number) of the parameter value (0 if a server parameter file was not used to start the instance). Useful only for parameters whose values are lists of strings.
UPDATE_COMMENT	VARCHAR2(255)	Comments associated with the most recent update (null if a server parameter file was not used to start the instance)
