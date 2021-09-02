#!/bin/bash


dst=$1
[ -z $dst ] && read -p "Input destnation git(gitee/github): " dst
[ -z $dst ] && exit 1

if [ $dst == 'gitee' ]; then
cat > .git/config <<EOF
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[remote "origin"]
	url = git@gitee.com:ops8/books.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
EOF

elif [ $dst == 'github' ]; then
cat > .git/config <<EOF
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[remote "origin"]
	url = git@github.com:8ops/books.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
EOF
fi


