Move Spfile to ASM

With ASM configured for RAC or NON-RAC systems, it is a good idea to move the 
spfile to ASM. The PFILE under $ORACLE_HOME/dbs location actually points to the SPFILE on ASM disk.

Create PFILE from SPFILE

Check if your database is running with SPFILE, if yes then create pfile from spfile

show parameter spfile

NAME     TYPE VALUE
-------- ----------- ------------------------------
spfile string /oracle/app/oracle/product/dbs/spfileORCL.ora
  
Create PFILE from the existing SPFILE

Create pfile from spfile;
File created.

Create Directory in ASM Diskgroup

Connect to ASMCMD (grid) and create directory to hold the SPFILE

asmcmd
ASMCMD> mkdir +DATA/ORCL/PARAM

Create SPFILE in ASM from PFILE

Now that we have the PFILE, we can create SPFILE from PFILE directly inside ASM

SQL> create spfile='+DATA/ORCL/PARAM/spfileORCL.ora' from pfile;

Rename the SPFILE under $ORACLE_HOME/dbs location

cd $ORACLE_HOME/dbs
mv spfileORCL.ora spfileORCL.ora_B4_ASM


Point PFILE to SPFILE on ASM

Edit the PFILE and just add one single line below to point SPFILE on ASM

vi initORCL.ora
spfile='+DATA/ORCL/PARAM/spfileORCL.ora'
  
Restart the database!
