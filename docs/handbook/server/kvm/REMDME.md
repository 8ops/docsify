
CentOS 7

一、硬件环境检测

KVM的虚拟化需要硬件支持（如Intel VT技术或者AMD V技术)。是基于硬件的完全虚拟化。而Xen早期则是基于软件模拟的Para-Virtualization，新版本则是基于硬件支持的完全虚拟化。但Xen本身有自己到进程调度器，存储管理模块等，所以代码较为庞大。广为流传的商业系统虚拟化软件VMware ESX系列也是基于软件模拟的Para-Virtualization。

grep -E --color 'vmx|svm' /proc/cpuinfo
有输出代表cpu支持，否则代表cpu不支持。

二、软件包安装

这里以centos6为例，安装软件前最好先用yum update 先做下升级操作。

# yum install qemu-kvm qemu-img
# yum install virt-managerlibvirt libvirt-python python-virtinst libvirt-client virt-viewer
也可以使用groupinstall进行安装，如下：

# yum groupinstall -y  Virtualization  "Virtualization Client""Virtualization Platform" "Virtualization Tools"
需要注意的是在使用桥接网络时，还需要安装bridge-utils包，不然会报“btctl  not found 的错误” ，安装方法如下：

#yum -y install bridge-utils
三、防火墙处理

关闭防火墙对ipv6的支持（目前用这货的人还比较少）

chkconfig ip6tables off
关闭selinux

#setenforce  0
#sed -i 's/=enforcing/=disabled/g' /etc/selinux/config
四、查看模块并启动进程

查看KVM模块
root@cq36:[/root]lsmod|grep kvm
kvm_intel              53484  26
kvm                   316506  1 kvm_intel
启动libvirt进程
services libvirtd restart
五、将网卡模式改为桥接模式

保存原网卡配置，并按下面的样式进行更改，首先复制原eth0网卡为br0，将原eth0的配置文件改为：

DEVICE="eth0"
BOOTPROTO="static"
HWADDR="30:85:A9:9F:67:74"
NM_CONTROLLED="no"
ONBOOT="yes"
TYPE="Ethernet"
UUID="34096e10-ff72-4142-b7b3-e290d200b68a"
BRIDGE="br0"
复制后的br0网卡的内容改为（一般可能还有eth1网卡，eth1内容参考上面，br1的配置这里也一并列出）：

#外网网卡（以下公网IP是我乱写的，请勿对号入座）
www@cq35:[/home/www]cat /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=119.37.194.189
PREFIX=28
GATEWAY=119.37.194.182
DNS1=8.8.8.8
IPADDR2=202.75.212.225
PREFIX2=28
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System br0"
#内网网卡
www@cq35:[/home/www]cat /etc/sysconfig/network-scripts/ifcfg-br1
DEVICE="br1"
BOOTPROTO="static"
BROADCAST="192.168.10.255"
IPADDR="192.168.10.35"
NETMASK="255.255.255.0"
NM_CONTROLLED="yes"
ONBOOT="yes"
TYPE="Bridge"
修改完成后service network restart重启。重启完成后，用下面的命令查看：

root@cq35:[/opt]brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.001ec9cf52cb       no              eth0
br1             8000.001ec9cf52cd       no              eth1
virbr0          8000.525400b9dc11       yes             virbr0-nic
其实也可以通过ifconfig 查看，此时查看到的网卡会发现变成了br0、br1、eth0、eth1、virbr0这样的网卡。此时再查看IP可能十分不方便，不过可以通过ip命令进行查看。

ip add show |grep inet




================================================================================
CentOS 7

一、安装kvm 软件

由于之前已做过较详细的 kvm 的安装与总结，这里只大致列下步骤：

[root@361way ~]# yum -y install qemu-kvm libvirt virt-install bridge-utils
[root@361way ~]# lsmod | grep kvm  # make sure modules are loaded
kvm                   441119  0
[root@361way ~]# systemctl start libvirtd
[root@361way ~]# systemctl enable libvirtd 
注：centos7上服务的管理方式换成了systemctl 。

二、配置网卡桥接

centos7上默认已不再是eth0、eth1 ，我的pc server上安装好的第一块网卡变成了enp3s0 ，修改步骤和centos 6上没有区别，如下
 

[root@361way ~]# cd /etc/sysconfig/network-scripts/
[root@361way network-scripts]# cat ifcfg-br0
TYPE=Bridge
BOOTPROTO=none
DEVICE=br0
ONBOOT=yes
IPADDR0=192.168.0.102
PREFIX0=24
GATEWAY0=192.168.0.1
[root@361way network-scripts]# cat ifcfg-enp3s0
DEVICE=enp3s0
TYPE=Ethernet
ONBOOT=yes
BRIDGE=br0
[root@361way ~]reboot
[root@361way network-scripts]# ifconfig
br0: flags=4163  mtu 1500
        inet 192.168.0.102  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::7a24:afff:fe46:ca60  prefixlen 64  scopeid 0x20
        ether 78:24:af:46:ca:60  txqueuelen 0  (Ethernet)
        RX packets 129  bytes 14676 (14.3 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 148  bytes 21994 (21.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
enp3s0: flags=4163  mtu 1500
        ether 78:24:af:46:ca:60  txqueuelen 1000  (Ethernet)
        RX packets 129  bytes 16482 (16.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 148  bytes 21994 (21.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
lo: flags=73  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10
        loop  txqueuelen 0  (Local Loopback)
        RX packets 9  bytes 728 (728.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9  bytes 728 (728.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
virbr0: flags=4099  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether a6:88:9f:14:b2:66  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1  bytes 90 (90.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
[root@361way network-scripts]# ip add show
1: lo:  mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp3s0:  mtu 1500 qdisc pfifo_fast master br0 state UP qlen 1000
    link/ether 78:24:af:46:ca:60 brd ff:ff:ff:ff:ff:ff
3: br0:  mtu 1500 qdisc noqueue state UP
    link/ether 78:24:af:46:ca:60 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.102/24 brd 192.168.0.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::7a24:afff:fe46:ca60/64 scope link
       valid_lft forever preferred_lft forever
4: virbr0:  mtu 1500 qdisc noqueue state DOWN
    link/ether a6:88:9f:14:b2:66 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
注：由于ip 命令属于iproute2软件包中的工具，由于代替旧的ifconfig命令，尽可能的习惯使用新的命令和工具包来淘汰老的软件和工具。


================================================================================
补充
cat ifcfg-enp1s0f0 
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
NAME=enp1s0f0
UUID=45bd5254-86be-4365-b73d-4c538f5acd54
DEVICE=enp1s0f0
ONBOOT=yes

MM_CONTROLLED=no
BRIDGE=br0

cat ifcfg-br0 
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.1.231
PREFIX=24
GATEWAY=192.168.1.1
DNS1=192.168.1.213
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
NAME="System br0"

systemctl restart NetworkManager
systemctl restart network

yum install -y wget nginx htop
cd /data
wget http://mirrors.aliyun.com/centos/7.1.1503/isos/x86_64CentOS-7-x86_64-Minimal-1503-01.iso
mkdir /mnt/cdrom /data/centos/cdrom /data/centos/root
mount /data/CentOS-7-x86_64-Minimal-1503-01.iso /mnt/cdrom
rsync -av /mnt/cdrom/ /data/centos/cdrom/

cd /data/centos/root
vim .treeinfo
[general]
family = CentOS
timestamp = 1444904916
variant =
totaldiscs = 1
version = 7.1
discnum = 1
packagedir =
arch = x86_64

[images-x86_64]
kernel = isolinux/vmlinuz
initrd = isolinux/initrd.img

[images-xen]
initrd = images/pxeboot/initrd.img

[stage2]
mainimage = images/install.img


install

virt-install \
--name centos7.1_001 \
--ram 512 \
--disk path=/dev/centos00/centos7.1_001,size=30 \
--vcpus 2 \
--os-type linux \
--os-variant rhel6 \
--network bridge=br0 \
--graphics none \
--console pty,target_type=serial \
--location 'http://192.168.1.231/cdrom/' \
--extra-args 'console=ttyS0,115200n8 serial'

or 
virt-install \
--name centos7.1_001 \
--ram 512 \
--disk path=/data/centos/images/centos7.1_001.img,size=20 \
--vcpus 2 \
--os-type linux \
--os-variant rhel6 \
--network bridge=br0 \
--graphics vnc,password=123456,port=5920 \
--console pty,target_type=serial \
--cdrom /data/centos/CentOS-7-x86_64-Minimal-1503-01.iso



================================================================================

使用virt-install创建虚拟机并安装GuestOS

virt-install是一个命令行工具，它能够为KVM、Xen或其它支持libvrit API的hypervisor创建虚拟机并完成GuestOS安装；此外，它能够基于串行控制台、VNC或SDL支持文本或图形安装界面。安装过程可以使用本地的安装介质如CDROM，也可以通过网络方式如NFS、HTTP或FTP服务实现。对于通过网络安装的方式，virt-install可以自动加载必要的文件以启动安装过程而无须额外提供引导工具。当然，virt-install也支持PXE方式的安装过程，也能够直接使用现有的磁盘映像直接启动安装过程。 
virt-install命令有许多选项，这些选项大体可分为下面几大类，同时对每类中的常用选项也做出简单说明。 
◇    一般选项：指定虚拟机的名称、内存大小、VCPU个数及特性等； 
    -n NAME, --name=NAME：虚拟机名称，需全局惟一； 
    -r MEMORY, --ram=MEMORY：虚拟机内在大小，单位为MB； 
    --vcpus=VCPUS[,maxvcpus=MAX][,sockets=#][,cores=#][,threads=#]：VCPU个数及相关配置； 
    --cpu=CPU：CPU模式及特性，如coreduo等；可以使用qemu-kvm -cpu ?来获取支持的CPU模式； 
◇    安装方法：指定安装方法、GuestOS类型等； 
    -c CDROM, --cdrom=CDROM：光盘安装介质； 
    -l LOCATION, --location=LOCATION：安装源URL，支持FTP、HTTP及NFS等，如ftp://172.16.0.1/pub； 
    --pxe：基于PXE完成安装； 
    --livecd: 把光盘当作LiveCD； 
    --os-type=DISTRO_TYPE：操作系统类型，如linux、unix或windows等； 
    --os-variant=DISTRO_VARIANT：某类型操作系统的变体，如rhel5、fedora8等； 
    -x EXTRA, --extra-args=EXTRA：根据--location指定的方式安装GuestOS时，用于传递给内核的额外选项，例如指定kickstart文件的位置，--extra-args "ks=http://172.16.0.1/class.cfg" 
    --boot=BOOTOPTS：指定安装过程完成后的配置选项，如指定引导设备次序、使用指定的而非安装的kernel/initrd来引导系统启动等 ；例如： 
    --boot  cdrom,hd,network：指定引导次序； 
    --boot kernel=KERNEL,initrd=INITRD,kernel_args=”console=/dev/ttyS0”：指定启动系统的内核及initrd文件； 
◇    存储配置：指定存储类型、位置及属性等； 
    --disk=DISKOPTS：指定存储设备及其属性；格式为--disk /some/storage/path,opt1=val1，opt2=val2等；常用的选项有： 
    device：设备类型，如cdrom、disk或floppy等，默认为disk； 
    bus：磁盘总结类型，其值可以为ide、scsi、usb、virtio或xen； 
    perms：访问权限，如rw、ro或sh（共享的可读写），默认为rw； 
    size：新建磁盘映像的大小，单位为GB； 
    cache：缓存模型，其值有none、writethrouth（缓存读）及writeback（缓存读写）； 
    format：磁盘映像格式，如raw、qcow2、vmdk等； 
    sparse：磁盘映像使用稀疏格式，即不立即分配指定大小的空间； 
    --nodisks：不使用本地磁盘，在LiveCD模式中常用； 
◇    网络配置：指定网络接口的网络类型及接口属性如MAC地址、驱动模式等； 
    -w NETWORK, --network=NETWORK,opt1=val1,opt2=val2：将虚拟机连入宿主机的网络中，其中NETWORK可以为： 
    bridge=BRIDGE：连接至名为“BRIDEG”的桥设备； 
    network=NAME：连接至名为“NAME”的网络； 
其它常用的选项还有： 
    model：GuestOS中看到的网络设备型号，如e1000、rtl8139或virtio等； 
    mac：固定的MAC地址；省略此选项时将使用随机地址，但无论何种方式，对于KVM来说，其前三段必须为52:54:00； 
    --nonetworks：虚拟机不使用网络功能； 
◇    图形配置：定义虚拟机显示功能相关的配置，如VNC相关配置； 
    --graphics TYPE,opt1=val1,opt2=val2：指定图形显示相关的配置，此选项不会配置任何显示硬件（如显卡），而是仅指定虚拟机启动后对其进行访问的接口； 
    TYPE：指定显示类型，可以为vnc、sdl、spice或none等，默认为vnc； 
    port：TYPE为vnc或spice时其监听的端口； 
    listen：TYPE为vnc或spice时所监听的IP地址，默认为127.0.0.1，可以通过修改/etc/libvirt/qemu.conf定义新的默认值； 
    password：TYPE为vnc或spice时，为远程访问监听的服务进指定认证密码； 
    --noautoconsole：禁止自动连接至虚拟机的控制台； 
◇    设备选项：指定文本控制台、声音设备、串行接口、并行接口、显示接口等； 
    --serial=CHAROPTS：附加一个串行设备至当前虚拟机，根据设备类型的不同，可以使用不同的选项，格式为“--serial type,opt1=val1,opt2=val2,...”，例如： 
    --serial pty：创建伪终端； 
    --serial dev,path=HOSTPATH：附加主机设备至此虚拟机； 
    --video=VIDEO：指定显卡设备模型，可用取值为cirrus、vga、qxl或vmvga； 
 
◇    虚拟化平台：虚拟化模型（hvm或paravirt）、模拟的CPU平台类型、模拟的主机类型、hypervisor类型（如kvm、xen或qemu等）以及当前虚拟机的UUID等； 
    -v, --hvm：当物理机同时支持完全虚拟化和半虚拟化时，指定使用完全虚拟化； 
    -p, --paravirt：指定使用半虚拟化； 
    --virt-type：使用的hypervisor，如kvm、qemu、xen等；所有可用值可以使用’virsh capabilities’命令获取； 
◇    其它： 
    --autostart：指定虚拟机是否在物理启动后自动启动； 
    --print-xml：如果虚拟机不需要安装过程(--import、--boot)，则显示生成的XML而不是创建此虚拟机；默认情况下，此选项仍会创建磁盘映像； 
    --force：禁止命令进入交互式模式，如果有需要回答yes或no选项，则自动回答为yes； 
    --dry-run：执行创建虚拟机的整个过程，但不真正创建虚拟机、改变主机上的设备配置信息及将其创建的需求通知给libvirt； 
    -d, --debug：显示debug信息；

[root@e3 cdrom]#  virt-install \
> --name centos6.6 \ #指定虚拟机名字
> --ram 512 \  #分配虚拟机的内存大小
> --disk path=/data/kvm/images/centos6.6.img,size=20 \ #虚拟机硬盘安装路径
> --vcpus 2 \  #CPU个数
> --os-type linux \ #操作系统类型
> --os-variant rhel6 \ #虚拟机操作系统的变种，当前CENTOS是redhat的所以。
> --network bridge=br0 \ #网络配置
> --graphics none \  #不使用图形界面
> --console pty,target_type=serial \ #配置接口
> --location 'ftp://192.168.0.244/cdrom/' \  #指定安装源
>  --extra-args 'console=ttyS0,115200n8 serial'  #额外传的参数




