#!/bin/bash

########
#
# memo: yum install
#
########

mkdir -p 1.5.2 && cd 1.5.2
mkdir -p master/k8s/ master/etcd/ master/kubernetes/
rsync -av --exclude .git -e "ssh -p 50022" jesse@10.10.10.36:/data/yaml/ master/yaml/
rsync -av --exclude .git -e "ssh -p 50022" jesse@10.10.10.36:/etc/etcd/ master/etcd/
rsync -av --exclude .git -e "ssh -p 50022" jesse@10.10.10.36:/etc/kubernetes/ master/kubernetes/

mkdir -p node/k8s/ node/etcd/ node/kubernetes/
rsync -av -e "ssh -p 50022" jesse@10.10.10.37:/etc/kubernetes/ node/kubernetes/
