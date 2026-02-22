Production Down at 2:17 PM — Oracle

Its 2:17 PM.
Alert rings.
Application team says: “Database is stuck. Nothing is committing.”

You log in to the Oracle Database server.

CPU — normal.
Memory — stable.
Disk — fine.
But sessions are hanging.

You check:
SELECT sid, serial#, blocking_session, event, wait_class
FROM v$session
WHERE status = 'ACTIVE';

Multiple sessions are waiting on:
enq: TX - row lock contention

Now the real question:
Is it:
• Lock contention?
• A long-running batch job?
• Undo tablespace pressure?
• Redo log bottleneck?
• Checkpoint issue?
• Or a blocking chain?

You dig deeper:

SELECT * FROM v$lock WHERE block = 1;

One reporting job started hours ago.
It updated millions of rows inside a single uncommitted transaction.

That one open transaction:
• Held row-level locks
• Blocked other sessions
• Consumed massive UNDO
• Generated heavy REDO
• Slowed commits (log file sync waits)

This is not theory.
This is production behavior.

The fix wasnt just killing a session.

It required:
• Identifying the root blocker
• Evaluating rollback impact
• Checking UNDO health
• Coordinating with the application team
• Monitoring recovery and redo behavior

Database stabilized.

The lesson?
Being an Oracle DBA is not about running “ALTER SYSTEM KILL SESSION”.

Its about understanding how Redo, Undo, Locks, Buffer Cache, Checkpoints, LGWR, DBWR, and Transactions interact under pressure.

Thats real production experience.
