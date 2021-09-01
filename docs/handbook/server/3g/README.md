测试3G网卡
移动 Huawei ET302S     
联通 Huawei E261         网关 10.64.64.64 
电信 Huawei Ec167        网关 172.16.126.178


尝试
1，工具安装

apt-get install -y usb_modeswitch
apt-get install -y wvdial

2，3G网卡识别成usb设备，默认配置文件 /etc/usb_modeswitch.conf

DefaultVendor= 0x12d1
DefaultProduct= 0x1436
TargetVendor= 0x12d1
TargetProduct= 0x1436
TargetClass = 0x005
HuaweiMode=1
DetachStorageOnly=1

运行

usb_modeswitch -W -c /etc/usb_modeswitch.conf

or

usb_modeswitch -v 0x12d1 -p 0x1436 -V 0x12d1 -P 0x1436 -C 0x005 DetachStorageOnly=1 HuaweiMode=1 -W



3，wvdial配置，默认配置文件  /etc/wvdial.conf

[Dialer Defaults]
Init1 = ATZ
Init2 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
Modem Type = Analog Modem
Baud = 9600
New PPPD = yes
Modem = /dev/ttyUSB0
ISDN = 0
Phone = *99#
Password = any
Username = any

运行
wvdial -c /etc/wvdial.conf -n

目标            网关            子网掩码        标志  跃点   引用  使用 接口
0.0.0.0         192.168.5.1     0.0.0.0         UG    100    0        0 eth0
10.64.64.64     0.0.0.0         255.255.255.255 UH    0      0        0 ppp0
169.254.0.0     0.0.0.0         255.255.0.0     U     1000   0        0 eth0
192.168.5.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0

route del -net 0.0.0.0
route add -net 0.0.0.0 netmask 0.0.0.0 gw 10.64.64.64 metric 100

目标            网关            子网掩码        标志  跃点   引用  使用 接口
0.0.0.0         10.64.64.64     0.0.0.0         UG    100    0        0 ppp0
10.64.64.64     0.0.0.0         255.255.255.255 UH    0      0        0 ppp0
169.254.0.0     0.0.0.0         255.255.0.0     U     1000   0        0 eth0
192.168.5.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0


4，ppp拨号
编辑并配置/etc/ppp/options,如下所示：
noipdefault
ipcp-accept-local
ipcp-accept-remote
defaultroute
noauth
crtscts
debug

编写自动化脚本
1.拨号脚本 /etc/ppp/ppp-on:
#!/bin/sh
# This script initiates the ppp connections by wvdial
wvdial tom &

断开连接自动化脚本/etc/ppp/ppp-off:
#!/bin/sh
#!stop wvdial
killall wvdial
# If the ppp0 pid file is present then the program is running. Stop it
if [ -r /var/run/ppp0.pid ]; then
    kill -INT `cat /var/run/ppp0.pid`
    echo "PPP link to ppp0 terminated."
else
    echo "ERROR: PPP link is not active on ppp0"
    exit 0
fi
exit 1

chmod +x /etc/ppp/ppp-*


