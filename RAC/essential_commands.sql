Oracle RAC Commands Every DBA Should Know

Working with Oracle RAC means managing multiple instances, 
nodes, and services and the right commands make life much easier.

Here are some essential Oracle RAC commands every DBA should keep handy 👇

🔹 Check Cluster Status
crsctl check clustercrsctl stat res -t
👉 Verifies if cluster and resources are running properly

🔹 Check Node Status
olsnodes -n
olsnodes -s
👉 Lists nodes and their status in the RAC cluster

🔹 Check ASM Status
srvctl status asm -n node1
crsctl stat res -t | grep asm 

🔹 Database Status (RAC)
srvctl status database -d orcl
srvctl status instance -d orcl -i orcl1

🔹 Start / Stop Database
srvctl start database -d orcl
srvctl stop database -d orcl

🔹 Listener Status
srvctl status listener
lsnrctl status 

🔹 Service Management
srvctl status service -d orcl
srvctl start service -d orcl -s app_srv

💡 Tip:
In RAC, always prefer srvctl over manual startup/shutdown 
- it keeps cluster integrity intact.

At Learnomate Technologies Pvt Ltd, we believe mastering 
these commands helps DBAs quickly troubleshoot node failures, 
service issues, and maintain overall cluster health.