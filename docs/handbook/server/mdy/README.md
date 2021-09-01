


===================> bind dns
http://wubinary.blog.51cto.com/8570032/1376390
http://heylinux.com/archives/3308.html
https://wiki.archlinux.org/index.php/BIND_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)
http://linux.vbird.org/linux_server/0350dns.php
https://www.isc.org/downloads/


---------------------------------

/dev/sdb                /data                   xfs    defaults,noatime,nodiratime,nosuid,nodev,allocsize=4m        0 0

xfs_info /dev/sdb; mount | grep xfs

mkfs.xfs -f -i size=512 -l size=64m,lazy-count=1 -d agcount=16 /dev/sdb

defaults,noatime,nobarrier 

W
rm -f /data/dd-*
for i in {1..5};do time dd if=/dev/zero of=/data/dd-0$i bs=1M count=100;done;

rm -f /data/dd-*
for i in {1..5};do time dd if=/dev/zero of=/data/dd-0$i bs=10M count=100;done;

R
for i in {1..5};do time dd if=/data/dd-0$i of=/dev/null bs=1M count=100;done

for i in {1..5};do time dd if=/data/dd-0$i of=/dev/null bs=10M count=100;done


mkfs.xfs -f -i size=512 -l size=64m,lazy-count=1 -d agcount=16 /dev/sdb
/dev/sdb                /data                   xfs     defaults,noatime,nobarrier        0 0


echo -n "" > /var/log/wtmp;echo -n "" > /var/log/rtmp;history -c; echo -n ""> ~/.bash_history;history -c

====================> install

yum install -y -q curl gcc memcached rsync sqlite xfsprogs git-core \
    libffi-devel xinetd liberasurecode-devel \
    python-setuptools \
    python-coverage python-devel python-nose \
    pyxattr python-eventlet \
    python-greenlet python-paste-deploy \
    python-netifaces python-pip python-dns \
    python-mock \
    tree \
    vim

mkfs.xfs -f /dev/sdb

/dev/sdb /swift/device01 xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0

mkdir -p /swift/device01
mount -a
mount | grep xfs

#useradd -M swift
useradd -m swift
chown -R swift.swift /swift

==> python env
curl -s http://yp.fs.8ops.com/python/auto_update_python.sh | bash

==> swift-client

cd /usr/local/src
git clone https://github.com/openstack/python-swiftclient.git
cd ./python-swiftclient
git checkout 2.4.0
python setup.py develop
cd -


==> swift

cd /usr/local/src
git clone https://github.com/openstack/swift.git
cd ./swift
git checkout 2.4.0
pip install -r requirements.txt
python setup.py develop
cd -

==> cache

mkdir -p /var/run/swift
chown swift:swift /var/run/swift
mkdir -p /var/cache/swift
chown swift:swift /var/cache/swift

==> rsync <未使用>

cat > /etc/rsyncd.conf <<EOF

uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = 0.0.0.0

[account]
max connections = 25
path = /swift/device01/
read only = false
lock file = /var/lock/account.lock

[container]
max connections = 25
path = /swift/device01/
read only = false
lock file = /var/lock/container.lock

[object]
max connections = 25
path = /swift/device01/
read only = false
lock file = /var/lock/object.lock

EOF

chkconfig rsyncd on
/etc/init.d/rsyncd start

==> rsyslog <未使用>

==> memcached

cat > /etc/sysconfig/memcached <<EOF
PORT="11211"
USER="memcached"
MAXCONN="4096"
CACHESIZE="64"
OPTIONS=""

EOF

chkconfig memcached on
/etc/init.d/memcached start

==> swift config 

mkdir -p /etc/swift
chown -R swift:swift /etc/swift

cat > /etc/swift/swift.conf << EOF
[swift-hash]
swift_hash_path_suffix = jtangfs

EOF

cat > /etc/swift/account-server.conf <<EOF
[DEFAULT]
devices = /swift/device01
mount_check = false
bind_ip = 0.0.0.0
bind_port = 6002
workers = 4
user = swift
log_facility = LOG_LOCAL4

[pipeline:main]
pipeline = account-server

[app:account-server]
use = egg:swift

[account-replicator]
[account-auditor]
[account-reaper]

EOF

cat > /etc/swift/container-server.conf <<EOF
[DEFAULT]
devices = /swift/device01
mount_check = false
bind_ip = 0.0.0.0
bind_port = 6001
workers = 4
user = swift
log_facility = LOG_LOCAL3

[pipeline:main]
pipeline = container-server

[app:container-server]
use = egg:swift

[container-replicator]

[container-updater]

[container-auditor]

[container-sync]

EOF

cat > /etc/swift/object-server.conf <<EOF
[DEFAULT]
devices = /swift/device01
mount_check = false
bind_ip = 0.0.0.0
bind_port = 6000
workers = 4
user = swift
log_facility = LOG_LOCAL2

[pipeline:main]
pipeline = object-server

[app:object-server]
use = egg:swift

[object-replicator]

[object-updater]

[object-auditor]


EOF

cat > /etc/swift/proxy-server.conf <<EOF
[DEFAULT]
bind_port = 8080
user = swift
workers = 2
log_facility = LOG_LOCAL1

[pipeline:main]
pipeline = healthcheck cache tempauth proxy-logging proxy-server

[app:proxy-server]
use = egg:swift
allow_account_management = true
account_autocreate = true

[filter:tempauth]
use = egg:swift
user_admin_admin = admin .admin .reseller_admin
user_test_tester = testing .admin
user_test2_tester2 = testing2 .admin
user_test_tester3 = testing3
reseller_prefix = AUTH
token_life = 86400

[filter:healthcheck]
use = egg:swift

[filter:cache]
use = egg:swift
memcache_servers = 192.168.121.38:11211,192.168.121.39:11211

[filter:proxy-logging]
use = egg:swift

EOF


==> ring

cat > /etc/swift/configure.sh <<EOF
#!/bin/bash
# configure
cd /etc/swift

rm -f *.builder *.ring.gz backups/*.builder backups/*.ring.gz

swift-ring-builder account.builder   create 18 3 1
swift-ring-builder container.builder create 18 3 1
swift-ring-builder object.builder    create 18 3 1

swift-ring-builder account.builder   add r1z1-192.168.121.38:6002/device01 100
swift-ring-builder container.builder add r1z1-192.168.121.38:6001/device01 100
swift-ring-builder object.builder    add r1z1-192.168.121.38:6000/device01 100

swift-ring-builder account.builder   add r1z2-192.168.121.39:6002/device01 100
swift-ring-builder container.builder add r1z2-192.168.121.39:6001/device01 100
swift-ring-builder object.builder    add r1z2-192.168.121.39:6000/device01 100

swift-ring-builder account.builder   rebalance
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder    rebalance

EOF

cat > /etc/swift/reset.sh <<EOF
#!/bin/bash
# reset

swift-init all stop

find /var/log/swift -type f -exec rm -f {} \;

umount /swift/device01
mkfs.xfs -f -i size=1024 /dev/sdb
mount /swift/device01

chown swift:swift /swift

rm -f /var/log/debug /var/log/messages /var/log/rsyncd.log /var/log/syslog
/etc/init.d/rsyslog restart
/etc/init.d/memcached restart

EOF

cat > /etc/swift/startup.sh <<EOF
#!/bin/bash
swift-init main start

EOF

cat > /etc/swift/stop.sh <<EOF
#!/bin/bash
swift-init main stop

EOF

chmod +x /etc/swift/*.sh

/etc/swift/configure.sh 





~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
0 1 1 * * /usr/sbin/ntpdate -u cn.pool.ntp.org

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2016-06-14

rm -rf /swift/device01/* /var/cache/swift /var/log/swift
mkdir -p /var/cache/swift /var/log/swift
chown -R swift.swift /etc/swift /swift /var/cache/swift
su swift
cd /etc/swift/
rsync -av --delete /usr/local/src/swift/etc/ /etc/swift/

mv proxy-server.conf-sample proxy-server.conf
mv object-server.conf-sample object-server.conf
mv account-server.conf-sample account-server.conf
mv container-server.conf-sample container-server.conf
mv container-reconciler.conf-sample container-reconciler.conf
mv swift.conf-sample swift.conf
mv object-expirer.conf-sample object-expirer.conf

sed -i '8 s/^swift_hash_path_suffix = changeme/swift_hash_path_suffix = jesse/' swift.conf
sed -i '9 s/^swift_hash_path_prefix = changeme/swift_hash_path_prefix = jesse/' swift.conf

sed -i '2 s/^# bind_ip = 0.0.0.0/bind_ip = 0.0.0.0/' account-server.conf
sed -i '6 s/^# user = swift/user = swift/' account-server.conf
sed -i '8 s/^# devices = \/srv\/node/devices = \/swift/' account-server.conf
sed -i '9 s/^# mount_check = true/mount_check = true/' account-server.conf
sed -i '14 s/^# workers = auto/workers = 4/' account-server.conf
sed -i '21 s/^# log_facility = LOG_LOCAL0/log_facility = LOG_LOCAL0/' account-server.conf

sed -i '2 s/^# bind_ip = 0.0.0.0/bind_ip = 0.0.0.0/' container-server.conf
sed -i '6 s/^# user = swift/user = swift/' container-server.conf
sed -i '8 s/^# devices = \/srv\/node/devices = \/swift/' container-server.conf
sed -i '9 s/^# mount_check = true/mount_check = true/' container-server.conf
sed -i '14 s/^# workers = auto/workers = 4/' container-server.conf
sed -i '27 s/^# log_facility = LOG_LOCAL0/log_facility = LOG_LOCAL0/' container-server.conf

sed -i '2 s/^# bind_ip = 0.0.0.0/bind_ip = 0.0.0.0/' object-server.conf
sed -i '6 s/^# user = swift/user = swift/' object-server.conf
sed -i '8 s/^# devices = \/srv\/node/devices = \/swift/' object-server.conf
sed -i '9 s/^# mount_check = true/mount_check = true/' object-server.conf
sed -i '17 s/^# workers = auto/workers = 4/' object-server.conf
sed -i '30 s/^# log_facility = LOG_LOCAL0/log_facility = LOG_LOCAL0/' object-server.conf

sed -i '2 s/^# bind_ip = 0.0.0.0/bind_ip = 0.0.0.0/' proxy-server.conf
sed -i '7 s/^# user = swift/user = swift/' proxy-server.conf
sed -i '27 s/^# workers = auto/workers = 2/' proxy-server.conf
sed -i '43 s/^# log_facility = LOG_LOCAL0/log_facility = LOG_LOCAL0/' proxy-server.conf
sed -i '123 s/^# allow_account_management = false/allow_account_management = true/' proxy-server.conf
sed -i '133 s/^# account_autocreate = false/account_autocreate = true/' proxy-server.conf
sed -i '386 s/^# memcache_servers = 127.0.0.1:11211/memcache_servers = 192.168.121.38:11211,192.168.121.39:11211/' proxy-server.conf

swift-ring-builder account.builder create 18 2 1
swift-ring-builder container.builder create 18 2 1
swift-ring-builder object.builder create 18 2 1

zone=1
ip=192.168.121.38
device=device01

swift-ring-builder account.builder add r1z$zone-$ip:6002/$device 100
swift-ring-builder container.builder add r1z$zone-$ip:6001/$device 100
swift-ring-builder object.builder add r1z$zone-$ip:6000/$device 100

zone=2
ip=192.168.121.39
device=device01

swift-ring-builder account.builder add r1z$zone-$ip:6002/$device 100
swift-ring-builder container.builder add r1z$zone-$ip:6001/$device 100
swift-ring-builder object.builder add r1z$zone-$ip:6000/$device 100

swift-ring-builder account.builder rebalance
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder rebalance


cat > start_swift.sh <<EOF
#!/bin/bash

swift-init main start

sleep 3

swift-init proxy start
swift-init account-server start
swift-init account-replicator start
swift-init account-auditor start
swift-init container-server start
swift-init container-replicator start
swift-init container-updater start
swift-init container-auditor start
swift-init object-server start
swift-init object-replicator start
swift-init object-updater start
swift-init object-auditor start

EOF

cat > stop_swift.sh <<EOF
#!/bin/bash

swift-init proxy stop
swift-init account-server stop
swift-init account-replicator stop
swift-init account-auditor stop
swift-init container-server stop
swift-init container-replicator stop
swift-init container-updater stop
swift-init container-auditor stop
swift-init object-server stop
swift-init object-replicator stop
swift-init object-updater stop
swift-init object-auditor stop

sleep 3

swift-init main stop

EOF

chmod +x start_swift.sh stop_swift.sh 


rsync -av -e "ssh -p 22234 " swift@192.168.121.38:/etc/swift/ /etc/swift/


# get X-Storage-Url or X-Auth-Token
curl -i \
-H 'X-Storage-User: test:tester' \
-H 'X-Storage-Pass: testing' \
http://127.0.0.1:8080/auth/v1.0 

# view account
curl -i \
-H 'X-Auth-Token: AUTH_tk8aafea3b862e4231b5f8e33e288bbc24' \
http://127.0.0.1:8080/v1/AUTH_test

# create container
curl -i \
-X PUT \
-H "X-Auth-Token: AUTH_tk8aafea3b862e4231b5f8e33e288bbc24" \
http://127.0.0.1:8080/v1/AUTH_test/test_container 


swift \
-A http://127.0.0.1:8080/auth/v1.0 \
-U test:tester \
-K testing stat

swift \
-A http://127.0.0.1:8080/auth/v1.0 \
-U test:tester \
-K testing \
post default

swift \
-A http://127.0.0.1:8080/auth/v1.0 \
-U test:tester \
-K testing \
list

swift \
-A http://127.0.0.1:8080/auth/v1.0 \
-U test:tester \
-K testing \
upload default /usr/local/src/Python-2.7.11.tgz

swift \
-A http://127.0.0.1:8080/auth/v1.0 \
-U test:tester \
-K testing \
list default

swift \
-A http://127.0.0.1:8080/auth/v1.0 \
-U test:tester \
-K testing \
download default usr/local/src/Python-2.7.11.tgz

