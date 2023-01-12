# NFS

## 一、安装

<u>CentOS</u>

```bash
# Server
yum install rpcbind nfs-utils 

mkdir -p /data1/lib/nfs-data

vim /etc/exports
/data1/lib/nfs-data 10.101.0.0/16(rw,sync)

systemctl start rpcbind nfs-utils nfs
systemctl enable rpcbind nfs-utils nfs
systemctl is-enabled rpcbind nfs-utils nfs
systemctl status rpcbind nfs-utils nfs

showmount -e 10.101.11.236 

systemctl restart rpcbind nfs-utils nfs
systemctl status  rpcbind nfs-utils nfs

showmount -e 10.101.9.179

# Client
yum install nfs-utils 
mkdir -p /data1/lib/nfs-data

vim /etc/fstab
10.101.9.179:/data1/lib/nfs-data /data1/lib/nfs-data nfs4 defaults 0 0

mount -a

mount -t nfs4 10.101.11.236:/data1/lib/nfs-data /data1/lib/nfs-data

rpcinfo -p 10.101.9.179
```

<u>Ubuntu</u>

```bash
# Server
apt install rpcbind libnfs-utils nfs-common

vim /etc/exports
/opt/lib/nfs 10.101.0.0/16(rw,sync)

systemctl start rpcbind nfs-utils
systemctl enable rpcbind nfs-utils
systemctl is-enabled rpcbind nfs-utils
systemctl status rpcbind nfs-utils

systemctl restart rpcbind nfs-utils nfs

# Client
apt install nfs-common
mkdir -p /opt/lib/nfs

vim /etc/fstab
10.101.11.236:/data1/lib/nfs /data1/lib/nfs nfs4 defaults 0 0

mount -a

mount -t nfs4 10.101.11.236:/data1/lib/nfs /data1/lib/nfs

rpcinfo -p 10.101.11.236
```

