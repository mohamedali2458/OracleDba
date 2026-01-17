The most commonly used DGMGRL commands with clear explanations and real-world usage.

1.Connect to DGMGRL
dgmgrl sys@PRIMARY_DB
Used to connect to the Broker configuration from the primary or standby database.

2. Show Broker Configuration
SHOW CONFIGURATION;
Quickly displays overall health, protection mode, and member databases.

3. Show Database Status
SHOW DATABASE primary_db;
SHOW DATABASE standby_db;
Provides detailed information including role, transport status, and warnings.

4. Enable Broker Configuration
ENABLE CONFIGURATION;
Activates Broker monitoring and management.

5. Disable Broker Configuration
DISABLE CONFIGURATION;
Used during maintenance or troubleshooting.

6. Enable a Database
ENABLE DATABASE standby_db;
Re-enables a database after a temporary issue.

7. Disable a Database
DISABLE DATABASE standby_db;
Stops Broker management for a specific database.

8. Perform Switchover
SWITCHOVER TO standby_db;
Safely switches roles between primary and standby.

9. Perform Failover
FAILOVER TO standby_db;
Used during disaster scenarios when the primary is unavailable.

10. Reinstate a Failed Primary
REINSTATE DATABASE primary_db;
Rebuilds the old primary as a standby after failover.

11. Validate Configuration
VALIDATE CONFIGURATION;
Checks readiness for switchover or failover.

12. Validate Database
VALIDATE DATABASE standby_db;
Validates redo transport and apply for a specific database.

13. Show Observer Status
SHOW OBSERVER;

Displays Fast-Start Failover observer information.

14. Enable Fast-Start Failover
ENABLE FAST_START FAILOVER;

Allows automatic failover when conditions are met.

15. Disable Fast-Start Failover
DISABLE FAST_START FAILOVER;

Used during maintenance or planned outages.

16. Show Fast-Start Failover Status
SHOW FAST_START FAILOVER;

Displays FSFO status and protection details.

17. Edit Database Properties
EDIT DATABASE standby_db SET PROPERTY LogXptMode=’ASYNC’;

Used to modify transport or apply behavior.

18. Show Database Properties
SHOW DATABASE standby_db PROPERTIES;

Lists all Broker-managed settings.

19. Remove a Database
REMOVE DATABASE standby_db;

Removes a database from Broker configuration.

20. Remove Broker Configuration
REMOVE CONFIGURATION;

Deletes the entire Broker configuration (use with caution).
