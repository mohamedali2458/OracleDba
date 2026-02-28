select username from v$session;

--blank users are related to background processes

select sid,serial# from v$session where username='SCOTT';

alter system kill session 'SID,SERIAL#';

select status from v$session where username='SCOTT';

--status must be killed

--user still logged on 
select table_name from user_tables;
--ora-01012

alter system kill session 'SID,SERIAL#' immediate;
select status from v$session where username='SCOTT';
--its gone completely. nothing comes in this query





Another Method
==============
Terminating an Oracle session is a two-step process. First, you have to identify the specific session details, and then you issue the command to "kill" it.

1. Find the Session Details
You need the SID (Session ID) and SERIAL# for the target session. Run this query to find the culprit:

SELECT sid, serial#, status, username, program 
FROM v$session 
WHERE username = 'SCOTT';

2. The Kill Command
Once you have the numbers (lets use SID 123 and Serial 456 as an example), use the following syntax:

ALTER SYSTEM KILL SESSION '123,456';

Important Options:
IMMEDIATE: If you dont want to wait for the session to acknowledge the kill command and roll back, add IMMEDIATE. This tells the database to roll back the transaction and release locks as fast as possible.

ALTER SYSTEM KILL SESSION '123,456' IMMEDIATE;

POST_TRANSACTION: This is the "polite" way. It waits for the user to finish their current transaction before terminating the session.

What happens behind the scenes?
When you run this command, Oracle doesnt just "delete" the process instantly. It marks the session as "KILLED." The background process (PMON) then cleans up the resources, rolls back uncommitted changes, and releases locks.

A Quick Warning
If a session is performing a massive update or delete, killing it might actually make things feel "slower" temporarily because the database has to roll back all those changes to maintain data integrity.

Pro Tip: If ALTER SYSTEM KILL SESSION fails or the session gets stuck in a "KILLED" status for a long time, you may need to kill the process at the Operating System level (using kill -9 on Linux/Unix), but always try the SQL command first to avoid corrupting memory.

Would you like me to help you write a script to identify the sessions that are currently holding the most locks?

Identifying Blocking Sessions
This script joins v$session with v$lock to show you the Username, the SID, and the Type of lock they are holding.

SELECT 
    l.sid, 
    s.username, 
    s.serial#, 
    s.status, 
    l.type, 
    l.lmode, 
    l.request, 
    o.object_name
FROM v$lock l
JOIN v$session s ON l.sid = s.sid
LEFT JOIN dba_objects o ON l.id1 = o.object_id
WHERE s.username IS NOT NULL
AND l.type IN ('TM', 'TX'); -- TM is DML, TX is Transaction

Understanding the Lock Hierarchy
When one session holds a lock, others have to wait in a queue. Killing the "Root Blocker" usually clears the traffic jam for everyone else.

Summary of Lock Modes (LMODE)
If you see these numbers in the query results, here is what they mean:

LMODE Value     Lock Description    Severity
0	            None	            No lock held
2	            Row-S (SS)	        Row Share
3	            Row-X (SX)	        Row Exclusive (Common for Updates)
4	            Share (S)	        Prevents others from updating
6	            Exclusive (X)	    Full access; blocks all other types


When "Kill Session" isnt enough
If the session status stays as KILLED for a long time, it means Oracle is still rolling back the transaction. If you absolutely must kill it at the OS level (Linux), you can find the SPID (System Process ID) with this:

SELECT p.spid, s.username, s.program
FROM v$process p
JOIN v$session s ON p.addr = s.paddr
WHERE s.sid = 123; -- Replace with your SID

Then, from the Linux terminal: kill -9 <SPID>

Would you like me to generate a script that automatically creates the ALTER SYSTEM kill commands for all sessions older than a certain number of hours?

This script is a bit of a "nuclear option," so use it with caution. It generates the specific SQL commands needed to kill any active sessions that have been running for more than a set number of hours (e.g., 2 hours).

The "Session Killer" Generator
Copy and run this in your SQL tool. It wont kill anything immediately; it simply outputs the commands for you to review and execute.

SELECT 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || ''' IMMEDIATE;' AS kill_command,
       username, 
       status, 
       last_call_et / 3600 AS hours_active,
       program
FROM v$session
WHERE status = 'ACTIVE' 
  AND username IS NOT NULL
  AND last_call_et > (2 * 3600); -- Change '2' to your desired hour threshold

How Oracle Manages the Termination
When you execute these generated commands, the database initiates a cleanup. Its helpful to understand the lifecycle of a killed session to know why some take longer to disappear than others.

Key Columns Explained:
last_call_et: This is the elapsed time (in seconds) since the last call was made. Dividing by 3600 converts it to hours.

IMMEDIATE: Ive included this in the generator to ensure the session is marked for termination as quickly as possible.

username IS NOT NULL: This prevents you from accidentally generating kill commands for vital background processes (like DBW0 or LGWR), which would crash your instance.

Best Practices Before Pulling the Trigger
Check for Parallel Processes: Sometimes one user session spawns many parallel "slave" processes. Killing the coordinator session usually cleans these up, but it can take a moment.

Verify the SPID: If the session is truly "hung" (not just busy), keep the SPID (System Process ID) handy in case you need to kill it at the OS level.

Warning: Running this against an ETL or Backup process can cause significant delays while the database performs a massive rollback. Always check the program column first!

