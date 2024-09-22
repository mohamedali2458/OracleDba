09. Scripting RMAN
==================
The Script Delimiter Approach
=============================
... snipped ...
rman target / << EOF
... RMAN commands come here ...
... more RMAN commands
EOF
... and the rest of the script ...


Command File
RMAN>@cmd.rman

The cmdfile Option
==================
You can use the cmdfile command-line option to call a command file while calling RMAN from the Unix shell
prompt, as shown here:
$ rman target=/ catalog=u/p@catalog cmdfile cmd.rman

You can also use the cmdfile option with an equal sign:
$ rman target=/ catalog=u/p@catalog cmdfile=cmd.rman

You can use the SQL*Plus–like notation to call a script by placing an @ before the name. For example:
$ rman target=/ catalog=u/p@catalog @cmd.rman

At the RMAN command line, the @ is synonymous with cmdfile.


Stored Scripts
==============
You can store scripts in a catalog and call them from the RMAN command prompt, as shown here:
RMAN> run { execute script stored_script; }

The stored script is in an RMAN catalog database, not on any file system.

You can also call a stored script using the script parameter on the command line, as shown here:
$ rman target=/ catalog=u/p@catalog script stored_script


Developing a Unix Shell Script for RMAN
=======================================
You want to develop a shell script to be run by an automated process to back up the database via RMAN.

how to develop a complete shell script to call any RMAN script. Here are some expectations for the script:
• It should be able to run from some automated utility, such as cron.
• It should send an e-mail to a set of addresses after successful completion.
• It should send an e-mail to another set of addresses after a failure.
• It should back up to multiple mount points. In this example, we have assumed nine mount points.
• It should produce a log file whose name follows this format:
  <ORACLE_SID>_<BACKUP_TYPE>_<BACKUP_MEDIA>_<TIMESTAMP>.log
• The log file should show the time stamp in mm/dd/yy hh24:mi:ss format, not the default dd-MON-yy format.
• This log file should be copied over to a central server where all the DBA-related logs are kept.
  In addition, the log file should be copied to one of the backup mount points as well.
• The script should be generic enough to be called for any database. In other words, the script
should not hard-code components that will be different from database to database, such as
Oracle Home, SID, and so on.
• The script should have a built-in locking mechanism; in other words, if the script is running
and is being called again, it shouldn’t start.

Script
======
1. # Beginning of Script
2. # Start of Configurable Section
3. export ORACLE_HOME=/opt/oracle/12.1/db_1
4. export ORACLE_SID=PRODB1
5. export TOOLHOME=/opt/oracle/tools
6. export BACKUP_MEDIA=DISK
7. export BACKUP_TYPE=FULL_DB_BKUP
8. export MAXPIECESIZE=16G
9. # End of Configurable Section
10. # Start of site specific parameters
11. export BACKUP_MOUNTPOINT=/oraback
12. export DBAEMAIL="dbas@proligence.com"
13. export DBAPAGER="dba.ops@proligence.com"
14. export LOG_SERVER=prolin2
15. export LOG_USER=oracle
16. export LOG_DIR=/dbalogs
17. export CATALOG_CONN=${ORACLE_SID}/${ORACLE_SID}@catalog
18. # End of site specific parameters
19. export LOC_PREFIX=$BACKUP_MOUNTPOINT/loc
20. export TMPDIR=/tmp
21. export NLS_DATE_FORMAT="MM/DD/YY HH24:MI:SS"
22. export TIMESTAMP='date +%T-%m-%d-%Y'
23. export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib:/lib
24. export LIBPATH=$ORACLE_HOME/lib:/usr/lib:/lib
25. export SHLIB_PATH=$ORACLE_HOME/lib:/usr/lib:/lib
26. export LOG=${TOOLHOME}/log
27. LOG=${LOG}/log/${ORACLE_SID}_${BACKUP_TYPE}_${BACKUP_MEDIA}_${TIMESTAMP}.log
28. export TMPLOG=$TOOLHOME/log/tmplog.$$
29. echo 'date' "Starting $BACKUP_TYPE Backup of $ORACLE_SID \
30. to $BACKUP_MEDIA" > $LOG
31. export LOCKFILE=$TOOLHOME/${ORACLE_SID}_${BACKUP_TYPE}_${BACKUP_MEDIA}.lock
32. if [ -f $LOCKFILE ]; then
33. echo 'date' "Script running. Exiting ..." >> $LOG
34. else
35. echo "Do NOT delete this file. Used for RMAN locking" > $LOCKFILE
36. $ORACLE_HOME/bin/rman log=$TMPLOG <<EOF
37. connect target /
38. connect catalog $CATALOG_CONN
39. CONFIGURE SNAPSHOT CONTROLFILE NAME TO
40. '${ORACLE_HOME}/dbs/SNAPSHOT_${ORACLE_SID}_${TIMESTAMP}_CTL';
41. run
42. {
43. allocate channel c1 type disk
44. format '${LOC_PREFIX}1/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
45. maxpiecesize ${MAXPIECESIZE};
46. allocate channel c2 type disk
47. format '${LOC_PREFIX}2/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
48. maxpiecesize ${MAXPIECESIZE};
49. allocate channel c3 type disk
50. format '${LOC_PREFIX}3/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
51. maxpiecesize ${MAXPIECESIZE};
52. allocate channel c4 type disk
53. format '${LOC_PREFIX}4/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
54. maxpiecesize ${MAXPIECESIZE};
55. allocate channel c5 type disk
56. format '${LOC_PREFIX}5/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
57. maxpiecesize ${MAXPIECESIZE};
58. allocate channel c6 type disk
59. format '${LOC_PREFIX}6/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
60. maxpiecesize ${MAXPIECESIZE};
61. allocate channel c7 type disk
62. format '${LOC_PREFIX}7/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
63. maxpiecesize ${MAXPIECESIZE};
64. allocate channel c8 type disk
65. format '${LOC_PREFIX}8/${ORACLE_SID}_${BACKUP_TYPE}_${TIMESTAMP}_%p_%s.rman'
66. maxpiecesize ${MAXPIECESIZE};
67. backup
68. incremental level 0
69. tag = 'LVL0_DB_BKP'
70. database
71. include current controlfile;
72. release channel c1;
73. release channel c2;
74. release channel c3;
75. release channel c4;
76. release channel c5;
77. release channel c6;
78. release channel c7;
79. release channel c8;
80. allocate channel d2 type disk format
81. '${LOC_PREFIX}8/CTLBKP_${ORACLE_SID}_${TIMESTAMP}.CTL';
82. backup current controlfile;
83. release channel d2;
84. }
85. exit
86. EOF
87. RC=$?
88. cat $TMPLOG >> $LOG
89. rm $LOCKFILE
90. echo 'date' "Script lock file removed" >> $LOG
91. if [ $RC -ne "0" ]; then
92. mailx -s "RMAN $BACKUP_TYPE $ORACLE_SID $BACKUP_MEDIA Failed" \
93. $DBAEMAIL,$DBAPAGER < $LOG
94. else
95. cp $LOG ${LOC_PREFIX}1
96. mailx -s "RMAN $BACKUP_TYPE $ORACLE_SID $BACKUP_MEDIA Successful" \
97. $DBAEMAIL < $LOG
98. fi
99. scp $LOG \
100. ${LOG_USER}@${LOG_SERVER}:${LOG_DIR}/${ORACLE_SID}/.
101. rm $TMPLOG
102. fi
