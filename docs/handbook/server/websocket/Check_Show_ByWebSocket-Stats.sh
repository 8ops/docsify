#! /bin/bash

dt=$1
if [ -z ${dt} ]; then
    tdt=$(date +%Y%m%d)
    read -t 10 -p "Input date (eg: yyyymmdd, default=${tdt}): " dt 
    [ -z $dt ] && dt=${tdt}
fi

logfile=/dev/shm/access.log-${dt}
[ -e ${logfile} ] || wget http://apm.yw.dpocket.cn/logs/ws/access.log-${dt}.gz -O ${logfile}.gz 
gunzip ${logfile}.gz
wc -l ${logfile} 

while read ip 
do
    grep "${ip}" ${logfile} > ${logfile}-${ip}
    all=$(wc -l ${logfile}-${ip} | cut -d' ' -f1)
    succ=$(grep -P "\/ws\/0\/" -c ${logfile}-${ip})
    echo -e "${all}\t${succ}"
done < ~/bin/apps/websocket/iplist


