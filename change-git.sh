#!/bin/bash


dst=$1
[ -z $dst ] && read -p "Input destnation git(gitee/github): " dst
[ -z $dst ] && exit 1

if [ $dst == 'gitee' ]; then
  /bin/cp .git/config-gitee .git/config
elif [ $dst == 'github' ]; then
  /bin/cp .git/config-github .git/config
fi


