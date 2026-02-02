Real-World Oracle Database Issue & Resolution (Oracle 19c vs 11g Client)
========================================================================
Recently, we faced a very unusual and interesting Oracle Database issue that’s worth sharing with the community.

A user reported that they were unable to log in to the Oracle database using SQL*Plus and Oracle Client. During troubleshooting, we identified multiple contributing factors.

Initial Findings

The user did not have access to SCAN listeners / SCAN IPs
As a workaround, we allowed the user to send requests via the PUBLIC network
There was a client–server compatibility issue

Actions Taken
We updated the sqlnet.ora file and added compatibility parameters to allow older clients
Specifically, we allowed:
Oracle 8
Oracle 9
Oracle 11g clients

The database was running Oracle 19c, while the client version was Oracle 11g
Despite these changes, the issue was still not resolved.

⚠️ Critical Miss (Root Cause)
On deeper analysis, we discovered that:
The sqlnet.ora parameters were added only on the first node
The second RAC node was completely missing these settings
After updating the second node, we retried the connection  but the problem still persisted.

🔑 Final Breakthrough: Password Version Mismatch
At this stage, we identified the actual root cause:
After modifying authentication-related parameters, the user password must be reset
Although:
The user could connect using PL/SQL Developer
The password was correct
The Oracle Client connection failed with a password error
This happened because the password version stored in the database was incompatible with the client after the parameter changes.

🔄 Once the password was reset, the issue was fully resolved.

✅ Key Takeaways
Always apply sqlnet.ora changes on all RAC nodes
Client–server version mismatch can cause silent authentication failures
After changing authentication or compatibility parameters, resetting user passwords is critical
A password may work in one tool but fail in another due to password version differences

This was a great reminder that Oracle issues are often multi-layered, and missing one small detail can keep the problem alive.
