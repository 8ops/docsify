#! /bin/bash

#m=$1
#n=$2
#[ -z $m ] && m=100
#[ -z $n ] && n=30

# count = m * n, thread = n
for i in {1..1000}
do
    dt=$(date +%Y%m%d%H%M%S)
    for j in {1..10}
    do
        python server.py '{"uid":"12345","pushId":"1234","message":"This is uplus.push.test push iphone message (i='$i',j='$j') - '$dt'","bage":"4"}'
    done &
    #sleep 1
done

