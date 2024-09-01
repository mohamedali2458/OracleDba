source /home/oracle/.bash_profile
SCRIPTDIR=/home/oracle/Daily
LOGDIR=${SCRIPTDIR}/logs
DATETIME=`date +%Y%m%d%H%M`

echo $SCRIPTDIR
echo $LOGDIR
echo $DATETIME

mv $LOGDIR/dailycheck.html $LOGDIR/dailycheck_${DATETIME}.html
rm $LOGDIR/diskspacereport.html
rm $LOGDIR/diskspacereport.txt
rm $LOGDIR/dbnodecpudetails.lst
rm $LOGDIR/diskspacereport1.html

sqlplus -s "/ as sysdba" @$SCRIPTDIR/dailycheck.sql

HOST=$(hostname)
IPADDR=$(hostname -i)

echo $HOST 
echo $IPADDR

>$LOGDIR/diskspacereport.txt
string1="CPU, Memory and Space Usage Report for DB Server($HOST | $IPADDR) : \n"

echo -e $string1>>$LOGDIR/diskspacereport.txt 

printf "\n"

for i in `seq 1 5` ; do
	>$LOGDIR/dbnodecpudetails.lst 
	top -bn 1 | head -n 3 >> $LOGDIR/dbnodecpudetails.lst
	sleep 3
done

cat $LOGDIR/dbnodecpudetails.lst >> $LOGDIR/diskspacereport.txt

echo "<br />" >> $LOGDIR/diskspacereport.txt

free | grep Mem | awk '{ printf("Free Memory: %.2f %\n", ($4+$7)/$2 * 100.0) }' >> $LOGDIR/diskspacereport.txt
echo "<br />" >> $LOGDIR/diskspacereport.txt
df -h >> $LOGDIR/diskspacereport.txt
echo "<br />" >> $LOGDIR/diskspacereport.txt

echo "************************END OF REPORT*************************" >> $LOGDIR/diskspacereport.txt
cat $LOGDIR/diskspacereport.txt > $LOGDIR/diskspacereport.html
sed 's/$/<br>/g' $LOGDIR/diskspacereport.html>$LOGDIR/diskspacereport1.html
cat $LOGDIR/diskspacereport1.html >> $LOGDIR/dailycheck.html
