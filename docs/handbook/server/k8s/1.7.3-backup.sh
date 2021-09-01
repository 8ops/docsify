#!/bin/bash

########
#
# memo: manual install
#
########

mkdir -p 1.7.3 && cd 1.7.3
mkdir -p k8s
rsync -av --exclude .git -e "ssh -p 50022" jesse@10.10.20.101:/data/k8s/conf/ k8s/conf/
scp -P 50022 jesse@10.10.20.101:/data/k8s/rsync* k8s/

