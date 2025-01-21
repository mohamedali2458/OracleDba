Go to root user
source crs home
go to $GRID_HOME

./crsctl stat res -t (found very few processes are running)
./crsctl stop crs -f (f stands for force)
./crsctl start crs
(this will bring the cluster up and add it to next node, instance, listener up)
