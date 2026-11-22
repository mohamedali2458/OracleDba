What is Data Guard?

Data Guard, which was introduced as the standby database in Oracle database Version 7.3 
under the name of Data Guard with Version 9i, is a data protection and availability 
solution for Oracle databases. The basic function of Oracle Data Guard is to keep a 
synchronized copy of a database as standby, in order to make provision, incase the 
primary database is inaccessible to end users. These cases are hardware errors, 
natural disasters, and so on. Each new Oracle release added new functionalities 
to Data Guard and the product became more and more popular with offerings such 
as data protection, high availability, and disaster recovery for Oracle databases.

Using Oracle Data Guard, its possible to direct user connections to a Data Guard standby
database automatically with no data loss, in case of an outage in the primary database. Data
Guard also offers taking advantage of the standby database for reporting, test, and backup
offloading. Corruptions on the primary database may be fixed automatically by using the
non-corrupted data blocks on the standby database. There will be minimal outages (seconds
to minutes) on the primary database in planned maintenances such as patching and
hardware changes by using the switchover feature of Data Guard, which changes the roles
of the primary and standby databases. All of these features are available with Data Guard,
which doesnt require an installation but a cloning and configuration of the Oracle database.

page 8
