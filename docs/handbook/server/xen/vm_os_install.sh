#!/bin/bash
#auto deploy of xen's vm

#install_source="http://mirrors.163.com/centos/6.4/os/x86_64/"
#install_source="http://centos.ustc.edu.cn/centos/6.4/os/x86_64/"
#install_source="http://mirrors.tuna.tsinghua.edu.cn/centos/6.5/os/x86_64/"
install_source="http://ks.yw.youja.cn/iso/cdrom/6.4/"
ks_source="http://ks.yw.youja.cn/iso/kickstart/ks.cfg"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DNS_SERVER="192.168.1.213"

gen_dev_hard() {
    dev=$1
    vm_name=$2
    partition_quota=$3
    vg_name=`echo $dev | awk -F'/' '{print $NF}'`	
    lvcreate -L $partition_quota -n $vm_name $vg_name > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "$dev/$vm_name"
        return 0
    else 
        echo "created $dev/$vm_name failed"
        return 100
        break
    fi
}

#main
echo "********************************************************************************"
echo "init install xen vm"
sed "1d" vm_server_data > vms_data
 
while read name vcpu vmem dev quota ip os
do
    echo $name | grep -P "^#" && continue
    echo "********************************************************************************"
    
    vg_name=`echo $dev | awk -F'/' '{print $NF}'`
    vgs | sed 1d | awk '{print $1}'
    if [ $? -ne 0 ]; then 
        echo "not find $dev(Volume Group)"
        continue
    fi
    
    if [ -b $dev/$name ];then
        echo "dev_name:$dev/$name is already exists"
        continue
    else
        gen_dev_hard $dev $name $quota
        echo "$dev/$name create OK"
    fi
    
    mac=`echo $ip | awk -F'.' 'BEGIN{printf("00:16:")}END{for(i=1;i<=NF;i++){if($i>16)printf("%X",$i);else printf("0%X",$i);if(i!=NF)printf(":")};}'`
    echo $mac
    
    xm list | sed 1,2d | cut -d' ' -f1 | grep -P "^$name$"
    if [ $? -eq 0 ]; then 
        echo "$name is already"
        continue
    fi
    
    /usr/bin/virt-install --name=$name --vcpus=$vcpu --ram=$vmem --mac=$mac --file=$dev/$name --location=$install_source  --extra-args="ks=${ks_source} ip=$ip netmask=$NETMASK gateway=$GATEWAY dns=${DNS_SERVER}" --paravirt --noautoconsole --nographics --debug

    echo "********************************************************************************"
done< vms_data

