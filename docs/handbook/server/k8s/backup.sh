#!/bin/bash

########
#
# memo: manual install new version
#
########

mkdir -p backup && cd backup
mkdir -p k8s
rsync -av \
--exclude .git \
--exclude *.pem \
--exclude *.key \
--exclude *.crt \
-e "ssh -p 50022" jesse@10.10.20.101:/data/k8s/etc/ k8s/etc/

rsync -av \
--exclude .git \
-e "ssh -p 50022" jesse@10.10.20.101:/data/k8s/yml/ k8s/yml/

scp -P 50022 jesse@10.10.20.101:/data/k8s/rsync* k8s/
scp -P 50022 jesse@10.10.20.101:/data/k8s/src/harbor/*.yml k8s/

