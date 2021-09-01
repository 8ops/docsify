
>>>docs<<<
http://docs.docker.com/installation/centos/
https://github.com/zhangpeihao/LearningDocker/blob/master/manuscript/01-DownloadAndInstall.md
https://yeasy.gitbooks.io/docker_practice/content/install/centos.html
http://www.zouyesheng.com/docker.html



>>>centos 6 repo update<<<
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo-old
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 http://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-6
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
wget http://mirrors.aliyun.com/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo-old
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
yum repolist
yum makecache

>>>centos 6 repo update<<<
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo-old
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 http://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-7
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
wget -O /tmp/epel-release-7-5.noarch.rpm http://mirrors.aliyun.com/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
rpm -ivh /tmp/epel-release-7-5.noarch.rpm
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo-old
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum repolist
yum makecache

================================================================================

for ubuntu 
curl -sSL https://get.docker.com/ | sh
================================================================================

cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum update
yum -y install docker-engine
systemctl start docker



docker images 显示镜像列表
docker ps 显示容器列表
docker run IMAGE_ID 指定镜像, 运行一个容器
docker start/stop/pause/unpause/kill/restart CONTAINER_ID 操作容器状态
docker tag IMAGE_ID [REGISTRYHOST/][USERNAME/]NAME[:TAG] 给指定镜像命名
docker pull/push NAME:TAG 下载, 推送镜像到 
Docker registry server , NAME 部分包括了服务地址
docker rm/rmi CONTAINER_ID/IMAGE_ID 删除容器, 镜像
docker inspect CONTAINER_ID/IMAGE_ID 查看细节信息
docker top CONTAINER_ID 查看指定的运行容器的进程情况
docker info 查看系统配置信息
docker save/load 保存, 恢复镜像信息
docker commit CONTAINER_ID 从容器创建镜像
docker export > xxx.tar 保存一个容器
docker import - < xxx.tar 恢复一个容器
docker cp CONTAINER_ID:PATH HOSTPATH 从镜像复制文件到实体机
docker diff CONTAINER_ID 查看容器相对于镜像的文件变化
docker logs CONTAINER_ID 查看容器日志
docker build 从 Dockerfile 构建镜像
docker history IMAGE_ID 查看镜像的构建历史


================================================================================

docker images
docker ps
docker ps -a
docker rm 容器id
docker rmi 镜像id
docker top
docker ps -a | awk 'NR>1{print "docker rm "$1}' | sh

docker logs --tail 0 -f  容器id


docker run -d -p 18080:8080 -v /data/docker/tomcat/webapps:/usr/local/tomcat/webapps/ 9b498f715108

e.g.
docker run -d -p 18080:8080 -v /data/docker/tomcat/webapps:/usr/local/tomcat/webapps/ -v /data/docker/tomcat/tomcat-users.xml:/usr/local/tomcat/conf/tomcat-users.xml:ro -v /data/docker/tomcat/settings.xml:/usr/local/tomcat/conf/settings.xml:ro -v /data/docker/tomcat/logs:/usr/local/tomcat/logs:rw 9b498f715108 

docker run -d -p 80:80 -p 443:443 -v /data/docker/nginx/conf:/etc/nginx:ro -v /data/docker/nginx/logs:/var/log/nginx:rw 5c82215b03d1


================================================================================

mkdir testdiyimages
cd testdiyimages
touch Dockerfile
FROM ubuntu:14.04
MAINTAINER Jesse <xtso520ok@gmail.com>
RUN apt-get -q update
RUN apt-get -qy install wget curl binutils
RUN mkdir -p /test/jesse
ADD /tmp/test.txt /test/jesse/test.txt
EXPOSE 80
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]

docker build -t="xtso520ok/youja.cn:testdiyimages" .

docker run -t -i xtso520ok/youja.cn:testdiyimages /bin/bash
docker commit -m "Add wget " -a "Jesse" 0b2616b0e5a8 xtso520ok/youja.cn:testdiyimages
docker push xtso520ok/youja.cn:testdiyimages

wget -O /data/docker/openvz/ubuntu-14.04-x86_64-minimal.tar.gz http://download.openvz.org/template/precreated/ubuntu-14.04-x86_64-minimal.tar.gz
cat /data/docker/openvz/ubuntu-14.04-x86_64-minimal.tar.gz | docker import - xtso520ok/ubuntu:14.04
docker push xtso520ok/ubuntu:14.04

docker save -o /data/docker/openvz/ubuntu-14.04.tar xtso520ok/ubuntu:14.04
docker load --input /data/docker/openvz/ubuntu-14.04.tar
or docker load < /data/docker/openvz/ubuntu-14.04.tar
docker export ae91444a1537 > tomcat.tar
cat tomcat-diy.tar | docker import - xtso520ok/tomcat:diy

docker run --name web -dti -p 8080:8080 1e41e2ebc383 /bin/bash
docker run --name centos --link web:web -dti -p 22:22 c0984d80e275 /bin/bash

docker inspect -f "{{.VolumesFrom}}" 3c5c81553192
docker inspect -f "{{.Name}}" 3c5c81553192
docker inspect -f "{{.NetworkSettings.IPAddress}}" 3c5c81553192
docker inspect -f "{{.NetworkSettings}}" 3c5c81553192














