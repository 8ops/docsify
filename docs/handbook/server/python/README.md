

yum install zlib zlib-devel (注意顺序这个先装，否则后面安装解压时python出错)
wget --no-check-certificate https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz
tar xvzf Python-2.7.12.tgz 
cd Python-2.7.12
./configure --prefix=/usr/local/python
make && make install

需要注意yum; which yum
cat > /etc/profile.d/sqlite3-env.sh << EOF
export SQLITE3_HOME=/usr/local/sqlite3
export PATH=\${SQLITE3_HOME}/bin:\$PATH
EOF
source /etc/profile
echo $PATH
which python

wget https://bootstrap.pypa.io/ez_setup.py -O - | python
easy_install pip
easy_install pymongo
easy_install redis
easy_install simplejson

CentOS7.0 or Ubuntu 需要注意特殊情况
yum install -y mysql-devel.x86_64
easy_install MySQL-python

配置国内的源
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF

[global]  
index-url=http://mirrors.aliyun.com/pypi/simple

EOF


遇到“ImportError: No module named _sqlite3”问题。
解决办法：需先编译sqlite3.
wget http://www.sqlite.org/sqlite-amalgamation-3.6.20.tar.gz
tar zxvf  sqlite-amalgamation-3.6.20.tar.gz
cd  sqlite-3.5.6
./configure –prefix=/usr/local/sqlite3
make && make install  (这样，sqlite3编译完成）

再来编译python2.7.12:
wget http://python.org/ftp/python/2.7.12/Python-2.7.12.tar.xz
xz -d Python-2.7.12.tar.xz
tar xf  Python-2.7.12.tar

cd  Python-2.7.12
先修改Python-2.7.12目录里的setup.py 文件：
sqlite_inc_paths = [ ‘/usr/include’,
     ‘/usr/include/sqlite’,
     ‘/usr/include/sqlite3’,
     ‘/usr/local/include’,
     ‘/usr/local/include/sqlite’,
     ‘/usr/local/include/sqlite3’,
     ‘/usr/local/lib/sqlite3/include’,
     ‘/usr/local/sqlite3/include’, # 添加此行

./configure --prefix=/usr/local/python
make && make install  
（这样，python2.7.12编译完成，解决sqlite3导入出错的问题）


yum install -y -q libxslt-devel
pip install lxml




