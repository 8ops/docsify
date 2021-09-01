#!/bin/bash
chown jesse.jesse -R /data/k8s
for host in 10.10.20.102 10.10.20.103
do
    echo "==== $host ===="
    su jesse -c 'ssh -p 50022 jesse@'$host' "sudo mkdir -p /data/k8s/{bin,conf,etc/kubernetes/ssl};sudo chown -R jesse.jesse /data/k8s"'
    su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/k8s/bin/ jesse@'$host':/data/k8s/bin/'
    su jesse -c 'scp -P 50022 /data/k8s/etc/kubernetes/ssl/ca* jesse@'$host':/data/k8s/etc/kubernetes/ssl/'

    cp ~/.kube/config /tmp/kube-config
    chown jesse.jesse /tmp/kube-config
    su jesse -c 'scp -P 50022 /tmp/kube-config jesse@'$host':/tmp/'
    su jesse -c 'ssh -p 50022 jesse@'$host' "sudo mkdir -p /root/.kube;sudo cp /tmp/kube-config /root/.kube/config"'

#    su jesse -c 'scp -P 50022 /etc/bash_completion.d/docker jesse@'$host':/tmp/bash_completion.d_docker'
#    su jesse -c 'ssh -p 50022 jesse@'$host' "sudo cp /tmp/bash_completion.d_docker /etc/bash_completion.d/docker"'

#    su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/k8s/src/ jesse@'$host':/data/k8s/src/'
done
