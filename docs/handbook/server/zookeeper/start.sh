#! /bin/bash

TMPDIR=/tmp
mkdir -p ${TMPDIR}/zookeeper{1..3}
mkdir -p ${TMPDIR}/logs{1..3}
for i in {1..3}; do
    echo "${i}" > ${TMPDIR}/zookeeper${i}/myid
done

DIR=~/bin/apps/zookeeper
zkServer.sh start ${DIR}/zoo.1.cfg
zkServer.sh start ${DIR}/zoo.2.cfg
zkServer.sh start ${DIR}/zoo.3.cfg


