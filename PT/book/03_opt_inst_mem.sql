Optimizing Instance Memory

In Oracle Database 11g, the burden of allocating Oracle’s memory is shifted almost completely
to the database itself.

This chapter starts off by explaining how to set up automatic memory management for a database.
The chapter also shows you how to set minimum values for certain components of memory even under
automatic memory management. It also includes recipes that explain how to create multiple buffer
pools, how to monitor Oracle’s usage of memory, and how to use the Oracle Enterprise Manager’s
Database Control (or Grid Control) tool to get advice from Oracle regarding the optimal sizing of
memory allocation. You’ll also learn how to optimize the use of the Program Global Area (PGA), a key
Oracle memory component, especially in data warehouse environments.

  new result caching feature. Oracle can
now cache the results of both SQL queries and PL/SQL functions in the shared pool component of
Oracle’s memory.

3-1. Automating Memory Management

steps to implement automatic memory management

1. Connect to the database with the SYSDBA privilege.

2. Assuming you’re using the SPFILE, first set a value for the MEMORY_MAX_TARGET parameter:
SQL> alter system set memory_max_target=2G scope=spfile;
System altered.

You must specify the SCOPE parameter in the alter system command, because MEMORY_MAX_TARGET
isn’t a dynamic parameter, which means you can’t change it on the fly while the instance is running.

3. Note that if you’ve started the instance with a traditional init.ora parameter
file instead of the SPFILE, you must add the following to your init.ora file:
memory_max_target = 2000M
memory_target = 1000M

4. Bounce the database.

5. Turn off the SGA_TARGET and the PGA_AGGREGATE_TARGET parameters by issuing the following ALTER SYSTEM commands:
SQL> alter system set sga_target = 0;
SQL> alter system set pga_aggregate_target = 0;

6. Turn on automatic memory management by setting the MEMORY_TARGET parameter:
SQL> alter system set memory_target = 1000M;

From this point on, the database runs under the automatic memory management mode, with it
shrinking and growing the individual allocations to the various components of Oracle memory
according to the requirements of the ongoing workload. You can change the value of the MEMORY_TARGET
parameter dynamically anytime, as long as you don’t exceed the value you set for the MEMORY_MAX_TARGET
parameter.

The term “target” in parameters such as memory_target and pga_memory_target means just that—
Oracle will try to stay under the target level, but there’s no guarantee that it’ll never go beyond that. It may exceed
the target allocation on occasion, if necessary.

Oracle’s memory structures consist of two distinct memory areas. The system global area (SGA)
contains the data and control information and is shared by all server and background processes. The
SGA holds the data blocks retrieved from disk by Oracle. The program global area (PGA) contains data
and control information for a server process. Each server process is allocated its own chunk of the PGA.
Managing Oracle’s memory allocation involves careful calibration of the needs of the database. Some
database instances need more memory for certain components of the memory. For example, a data
warehouse will need more PGA memory in order to perform huge sorts that are common in such an
environment. Also, during the course of a day, the memory needs of the instance might vary; during
business hours, for example, the instance might be processing more online transaction processing
(OLTP) work, whereas after business hours, it might be running huge batch jobs that involve data
warehouse processing, jobs that typically need higher PGA allocations per each process.

In prior versions of the Oracle database, DBAs had to carefully decide the optimal allocation of
memory to the individual components of the memory one allocated to the database. Technically, you
can still manually set the values of the individual components of the SGA as well as set a value for the
PGA, or partially automate the process by setting parameters such as SGA_TARGET and
PGA_AGGREGATE_TARGET. Although Oracle still allows you to manually configure the various components of
memory, automatic memory management is the recommended approach to managing Oracle’s
memory allocation. Once you specify a certain amount of memory by setting the MEMORY_TARGET and
MEMORY_MAX_TARGET parameters, Oracle automatically tunes the actual memory allocation, by
redistributing memory between the SGA and the PGA.

Under an automatic memory management
regime, Oracle automatically tunes the total SGA size, the SGA component sizes, the instance PGA size,
and the individual PGA size. This dynamic memory tuning by the Oracle instance optimizes database
performance, as memory allocations are changed automatically by Oracle to match changing database
workloads. Automatic memory management means that once you set the MEMORY_TARGET parameter, you
can simply ignore the following parameters by not setting them at all:

• SGA_TARGET
• PGA_AGGREGATE_TARGET
• DB_CACHE_SIZE
• SHARED_POOL_SIZE
• LARGE_POOL_SIZE
• JAVA_POOL_SIZE

