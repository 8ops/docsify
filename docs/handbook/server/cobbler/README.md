
CentOS 6.4 & Cobbler 2.4
===========================

stop iptables selinux, chkconfig iptables off

rpm -ivh http://mirrors.sohu.com/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

yum -y install tftp-server httpd dhcp yum-utils cobbler cobbler-web cman  debmirror
















