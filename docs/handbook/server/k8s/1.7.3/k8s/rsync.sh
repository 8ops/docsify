#!/bin/bash

chown jesse.jesse -R /data/k8s /data/package
for host in 10.10.20.102 10.10.20.103
do
    echo "==== $host ===="
    su jesse -c 'ssh -p 50022 jesse@'$host' "sudo chown -R jesse.jesse /data/k8s"'
    su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/k8s/bin/ jesse@'$host':/data/k8s/bin/' 

    su jesse -c 'ssh -p 50022 jesse@'$host' "mkdir -p /data/k8s/etc/kubernetes/"'
    su jesse -c 'rsync -av --delete --exclude-from=./rsync-exclude.file -e "ssh -p 50022" /data/k8s/etc/kubernetes/ jesse@'$host':/data/k8s/etc/kubernetes/' 

    su jesse -c 'ssh -p 50022 jesse@'$host' "mkdir -p /data/k8s/etc/flanneld/"'
    su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/k8s/etc/flanneld/ jesse@'$host':/data/k8s/etc/flanneld/' 

    #su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/k8s/ jesse@'$host':/data/k8s/' 
    #su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/package/ jesse@'$host':/data/package/' 
done
