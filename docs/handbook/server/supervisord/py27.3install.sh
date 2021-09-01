#!/bin/bash

#install python
function python_install(){
    wget http://ks.yw.youja.cn/Python-2.7.3.sslzlib.tar.gz
    tar zxvf Python-2.7.3.sslzlib.tar.gz
    cd Python-2.7.3
    ./configure --prefix=/usr/local/python2.7
    make all 
    make install
    
    #file modify
    mv /usr/bin/python /usr/bin/python.bak
    ln -s /usr/local/python2.7/bin/python2.7 /usr/bin/python2.7
    ln -s /usr/bin/python2.7 /usr/bin/python
    
    #update yum file
    cp /usr/bin/yum /usr/bin/yum.backup
    sed -i '1s&.*&#!/usr/bin/python2.6&' /usr/bin/yum
}



#install setuptools
function setuptoos_install(){
    wget  http://ks.yw.youja.cn/setuptools-0.6c11-py2.7.egg
    echo "setuptools-install"

    chmod +x setuptools-0.6c11-py2.7.egg
    ./setuptools-0.6c11-py2.7.egg
}

#install pip
function pip_install(){
    wget  http://ks.yw.youja.cn/pip-1.3.1.tar.gz
    tar zxvf pip-1.3.1.tar.gz
    cd pip-1.3.1
    python setup.py install
}

#main
#install event
yum install -y automake autoconf libtool make zlib zlib-devel openssl-devel gcc gcc-c++ bzip2-devel bzip2
yum install -y tcl tcl-devel

cd /usr/local/src
python_install

cd /usr/local/src
setuptoos_install

cd /usr/local/src
pip_install

ln -s /usr/local/python2.7/bin/pip /usr/bin/pip
