

Singapore
=============
# 系统信息
Red Hat Enterprise Linux Server release 7.0 (Maipo)
Linux ip-172-16-10-10.ap-southeast-1.compute.internal 3.10.0-123.8.1.el7.x86_64 #1 SMP Mon Aug 11 13:37:49 EDT 2014 x86_64 x86_64 x86_64 GNU/Linux


# user manage
groupadd -g 600 sshuser
groupadd -g 601 sudoer
useradd -G sshuser,sudoer jesse
useradd -G sshuser,sudoer ericdu
useradd -G sshuser,sudoer balaamwe
echo "youja+2014+jesse"|passwd jesse --stdin
echo "youja+2014+ericdu"|passwd ericdu --stdin
echo "youja+2014+balaamwe"|passwd balaamwe --stdin
#sed -i '/--dport 22/a\-A INPUT -m state --state NEW -m tcp -p tcp --dport 50022 -j ACCEPT' /etc/sysconfig/iptables
echo -e "\n%sudoer ALL=(ALL) ALL\njesse ALL=NOPASSWD:ALL\n" >> /etc/sudoers

# init tool and env
yum install -y binutils make cmake vim wget nmap nc lrzsz ntpdate tree rsync sysstat curl openssh-clients net-snmp-utils
sed -i '65a\export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' /etc/profile

# set history for profile
sed -i 's/HISTSIZE=1000/HISTSIZE=100/g' /etc/profile

# set welcome info
cat > /etc/issue << EOF
Welcome to www.youja.cn.
Redhat 7 x86_64 (Final)
EOF

# set server hostname
#echo "HOSTNAME=youja.cn" >> /etc/sysconfig/network
echo "youja.cn" > /etc/hostname

# set sshd_config
echo "AllowGroups sshuser" >> /etc/ssh/sshd_config
sed -i '/#PermitRootLogin yes/a\PermitRootLogin no' /etc/ssh/sshd_config
sed -i '/#Port 22/a\Port 50022' /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config << EOF

PermitEmptyPasswords no
UseDNS no
Banner /etc/issue
EOF

systemctl reload sshd.service
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# close system service
systemctl stop postfix.service
systemctl disable postfix.service
systemctl stop chronyd.service
systemctl disable chronyd.service
systemctl stop avahi-daemon.service
systemctl disable avahi-daemon.service
systemctl stop Firewalld.service
systemctl disable Firewalld.service

# ulimit sets
cat > /etc/security/limits.conf << EOF
* soft nofile 65536
* hard nofile 65536
* hard nproc 4096
* soft nproc 4096
EOF
cat > /etc/security/limits.d/20-nproc.conf << EOF
*          soft    nproc     4096
EOF

# tcp for kernel
cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.tcp_syncookies = 1
kernel.shmmni = 10240
kernel.sem = 250 32000 100 128
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
fs.file-max = 1213051
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_keepalive_time = 10
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_tw_buckets = 10240

net.netfilter.nf_conntrack_tcp_timeout_established = 60
net.netfilter.nf_conntrack_max = 655350
net.nf_conntrack_max = 655350


EOF

# user ssh key
mkdir /home/jesse/.ssh
cat > /home/jesse/.ssh/authorized_keys << EOF
ssh-dss AAAAB3NzaC1kc3MAAACBALN+zutgLhYyLEgmNnW9DbaVnPCLlq3dMv1gCk80lm7ufcUzNp9zvR3OrCECAq3s1w9vVPqWMfg21LkAAF/e/eTgBYI+aF4s+4z+Cn4eiXTyM0mRyuQ0YxWqs3GJLBjqcLVdOpWGy5F3X/9sAe9lG+SbbErSy68YxmYv7U40ha/9AAAAFQDtw6YYdKinAPj6hu6S3Islyb3ZdQAAAIAIIFtUk2V4ASA2QgE2OGLVM/QMeRYaRVdP/OHF4Ri2kvR0B3s5P1C652PKnc97bwb0BTHqDhTJoqfSKiHLHLBdfQXdLY1LLh/hiBdPasMrUMiSEhiy+pvjNqwW1BqL6b4hBpvooVkdHTk/6pKTYQwVhJ2oN8+0FzUk6GC+VseM8AAAAIEAg8LYT2iAv0hicgHFo3qmqv/MFvJQISlRWm0TxRBa3FFp6EH4MuaRzzVekur79h+oDOf/41QZ+j9M2oh5RdePUDGOQ6S3WBcppQOYc5vzF37wPv2Z1p1lD8vRSu2yNMxPjkMvlRu1+plYjjLyQvicyJbX7jN+DDl/iDp1pKYY5vg=
ssh-dss AAAAB3NzaC1kc3MAAACBANyhLAY0OZcXuP/zoSzb2wHp8yEd7C5bjLw794bPNHKJeYX8Whz0plqUirP9rKxiXGm1B2Nwnpf9wNmso/EFquMA2kVjAT56i7tvPNj5V/PmkUT5FIhApoFqw9pZ90vHPDyB8u/u4oNNO0N9sschVEJa592boH4u28rSvd78sAlfAAAAFQCH+kjWbyk1bm2RhroMkPx/zsQaWwAAAIAzFvXSzBWrm92V322txFVRwLU2ahz7V9H6Ff6OQEpdL0bylMQj6MD6d+v5P1H1fuPgCDtBB87XRGnvV4IonMocr2/Qm/YwUOnRZOLbg05/5wVZiJQkLsErnDgeFGat+Ib97P5ytLvZXPf1m/tW6FoxplZq5GjvQAQ2A7Cw/voQjwAAAIASoJ05CkDWzgfg4eBonFPEtJbF8eGIEqH6y1e09NmBlw6S4khGfU3thg5OPQYfRLdOCg/4rnrc31T2TUnZaoL+W+nJe6+4uAiMFBTszpVlvQ1JD8yNPgIVZJD8/BMXE0eGLu+OVvMHlqTGIev8dUO+Iv3a3wBPuA8ReiI9ZTK+cw==
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV5RZ2Cmd3rk01XgbMzubxQYFVcFznSnzadcB1dhDaw7MiC3DRLGU5YLgsZmZdZQxrGSVEXmXwEKrD9oxcwL31DnWJdjzsnJrHXv/6LXKh03OlQ7Di4UoNLxpFHZecX2o23fYuTdFBojL8sSeI9jucVAAskMFW0rJHcKiv1/f/CJnUIH604Z6xeHK7tfqJUJ+bxuLuhFgbMymHkbqNI2UU0L4LHBg8IvPIROA86xbSmgINZ/ccbhy7ZEhGOODLCY4K3AlVaWQqMrhjjOA003TBtYbrKGFWpG+KFdTVAbZjVawGbnWtSN03qYQPYmbSY5e1sH/oTyfzwWVeFI1d8tbv
EOF
chmod 700 /home/jesse/.ssh
chown jesse.jesse -R /home/jesse/.ssh

cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
mirrorlist=http://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 6 - \$basearch - Debug
mirrorlist=http://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=\$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 6 - \$basearch - Source
mirrorlist=http://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=\$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1

EOF

cat > /etc/yum.repos.d/nginx.repo << EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/6/x86_64/
gpgcheck=0
enabled=1

EOF

cat > /etc/yum.repos.d/varnish.repo << EOF
[varnish-3.0]
name=Varnish 3.0 for Enterprise Linux el6 - \$basearch
baseurl=http://repo.varnish-cache.org/redhat/varnish-3.0/el6/\$basearch
enabled=1
gpgcheck=0

EOF

# 时区，语言，DNS，路由，NTP

--------------------------------------------------------------------------------

# 时区
/bin/cp /usr/share/zoneinfo/Asia/Singapore /etc/localtime
/bin/cp /usr/share/zoneinfo/America/New_York /etc/localtime
/sbin/ntpdate 0.rhel.pool.ntp.org

echo "30 5 * * * /usr/sbin/ntpdate ntp.uplus.youja.cn" | crontab -
echo "/usr/sbin/ntpdate ntp.uplus.youja.cn" >> /etc/rc.local
echo "nameserver 192.168.1.213" > /etc/resolv.conf








