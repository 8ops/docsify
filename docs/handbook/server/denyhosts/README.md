
配置文件说明 /usr/share/denyhosts/denyhosts.cfg

# 用户登录的日志文件（ubuntu /var/log/auth.log centos and ferdon /var/log/secure）
SECURE_LOG = /var/log/auth.log

# 禁止登陆的主机文件
HOSTS_DENY = /etc/hosts.deny

# 清除已禁止主机的时间
PURGE_DENY = 5d

# 禁止的服务名
BLOCK_SERVICE = sshd

# 允许无效用户登录失败的次数
DENY_THRESHOLD_INVALID = 1

# 允许普通用户登陆失败的次数
DENY_THRESHOLD_VALID = 3

# 允许 root 用户登陆失败的次数
DENY_THRESHOLD_ROOT = 3

# 是否做域名反解
HOSTNAME_LOOKUP=NO

# 管理员邮件地址
ADMIN_EMAIL = admin@domain.com

# SMTP 的相关设置
SMTP_HOST = mail.domain.com
SMTP_PORT = 25
SMTP_USERNAME=denyhosts@domain.com
SMTP_PASSWORD=password
SMTP_FROM = DenyHosts 
SMTP_SUBJECT = DenyHosts Report from domain.com
#接收服务器：pop.exmail.qq.com(使用SSL，端口号995)
#发送服务器：smtp.exmail.qq.com(使用SSL，端口号465)

# DenyHosts 的日志文件
DAEMON_LOG = /var/log/denyhosts


设置启动脚本
cp /usr/share/denyhosts/daemon-control-dist /usr/share/denyhosts/daemon-control
chown root /usr/share/denyhosts/daemon-control
chmod 755 /usr/share/denyhosts/daemon-control
ln -s /usr/share/denyhosts/daemon-control /etc/init.d/denyhosts
chkconfig --level 345 denyhosts on

vim /etc/init.d/denyhosts
...
/usr/local/python/bin/denyhosts.py
/usr/local/python/bin/python
...

启动denyhosts
service denyhosts start


=====
安装步骤

cd /usr/local/src
wget http://nchc.dl.sourceforge.net/project/denyhosts/denyhosts/2.6/DenyHosts-2.6.tar.gz 
tar -zxvf DenyHosts-2.6.tar.gz
cd DenyHosts-2.6
python setup.py install
/bin/cp /usr/share/denyhosts/denyhosts.cfg-dist /usr/share/denyhosts/denyhosts.cfg
/bin/cp /usr/share/denyhosts/daemon-control-dist /usr/share/denyhosts/daemon-control
chown root /usr/share/denyhosts/daemon-control
chmod 755 /usr/share/denyhosts/daemon-control
ln -s /usr/share/denyhosts/daemon-control /etc/init.d/denyhosts
chkconfig --level 345 denyhosts on

cat > /usr/share/denyhosts/denyhosts.cfg << EOF
SECURE_LOG = /var/log/secure
HOSTS_DENY = /etc/hosts.deny
PURGE_DENY = 1d 
BLOCK_SERVICE  = sshd
DENY_THRESHOLD_INVALID = 1
DENY_THRESHOLD_VALID = 3
DENY_THRESHOLD_ROOT = 1
DENY_THRESHOLD_RESTRICTED = 1
WORK_DIR = /usr/share/denyhosts/data
SUSPICIOUS_LOGIN_REPORT_ALLOWED_HOSTS = YES
HOSTNAME_LOOKUP = NO
LOCK_FILE = /var/lock/subsys/denyhosts
ADMIN_EMAIL = jie.zhang@@youja.cn 
SMTP_HOST = smtp.exmail.qq.com
SMTP_PORT = 456
SMTP_USERNAME = auto_send_from_os
SMTP_PASSWORD = youja2014
SMTP_FROM = DenyHosts from aliyun 
SMTP_SUBJECT = DenyHosts Report aliyun
AGE_RESET_VALID = 5d
AGE_RESET_ROOT = 25d
AGE_RESET_RESTRICTED = 25d
AGE_RESET_INVALID = 10d
DAEMON_LOG = /var/log/denyhosts
DAEMON_SLEEP = 30s
DAEMON_PURGE = 1h

EOF

/etc/init.d/denyhosts start

cat > /usr/share/denyhosts/data/allowed-hosts << EOF
122.144.133.40
122.144.133.71
180.166.198.58
182.92.242.176
211.155.90.27
10.10.10.109
10.10.10.108
10.10.10.12
10.10.10.61

EOF

/etc/init.d/denyhosts restart

cat /etc/hosts.deny

ps -ef | grep deny






