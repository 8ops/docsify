#!/bin/bash

#122.144.133.40 122.144.133.71 180.166.198.58 182.92.242.176 211.155.90.27

clean(){
    echo "try clean $ip is denyhost info"    
    sed -i '/'$ip'/d' /usr/share/denyhosts/data/hosts
    sed -i '/'$ip'/d' /usr/share/denyhosts/data/hosts-root
    sed -i '/'$ip'/d' /usr/share/denyhosts/data/hosts-valid
    sed -i '/'$ip'/d' /usr/share/denyhosts/data/hosts-restricted
    sed -i '/'$ip'/d' /usr/share/denyhosts/data/users-hosts
    sed -i '/'$ip'/d' /etc/hosts.deny

}

ip=$1
[ -z $ip ] && exit 1
clean $ip


