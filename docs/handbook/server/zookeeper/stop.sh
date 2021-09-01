#! /bin/bash

DIR=~/bin/apps/zookeeper
zkServer.sh stop ${DIR}/zoo.1.cfg
zkServer.sh stop ${DIR}/zoo.2.cfg
zkServer.sh stop ${DIR}/zoo.3.cfg


