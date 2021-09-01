#! /bin/bash

N=5
dt=$(date +%Y%m%d%H%M%S)
TMPDIR=/tmp/$dt
mkdir -p $TMPDIR 
cd $TMPDIR 

zoo_server(){
    O=0
    while true
    do
        O=$((O+1))
        [ $O -gt $N ] && break
        echo "server.$O=127.0.0.1:288$O:388$O"
    done
}

P=0
while true
do

# Create zoo.cfg
P=$((P+1))
[ $P -gt $N ] && break
cat > $TMPDIR/zoo-$P.cfg << EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/$dt/zookeeper-$P
clientPort=218$P
dataLogDir=/tmp/$dt/logs-$P
EOF

zoo_server >> $TMPDIR/zoo-$P.cfg 

# Create dir
mkdir $TMPDIR/zookeeper-$P
mkdir $TMPDIR/logs-$P
echo "$P" > $TMPDIR/zookeeper-$P/myid

# Start zoo
zkServer.sh start $TMPDIR/zoo-$P.cfg

done



