#! /bin/bash
# author: jesse
# date  : 2014-05-08

tnum=100

sdir=(/data/SnsFile)
tdir=/dev/shm
listfile=$tdir/list.file-$(date +%s)
timefile=$tdir/time.file

upload(){
    childlistfile=$1
    echo "Start upload file for $childlistfile  - $(date)" >> $timefile
    while read file
    do
        url=$(echo $file | sed 's/^\/data/http:\/\/image\.fs\.i-jesse\.org\/put/')
        curl --upload-file $file $url
    done < $childlistfile
    echo "Complete upload file for $childlistfile  - $(date)" >> $timefile
    rm -f $childlistfile
}

echo "Start scan file for dir - $(date)" > $timefile
echo -n "" > $listfile
for dir in ${sdir[@]}
do
    echo "Scan file for $dir "
    find $dir -type f >> $listfile
done
echo "Complete scan file for dir - $(date)" >> $timefile

echo "Start put file. "
echo "Start prepare thread  - $(date)" >> $timefile
count=$(wc -l $listfile | cut -d" " -f1)
pnum=$((count/tnum))
index=0
while true
do
    sed -n $((index*pnum+1)),$(((index+1)*pnum))p $listfile > $listfile.t$index
    upload $listfile.t$index &  
    index=$((index+1))
    [ $index -gt $tnum ] && break
done
echo "Complete prepare thread  - $(date)" >> $timefile

rm -f $listfile


