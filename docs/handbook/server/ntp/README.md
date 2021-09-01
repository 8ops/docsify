yum install -y ntp.x86_64

vim /etc/ntp.conf

/bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo "30 5 * * * /usr/sbin/ntpdate -u ntp.uplus.youja.cn" | crontab -


