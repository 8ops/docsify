# 系统结构



## 一、KVM

### 1.1 安装

```bash
# CentOS Linux release 7.5.1804 (Core
egrep 'vmx|svm' /proc/cpuinfo

yum install qemu-kvm qemu-img virt-manager libvirt libvirt-python virt-install virt-viewer

lsmod | grep -i kvm

brctl show

# virsh net-list

systemctl start libvirtd
systemctl enable libvirtd
systemctl is-enabled libvirtd

cd /etc/sysconfig/network-scripts/
# vim ifcfg-em2 & ifcfg-br0
cat > ifcfg-br0 <<EOF
TYPE=Bridge
BOOTPROTO=static
NAME=br0
DEVICE=br0
ONBOOT=yes
IPADDR=10.1.2.109
PREFIX=24
EOF

cat > ifcfg-em2 <<EOF
TYPE=Ethernet
BOOTPROTO=none
NAME=em2
DEVICE=em2
ONBOOT=yes
BRIDGE=br0
EOF

# systemctl restart NetworkManager
systemctl restart network

# 释放多余的桥接
ip l set dev virbr0-nic down
brctl delif virbr0 virbr0-nic
brctl delbr virbr0

ip l set dev virbr0 down
ip l del virbr0-nic

# METHOD VNC
virt-install --name UAT-BIGDATA-000 \
    --virt-type kvm \
    --ram=8192 \
    --vcpus=2 \
    --cdrom=/data/backup/CentOS-7-x86_64-DVD-2009.iso \
    --disk path=/data/lib/kvm/UAT-BIGDATA-001/UAT-BIGDATA-000-SDA.raw \
    --network bridge=br0 \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole

virt-install --name UAT-BIGDATA-000 \
    --virt-type kvm  \
    --ram 4096 \
    --vcpus 2 \
    --boot hd \
    --disk path=/data/lib/kvm/UAT-BIGDATA-001/UAT-BIGDATA-000-SDA.qcow2 \
    --mac=52:54:0A:01:02:32 \
    --network bridge=br1 \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole
 
# METHOD Console
mkdir -p /data/lib/kvm/UAT-BIGDATA-000
qemu-img create -f qcow2 /data/lib/kvm/UAT-BIGDATA-000-SDA.img 50G

virt-install --name UAT-BIGDATA-000 \
    --ram=8192 \
    --vcpus=2 \
    --location=/data/backup/CentOS-7-x86_64-DVD-2009.iso \
    --disk path=/data/lib/kvm/UAT-BIGDATA-000-SDA.img \
    --network bridge=br0,mac=52:54:0A:01:02:32 \
    --graphics=none \
    --console=pty,target_type=serial \
    --extra-args="console=tty0 console=ttyS0"

# MAC 地址生成策略
echo 10.1.2.50 | \
    awk -F'.' '{
        printf("52:54");
        for(i=1;i<NF+1;i++){
            if($i<=10){printf(":0%X",$i)}
            else{printf(":%X",$i)}}
    printf("\n")}'
    
# 常用命令
virsh list --all        查看所有虚拟机状态
virsh start vm_name     开机 
virsh shutdown vm_name  关机
virsh destroy vm_name   强制关闭电源 
virsh undefine vm_name  移除虚拟机
virsh suspend vm_name   暂停虚拟机
virsh resume vm_name    恢复虚拟机
virsh autostart vm_name 设置随开机启动 # 生成成软链 /etc/libvirt/qemu/autostart/vm_server.xml 
virsh autostart --disable vm_name 取消随开机启动
```



### 1.2 克隆

```bash
# METHOD AUTO（需要关机）
# -o 旧虚拟机
# -n 新虚拟机
virt-clone --auto-clone -o old-vm-server -n new-vm-server
# virt-clone --auto-clone -o UAT-BIGDATA-000 -n UAT-BIGDATA-001

# METHOD MANUAL
# 备份磁盘文件
cp old-vm-server.qcow2 new-vm-server.qcow2 
# 导出配置文件
virsh dumpxml old-vm-server > new-vm-server.xml
# 编辑配置文件：修改名称、移除UUID、修改磁盘文件名、删除MAC地址
vim new-vm-server.xml
# 导入配置文件
virsh define new-vm-server.xml 
# 启动虚拟机
virsh start new-vm-server
```



### 1.3 扩容磁盘

磁盘类型有 `qcow2` 和 `raw`，默认是`raw`

```bash
# 创建磁盘
qemu-img create -f qcow2 /data/lib/kvm/UAT-BIGDATA-000-SDB.img 100G

# 挂载磁盘（需要实例在运行中）
virsh attach-disk UAT-BIGDATA-000 \
    /data/lib/kvm/UAT-BIGDATA-000-SDB.img sdd \
    --cache none \
    --targetbus scsi \
    --subdriver qcow2 \
    --live \
    --config 
    
mkfs.xfs /dev/sda && blkid /dev/sdb

echo 'UUID=ad1798f1-52ec-498d-a793-acd82bea5d51 /data xfs     defaults        0 0' >> /etc/fstab

mkdir -p /data && mount -a


```

### 1.4 NAT上网

```bash
# 双网卡桥接内网上网
# 开启转发
sysctl -w net.ipv4.ip_forward=1

# 打开NAT（其中 eth0 为上网网卡）
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# 设置路由（内网网卡 eth1: 10.1.2.109 为内网网段路由网关）
# 在内网网段server上替换默认路由
ip r del default via 10.1.2.1
ip r add default via 10.1.2.109
```



## 二、BOND后桥接

```bash
# cat  ifcfg-bond0 
TYPE=Ethernet
BOOTPROTO=none
IPV6INIT=no
DEVICE=bond0
NAME=bond0
DEVICE=bond0
ONBOOT=yes
BRIDGE=virbr0

# cat ifcfg-em1
DEVICE=em1
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
ONBOOT=yes

# cat ifcfg-em2
DEVICE=em2
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
ONBOOT=yes

# cat ifcfg-virbr0 
DEVICE=virbr0
BOOTPROTO=static
ONBOOT=yes
TYPE=Bridge
IPADDR=10.10.54.11
NETMASK=255.255.255.0
GATEWAY=10.10.54.1
DEFROUTE=yes
PV4_FAILURE_FATAL=yes
IPV6INIT=no
DELAY=0
USERCTL=no

# cat /etc/modprobe.d/bonding.conf 
alias bond0 bonding
options bond0 miimon=100 mode=0

# modeprobe bonding (设置随开机启动)
ifenslave bond0 em1 em

```















