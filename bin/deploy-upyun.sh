#!/bin/bash

[ `dirname $0` == "./bin" ] || exit 1
set -e

CTX_NAME=jesse-8ops-books
upx switch ${CTX_NAME}
[ "X${CTX_NAME}Y" == "X`upx sessions | awk '/^>/{printf $2}'`Y" ] || exit 1
upx sync --delete docs/ /
upx switch jesse-8ops-normal

printf "\nCompleted.\n\n"
