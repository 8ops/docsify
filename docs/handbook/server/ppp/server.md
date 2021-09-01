rpm -Uvh http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
加入yum源
2.yum install pptpd
3. yum install ppp
4.vi /etc/ppp/options.pptpd

1、配置文件编写
①、配置文件/etc/ppp/options.pptpd
mv /etc/ppp/options.pptpd /etc/ppp/options.pptpd.bak
vi /etc/ppp/options.pptpd
输入以下内容：
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
proxyarp
lock
nobsdcomp
novj
novjccomp
nologfd
idle 2592000
ms-dns 8.8.8.8  //DNS可以不设置
ms-dns 8.8.4.4

--------------------------------------------------------------------------------

②、配置文件/etc/ppp/chap-secrets
mv /etc/ppp/chap-secrets /etc/ppp/chap-secrets.bak
vi /etc/ppp/chap-secrets
输入以下内容
# Secrets for authentication using CHAP
# client         server   secret                   IP addresses
zhangjie pptpd ssxcEDfgd 10.0.0.250
vmcenter pptpd asdfdDSDF 10.0.0.251
wangyi   pptpd vpnOttpod 10.0.0.252
wangjian pptpd Dg3e20exq 10.0.0.253

  注：这里的myusername和mypassword即为PPTP VPN的登录用户名和密码


--------------------------------------------------------------------------------

③、配置文件/etc/pptpd.conf
mv /etc/pptpd.conf /etc/pptpd.conf.bak
vi /etc/pptpd.conf
输入以下内容：
option /etc/ppp/options.pptpd
logwtmp
localip 117.135.151.114
remoteip 10.0.0.250-254
  注：为拨入VPN的用户动态分配192.168.1.250～192.168.1.252之间的IP


--------------------------------------------------------------------------------

④、配置文件/etc/sysctl.conf
vi /etc/sysctl.conf
修改以下内容：
net.ipv4.ip_forward = 1

保存、退出后执行：
/sbin/sysctl -p

--------------------------------------------------------------------------------

3、启动PPTP VPN 服务器端：
/sbin/service pptpd start

--------------------------------------------------------------------------------

  4、启动iptables：//可设置也可不设置,如防火墙开启则一定要设置
/sbin/service iptables start
/sbin/iptables -t nat -A POSTROUTING -o eth0 -s 192.168.1.0/24 -j MASQUERADE


