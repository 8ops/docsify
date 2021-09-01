
cd /usr/local/src
wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.0.tgz
tar xvzf mongodb-linux-x86_64-2.6.0.tgz 
mv .. /usr/local/

# set env

mkdir -p /etc/mongo /data/logs/mongo /data/mongo/27117 /data/mongo/27217 

cat /etc/mongo/mongo-27117.conf

logpath=/data/logs/mongo/mongo-27117.log
port=27117
logappend=true
fork = true
rest = true
dbpath=/data/mongo/27117
noscripting = true
notablescan = true
master = true
source = 10.0.10.151:27117

cat /etc/mongo/mongo-27217.conf
logpath=/data/logs/mongo/mongo-27217.log
port=27217
logappend=true
fork = true
rest = true
dbpath=/data/mongo/27217
noscripting = true
notablescan = true
slave = true
source = 10.0.10.151:27117
autoresync = true



mongod -f /etc/mongo/mongo-27117.conf
mongod -f /etc/mongo/mongo-27217.conf
mongod -f /etc/mongo/mongo-27317.conf



常规使用

db.serverStatus() or db.runCommand({"serverStatus":1})

db.printReplicationInfo()
db.printSlaveReplicationInfo()

导出导入
mongodump -d uplus -o uplus.dump
mongorestore --drop --port 27117 -d uplus uplus.dump/*

mongoexport -d uplus -c userLocation | gunzip > userLocation.20140428.gz
zcat userLocation.20140428.gz | mongoimport -d uplus -c userLocation 

关掉服务
use admin
db.shutdownServer()

删除数据库
use test; 
db.dropDatabase();
mongodb删除表 
db.mytable.drop();

获取数据库uplus的索引
db.userLocation.getIndexes()
获取系统所有索引信息
db.system.indexes.find()


GEO 2d index find()
附近查询
db.userLocation.find({pos:{$near:[100,100],$maxDistance:30}})
区域内查询
db.userLocation.find({pos:{$within:{$box:[[0,0],[100,100]]}}})
返回目标距离点的距离
db.runCommand({geoNear:"userLocation",near:[50,50]})
db.runCommand({geoNear:"userLocation",near:[50,50],num:2})
对结果追加条件筛选
db.runCommand({geoNear:"userLocation",near:[50,50],num:200,query:{gender:false}})
定义变量
box=[[40,40],[60,60]] 
db.userLocation.find({"pos":{"$within":{"$box":box}}})

查看慢查询
db.setProfilingLevel(2);
db.getProfilingLevel()
db.system.profile.find().sort({$natural:-1})







