更新于2013-11-30

1，安装pptp客户端
cd /usr/local/src
#wget http://nchc.dl.sourceforge.net/sourceforge/pptpclient/pptp-1.7.1.tar.gz
wget http://superb-dca3.dl.sourceforge.net/project/pptpclient/pptp/pptp-1.8.0/pptp-1.8.0.tar.gz
tar xvzf pptp-1.7.1.tar.gz
cd pptp-1.7.1
make && make install

2，配置
vim /etc/ppp/peers/qtestin-21

remotename Tmonitor
linkname Tmonitor
ipparam Tmonitor
pty "pptp vpn.yw.qtestin.com --nolaunchpppd "
name Tmonitor
usepeerdns
require-mppe
refuse-eap
noauth

3，拨号
pppd call qtestin-21
route add -net 10.10.10.0 netmask 255.255.255.0 dev ppp0

route add -net 172.16.0.0/16 dev ppp0

pptp.sh
1.9 KB



4，测试
通过

vpn 服务器

iptables -t nat -A  POSTROUTING -s 10.10.10.0/24 -o eth1 -j MASQUERADE
iptables -t nat -A  POSTROUTING -s 10.10.10.0/24 -o ppp0 -j MASQUERADE

windows client
route delete 10.0.0.0
route add 10.0.0.0/8 10.10.10.10

QTestin-david ==> qtestin-15（能出不能进，跟公司的防火墙有关）
A43S-david ==>qtestin-16
beijing_tele_118.244.134.34     ==> qtestin-17
chongqing_tele_219.153.64.211 ==> qtestin-18




如果你需要在Linux中拨入虚拟网络中，那就需要安装Linux下相应VPN的客户端，本文将介绍以pptp方式拨入虚拟网络的VPN的方法。
　　以下操作均在root用户下操作完成，并假设你的Linux系统已经安装了编译环境。
　　１、下载pptp客户端
　　wget http://nchc.dl.sourceforge.net/sourceforge/pptpclient/pptp-1.7.1.tar.gz
　　2、解压
　　tar zxvf pptp-1.7.1.tar.gz
　　3、编译和安装
　　make; make install
　　4、编辑配置文件，设定拨号名为mypptp
　　vim /etc/ppp/peers/mypptp
　　内容如下：

 

remotename Tmonitor
linkname Tmonitor
ipparam Tmonitor
pty "pptp 61.147.88.113 --nolaunchpppd "
name Tmonitor
usepeerdns
require-mppe
refuse-eap
noauth


      其中，myaccount为用户名
　　5、编辑/etc/ppp/chap-secrets，加入用户名和帐号，这里假设myaccount的密码为mypassword
     myaccount * mypassword *
　　6、拨号，运行以下命令
     /usr/sbin/pppd call mypptp logfd 1 updetach
　　如果以上配置文件正确无误，则可正常拨入虚拟网管的pptp VPN网络中了，此时如果用ifconfig查看连接情况，可以看到多了一条ppp连接，并能正确分到IP地址了。
　　７、添加路由
　　虽然已经拨号上来了，但此时，如果你要访问你的虚拟局域网资源，你必需添加一条路由才行，这里假设你拨号上来的连接名为ppp0，并此你的虚拟局域网的IP段为192.168.163.0，那么，你需要加入以下命令： 
     route add -net 192.168.163.0 netmask 255.255.255.0 dev ppp0
　 至此，在Linux系统下以pptp方式拨入虚拟网络的VPN网络中了。
     PS：如果在拨号时报以下错误：
     /usr/sbin/pppd:pty option precludes specifying device name
     请检查pppd的版本，不可低于2.3.7。
     检查/etc/ppp/optoins文件，该文件不能为空。
