
================================================================================

yum install -y gcc* c++ * autoconf automake zlib*  libxml* ncurses-devel libmcrypt* libtool-ltdl-devel* cmake* make bison.x86_64 bison-devel.x86_64

#http://uplus.file.youja.cn/db/Percona-Server-5.5.24-rel26.0.tar.gz
http://yp.fs.8ops.cc/db/Percona-Server-5.5.24-rel26.0.tar.gz
http://qn.fs.8ops.cc/db/Percona-Server-5.5.24-rel26.0.tar.gz

useradd -M mysql
tar zxvf Percona-Server-5.5.24-rel26.0.tar.gz
cd Percona-Server-5.5.24-rel26.0
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/data/mysql \
-DMYSQL_UNIX_ADDR=/tmp/mysqld.sock \
-DDEFAULT_CHARSET=utf8 \
-DMYSQL_USER=mysql \
-DWITH_DEBUG=0
make && make install

--------
安装了ncurses-devel包后，删除CMakeCache.txt，然后重新编译，编译成功，问题解决！

character-set-server = utf8
collation-server = utf8_general_ci
--------

mkdir -p /data/mysql /data/mysqllog/binlog
touch /data/mysqllog/binlog/mysql-bin.index
cd /usr/local/mysql
chown -R mysql.mysql .
chown -R mysql.mysql /data/mysql /data/mysqllog
chmod 777 /var/run

./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
/bin/cp support-files/my-medium.cnf /etc/my.cnf
/bin/cp support-files/mysql.server /etc/init.d/mysql.server

--------------------------
vim /etc/my.cnf # master
server-id = 10
log-bin = mysql-bin

vim /etc/my.cnf # slave
server-id = 100
log-bin = mysql-bin
master-host = 192.168.1.222
master-user = rsync
master-password = jesse
master-port = 3306
expire_logs_days = 5
replicate-ignore-db = mysql
replicate-ignore-db = information_schema

grant all privileges on *.* to 'tongbu'@'10.10.50.101' identified by 'tongbu';

flush tables with read lock; # master

slave stop; # slave
change master to 
master_host='10.10.50.101', 
master_user='tongbu', 
master_password='tongbu', 
master_log_file='mysql-bin.000001', 
master_log_pos=755;
slave start;

unlock tables; #master

show master status\G;
show slave status\G;


set global read_only=1;       (default 0 or OFF)
show variables like 'read_only';
类redis　slave功能，从库非super权限用户只允许读功能。注意root用户只读无效，因为root是super权限

set global log_slave_updates=1; (default 0 or OFF)
show variables like 'log_slave_updates'; # 主-从（主）-从 这样的链条式结构只有加上它，从前一台机器上同步过来的数据才能同步到下一台机器

create database D_001 default character set utf8;
create table T_001(id int primary key auto_increment,name varchar(20));

select host,user,password from mysql.user;
create user 'test'@'%' identified by 'test';
grant all privileges on test.* to 'test'@'%' with grant option;

--------------------------

----
federated

没有成功
./configure ... --with-federated-storage-engine
or 
cmake ... -DWITH_PERFSCHEMA_STORAGE_ENGINE=1

/etc/my.cnf
[mysqld]
federated

how to use federated
CREATE TABLE test_table (
    id     int(20) NOT NULL auto_increment,
    name   varchar(32) NOT NULL default '',
    other  int(20) NOT NULL default '0',
    PRIMARY KEY  (id),
    KEY name (name),
    KEY other_key (other)
) ENGINE=MyISAM;

接着, 在本地服务器上为访问远程表创建一个FEDERATED表:
CREATE TABLE federated_table (
    id     int(20) NOT NULL auto_increment,
    name   varchar(32) NOT NULL default '',
    other  int(20) NOT NULL default '0',
    PRIMARY KEY  (id),
    KEY name (name),
    KEY other_key (other)
) ENGINE=FEDERATED CONNECTION='mysql://username:password@hostname/database/tablename';


----
在已经装好的percona版本下直接
install plugin federated soname 'ha_federated.so';
/etc/my.cnf
[mysqld]
federated
重启就支持了






