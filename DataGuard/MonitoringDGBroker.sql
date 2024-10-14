Monitoring a Data Guard Broker Configuration

1-Invoke DGMGRL on your primary DB host and connect as sys user
dgmgrl
DGMGRL> connect sys/sys

2-Execute the SHOW CONFIGURATION command to check your configuration status
DGMGRL> show configuration;

3-In your standby DB, invoke DGMGRL and connect as the sys user
dgmgrl
DGMGRL> connect sys/sys

4-DISABLE Redo Apply on your stanby DB
DGMGRL> edit database 'stdby' set state='apply-off';

5-Return to your primary DB window and Confirm your change by using the
SHOW DATABASE command
DGMGRL> show database stdby;

6-Return to your standby DB and Restart Redo Apply
DGMGRL> edit database 'stdby' set state='apply-on';

7-Confirm your change by using the SHOW DATABASE command to display a brief summary of the database.
DGMGRL> show database stdby;

8-Use the SHOW DATABASE VERBOSE command to display all property values for a database
DGMGRL> show database verbose stdby;

9-Viewing Standby Redo Log Information in V$LOGFILE
select group#, member from v$logfile where type='STANDBY';

10-Monitoring Redo Apply by Querying V$MANAGED_STANDBY
select process, status, thread#, sequence#, block#, blocks from v$managed_standby;

11-Identifying Destination Settings
select dest_id, valid_type, valid_role, valid_now from v$archive_dest;

12) Evaluating Redo Data by Querying V$DATAGUARD_STATS
select name, value, time_computed from v$dataguard_stats;

13-Viewing Data Guard Status Infomation by Querying V$DATAGUARD_STATUS
select timestamp, facility, dest_id, message_num, error_code, message
from v$dataguard_status
order by timestamp;

