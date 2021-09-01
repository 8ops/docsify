#!/bin/bash
# author: jesse
# date  : 2014-05-08

daoHosts=(webapps-45 webapps-46 webapps-50)
serverHosts=(webapps-31 webapps-32 webapps-37 webapps-49 webapps-52)
serverHosts=(webapps-31 webapps-32)

daoHosts=(10.10.10.45 10.10.10.46 10.10.10.50)
serverHosts=(10.10.10.31 10.10.10.32 10.10.10.37 10.10.10.49 10.10.10.53)
templateDao=/dev/shm/template-dao
templateServer=/dev/shm/template-server

pullDaoWebapps(){
    for host in ${daoHosts[@]}
    do
        rsync -rtlv -e "ssh -p 50022" jesse@$host:/data/webapps/ /dev/shm/webapps-$host/
    done
}

pullServerWebapps(){
    for host in ${serverHosts[@]}
    do
        rsync -rtlv -e "ssh -p 50022" jesse@$host:/data/webapps/ /dev/shm/webapps-$host/
    done
}

checkDao(){
    successCount=0
    failureCount=0
    cd $templateDao
    grep -roPn "10.10.10.[0-9]+" . | sed 's/:/ /g' | while read file num ip
    do
        echo -e "\n[CHECK DAO CONFIG] $file\t$num\t$ip"
        for host in ${daoHosts[@]}
        do
            echo -e "[CHECK HOST] $host"
            domain=$(sed -n ${num}p ../webapps-$host/$file | grep -oP "[a-z0-9]+\.[a-z0-9]+\.youja.cn") 
            if [ -z $domain ]; then
                echo "domain is not found."
                failureCount=$((failureCount+1))
                continue
            else
                echo -n "domain is $domain ==> "
            fi
            pingip=$(ping -c1 $domain 2>&1 | head -n1 | grep -oP "(\d+\.){3}\d+")
            echo -n "ping domain output $pingip compare is $ip: "
            if [ "X$ip" == "X$pingip" ]; then
                successCount=$((successCount+1))
                echo "OK"
            else
                failureCount=$((failureCount+1))
                echo "Fail"
            fi
        done
    done
    echo -e "\n[CHECK RESULT]check dao success $successCount times, failure $failureCount times.\n\n"
}

checkServer(){
    successCount=0
    failureCount=0
    cd $templateServer
    grep -roPn "10.10.10.[0-9]+" . | sed 's/:/ /g' | while read file num ip
    do
        echo -e "\n[CHECK SERVER CONFIG] $file\t$num\t$ip"
        for dir in ${serverHosts[@]}
        do
            echo -e "[CHECK HOST] $dir"
            domain=$(sed -n ${num}p ../$dir/$file | grep -oP "[a-z0-9]+\.[a-z0-9]+\.youja.cn")
            if [ -z $domain ]; then
                echo "domain is not found."
                failureCount=$((failureCount+1))
                continue
            else
                echo -n "domain is $domain ==> "
            fi
            pingip=$(ping -c1 $domain 2>&1 | head -n1 | grep -oP "(\d+\.){3}\d+")
            echo -n "ping domain output $pingip compare is $ip: "
            if [ "X$ip" == "X$pingip" ]; then
                successCount=$((successCount+1))
                echo "OK."
            else
                failureCount=$((failureCount+1))
                echo "Fail. ================================================== warn "
            fi
        done
    done
    echo -e "\n[CHECK RESULT]check dao success $successCount times, failure $failureCount times.\n\n"
}


echo "Start checking... "
#rsync -rtlv /data/webapps/template-dao/ /dev/shm/template-dao/
#rsync -rtlv /data/webapps/template-server/ /dev/shm/template-server/
#pullDaoWebapps
checkDao
#pullServerWebapps
#checkServer


echo "Over checked "
