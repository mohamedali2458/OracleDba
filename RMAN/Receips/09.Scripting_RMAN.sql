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
256
