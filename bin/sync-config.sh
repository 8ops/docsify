#!/bin/bash


function sync_kubernetes(){

rsync -av --delete -e"ssh" root@10.101.11.240:/opt/helm/ ./docs/attachment/kubernetes/helm/

}

#------------------------------------------------------------------------------

[ `dirname $0` == "./bin" ] || exit 1
sync_kubernetes

