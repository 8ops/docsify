

在10.16
mysql -u'root' -p -D'uplusmain' -e'set names utf8;show create table photos\G;'
mysql -u'root' -p -D'uplusmain' -e'set names utf8;select id,user_id,photouri from photos where status>=0;' > photo-0-20141030.txt
mysql -u'root' -p -D'uplusmain' -e'set names utf8;select id,user_id,photouri from photos where status<0;' > photo-x-20141030.txt

在50.101
scp -P 50022 jesse@10.10.10.16:/dev/shm/photo* /dev/shm/


cd /usr/local/src
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm

vim /etc/yum.repos.d/epel.repo
https: ==> http:

yum install -y atlas-devel
yum install -y the python-devel
yum install -y leveldb-devel snappy-devel opencv-devel boost-devel hdf5-devel gcc gcc-c++

cd /usr/local/src
wget https://github.com/google/protobuf/release/download/2.6.1/protobuf-2.6.1.tar.gz
wget -O protobuf-2.6.1.tar.gz "https://s3.amazonaws.com/github-cloud/releases/23357588/0a2433bc-5a29-11e4-8e74-fbea8721fcc7.gz?response-content-disposition=attachment%3B%20filename%3Dprotobuf-2.6.1.tar.gz&response-content-type=application/octet-stream&AWSAccessKeyId=AKIAISTNZFOVBIJMK3TQ&Expires=1414680954&Signature=Kz%2FpwtjZySU7XWlIGZ9b5%2F7kbfI%3D"
wget -O protobuf-2.6.1.tar.gz https://github.com/google/protobuf/archive/2.6.1.tar.gz
scp -P 50022 jesse@211.155.90.27:/dev/shm/protobuf-2.6.1.tar.gz ./

tar -xzvf protobuf-2.6.1.tar.gz
cd protobuf-2.6.1
./configure
make && make install

cd /usr/local/src
wget https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz
scp -P 50022 jesse@211.155.90.27:/dev/shm/glog-0.3.3.tar.gz ./

tar -xzvf glog-0.3.3.tar.gz
cd glog-0.3.3
./configure
make && make install

cd /usr/local/src
yum install git -y
git clone git://gitorious.org/mdb/mdb.git
cd mdb/libraries/liblmdb/
mkdir /usr/local/man
make && make install

cd /usr/local/src
yum install -y libjpeg-turbo libpng-devel libXp libXpm libXt libXmu

wget http://g3c-products.s3.amazonaws.com/uplus/uplus_executable.tar.gz
scp -P 50022 jesse@211.155.90.27:/dev/shm/uplus_executable.tar.gz ./

tar -xzvf uplus_executable.tar.gz
cd uplus_executable
chmod +x *



================================================================================

htmlfile=result-01.html
echo "<table>" > $htmlfile
index=0
grep '"decision":"objectionable"' results/* | sed 's/^.*\.txt://' | head -n 300 | while read content
do 
index=$((index+1))
echo "<tr>"
echo "<td>$index</td>"
echo "<td><img src=$(echo $content |grep -oP "http://.*\.jpg") width=300/></td>"
echo "<td>$content</td>"
echo "</tr>"
done >> $htmlfile
echo "</table>" >> $htmlfile
curl --upload-file $htmlfile http://fs.uplus.youja.cn/put/$htmlfile

http://fs.uplus.youja.cn/get/result-01.html





















