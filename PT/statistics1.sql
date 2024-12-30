About Oracle Statistics
=======================
What are statistics?

Ans: Input to the Cost-Based Optimizer, Provide information on

User Objects
	Table, Partition, Subpartition
	Columns
	Index, Index Partition, Index Subpartition
System
Dictionary
Memory structure (X$)

Statistics on a table are considered stale when more than STALE_PERCENT (default 10%) of the rows are changed
(total number of inserts, deletes, updates) in the table. 
Oracle monitors the DML activity for all tables and records it in the SGA. 
The monitoring information is periodically flushed to disk, and is exposed in the *_TAB_MODIFICATIONS view.

Why do we care about statistics?

Poor statistics usually lead to poor plans
Collecting good quality stats is not straightforward
Collecting good quality stats may be time consuming
Improving statistics quality improves the chance to find an optimal plan (usually)
The higher the sample the higher the accuracy
The higher the sample the longer it takes to collect
The longer it takes the less frequent we can collect fresh stats!

If your data changes frequently, then

If you have plenty of resources:
Gather statistics often and with a very large sample size

If your resources are limited: 
Use AUTO_SAMPLE_SIZE (11g)
Use a smaller sample size (try to avoid this)

If your data doesn’t change frequently: 
Gather statistics less often and with a very large sample size


Recommended syntax

/*
Assuming we want Oracle to determine where to put histograms (instead of specifying the list manually):

In 10g avoid AUTO_SAMPLE_SIZE

exec dbms_stats.gather_table_stats('owner', 'table_name', estimate_percent => NNN,granularity => “it depends”);

In 11g use AUTO_SAMPLE_SIZE but keep an eye open. 
exec dbms_stats.gather_table_stats('owner', 'table_name');
*/
