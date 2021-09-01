Operating System : CentOS 6.4
yum install -y gcc gcc-c++ wget curl unzip cmake make git 

cd /usr/local/src
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
vim /etc/yum.repos.d/epel.repo
modify
https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch to
to
http://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch

sed -i 's/https:/http:/g' /etc/yum.repos.d/epel.repo

yum install -y atlas-devel python-devel leveldb-devel snappy-devel opencv-devel boost-devel 

cd /usr/local/src
#wget https://github.com/google/protobuf/releases/download/2.6.1/protobuf-2.6.1.tar.gz
tar -vzxf protobuf-2.6.1.tar.gz
cd protobuf-2.6.1
./configure
make && make install

cd /usr/local/src
#wget https://google­glog.googlecode.com/files/glog-0.3.3.tar.gz
tar -vzxf glog-0.3.3.tar.gz
cd glog-0.3.3
./configure
make && make install

cd /usr/local/src
#wget -O gflags-master.zip https://github.com/schuhschuh/gflags/archive/master.zip
unzip gflags-master.zip
cd gflags-master
mkdir -p build && cd build
export CXXFLAGS="-fPIC" && cmake .. && make VERBOSE=1
make && make install

cd /usr/local/src
#git clone git://gitorious.org/mdb/mdb.git
cd mdb/libraries/liblmdb/
mkdir -p /usr/local/man/
make && make install

yum install -y libjpeg-turbo libpng-devel libXp libXpm libXt libXmu

yum install -y pciutils
lspci | grep VGA

yum install -y kernel.x86_64  kernel-devel.x86_64 kernel-headers.x86_64

ls /boot
/boot/config-2.6.32-504.1.3.el6.x86_64

==> Nvidia GTX 730
title CentOS (2.6.32-504.1.3.el6.x86_64)
	root (hd0,0)
	kernel /vmlinuz-2.6.32-504.1.3.el6.x86_64 ro root=UUID=2b34ab46-b524-4f2c-8f56-f79f704df788 rd_NO_LUKS  KEYBOARDTYPE=pc KEYTABLE=us LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 rd_NO_LVM crashkernel=auto rhgb quiet rd_NO_DM rhgb quiet nouveau.modeset=0 rd.driver.blacklist=nouveau video=vesa:off vga=normal
	initrd /initramfs-2.6.32-504.1.3.el6.x86_64.img

==> Nvidia Telsa K20 显卡
title CentOS (2.6.32-504.1.3.el6.x86_64)
	root (hd0,0)
	kernel /vmlinuz-2.6.32-504.1.3.el6.x86_64 ro root=UUID=be2979bf-fb6b-4a88-985e-2dc91e6a6163 rd_NO_LUKS  KEYBOARDTYPE=pc KEYTABLE=us LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 rd_NO_LVM crashkernel=auto rhgb quiet rd_NO_DM rhgb quiet rdblacklist=nouveau nouveau.modeset=0



cd /usr/local/src
#wget http://wx.act.youja.cn/store/NVIDIA-Linux-x86_64-340.58.run
./NVIDIA-Linux-x86_64-340.58.run
nvidia-smi 
lsmod

cd /usr/local/src
#wget http://wx.act.youja.cn/store/cuda_6.5.14_linux_64.run
./cuda_6.5.14_linux_64.run
wget http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run
wget http://developer.download.nvidia.com/compute/cuda/repos/rhel6/x86_64/cuda-repo-rhel6-6.5-14.x86_64.rpm
rpm -ivh cuda-repo-rhel6-6.5-14.x86_64.rpm
yum install -y cuda

ln -s xxx.so /usr/lib{,64}


cat > /etc/profile.d/jdk-env.sh << EOF
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:$PATH
EOF

cat > /etc/profile.d/cuda-env.sh <<EOF
export CUDA_HOME=/usr/local/cuda
export PATH=\$CUDA_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH
export G3C_GPU=1
EOF

184.72.235.74 for authentication information.

wget http://g3c-products.s3.amazonaws.com/uplus/uplus_java.tar.gz
tar ­zxvf uplus_java.tar.gz
cd uplus_java
chmod +x *

The java programs using the libraries should have the jars, lib, logs, results, download

== demo ==
javac -classpath "./jars/*" run_classifier.java
java -cp .:./jars/javabuilder.jar:./jars/IAJava.jar run_classifier /tmp/demp.jpg

results={"decision":"objectionable","porn_confidence":"0.91948","sensitivity":"low","filename":"/root/images/uplus/uplus/partial-porn/40d7a0e5fbc6a695a01ed1e4ab34384a.jpg","status":"success",”blur”:0}

IAJava classifier = new IAJava();
classifier.IADeepSetup();
Object[] result = null;
result = classifier.DetectImage(1,”/path/to/image/1.jpg”);
System.out.println(result[0].toString());

Output :
{"decision":"non­objectionable","blur":0,"status":"success","filename":"/path/to/image/1.jpg"}
The results file for the above analysis can be read by:

cat <pwd>/results/a66ce03ffee2b1f367287f7657b4ca81.txt
{"decision":"non­objectionable","filename":"/root/images/uplus/uplus/ncrowd/9af93fec22f1f743cc0338e7e9223562.jpg","status":"success",”blur”:1}


================================================================================
Add vedio

vim /etc/yum.repos.d/dag.repo
[dag]
name=Dag RPM Repository for Red Hat Enterprise Linux
baseurl=http://apt.sw.be/redhat/el$releasever/en/$basearch/dag
gpgcheck=1
enabled=1

yum install -y ffmpeg ffmpeg-devel

or 

rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
yum install -y ffmpeg

demo:

javac -classpath "./jars/*" run_classifier.java
java -cp .:./jars/ run_classifier

or 

java -cp .:./jars/javabuilder.jar:./jars/VAJava.jar run_classifier



vim /etc/yum.repos.d/atrpms.repo

[atrpms]
name=Fedora Core $releasever - $basearch - ATrpms
baseurl=http://dl.atrpms.net/el$releasever-$basearch/atrpms/stable
gpgkey=http://ATrpms.net/RPM-GPG-KEY.atrpms
enabled=1
gpgcheck=1














