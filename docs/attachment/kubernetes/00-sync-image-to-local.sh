#!/bin/bash

###################################################################################
# origin: 
#   k8s.gcr.io/kube-apiserver:v1.21.4
#   k8s.gcr.io/kube-controller-manager:v1.21.4
#   k8s.gcr.io/kube-scheduler:v1.21.4
#   k8s.gcr.io/kube-proxy:v1.21.4 
#
# broker:
#   registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.21.4
#   registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.21.4
#   registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.21.4
#   registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.21.4
#
# target:
#
###################################################################################

set -e

src=registry.cn-hangzhou.aliyuncs.com
dst=hub.8ops.top

ver=$1
[ -z $ver ] && exit 1

for addon in kube-apiserver kube-controller-manager kube-scheduler kube-proxy
do
  image=$addon:$ver
  echo "docker pull $src/google_containers/$image $dst/google_containers/$image"
  docker pull $src/google_containers/$image
  docker tag  $src/google_containers/$image $dst/google_containers/$image
  docker push $dst/google_containers/$image
done

exit 0
