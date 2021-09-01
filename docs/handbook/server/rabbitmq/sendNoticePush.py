#!/usr/bin/env python
#coding=utf-8


import redis
import MySQLdb
import json
import random
import time
import httplib
from urllib import urlencode
from Queue import Queue
import threading
from pika import BlockingConnection,ConnectionParameters,credentials 
queue = Queue()
uidpidDict=dict()
uidpidDictNum = 0


###############配置选项########Start###############################

#模式选择 USE_HTTP_POST = true 通过http False 使用 RabbitMQ
USE_HTTP_POST = False

#mysql从库配置
READ_MYSQL_HOST = '10.10.10.16'
#READ_MYSQL_HOST = '192.168.1.210'
READ_MYSQL_UNAME = 'moplus'
READ_MYSQL_PASSWD = 'Wd36sRpt182jENTTGxVf'

#mysql主库配置
WRITER_MYSQL_HOST = '10.10.10.123'
WRITER_MYSQL_UNAME = 'moplus'
WRITER_MYSQL_PASSWD = 'Wd36sRpt182jENTTGxVf'

#mysql通用配置
MYSQL_DB_NAME = 'uplusmain'
MYSQL_DB_CHARSET = 'UTF8'

#离线消息服务器
REDIS_HOST = '10.10.10.120'
REDIS_DB_NUM = 5

#RabbitMQ 服务器
MQ_HOST = '10.10.10.66'
MQ_PORT = 5672
MQ_AUTH=credentials.PlainCredentials('guest','guest')
MQ_EXCANGE = 'uplus.push.iphone'
MQ_TYPE = 'fanout'

#消息队列服务器 http方式
HTTP_POST_HOST = '192.168.1.22'
HTTP_POST_PORT = '8080'
HTTP_POST_TIMEOUT = 5

#线程数 RabbitMQ 模式 推荐线程数 30
THREADS_NUM = 30

###############配置选项########end###############################


#####################用户设置区### start ###############################################
NOTICE_MESSAGE = '''【4月联欢会-秀出真本色】周五举行，亲们赶紧参加本周秀主活动争夺进入联欢会的20个名额哦！'''

STR_SQL = '''select u1.user_id  from user_status u1
               where  u1.last_login_time > 
               '2013-01-01 00:00:00' '''
               
#####################用户设置区### end #################################################
 
class AutoMySQLConn():
    '''
    使用方法
    AutoMySQLConn.read(SQL)   自动选择从库
    AutoMySQLConn.write(SQL)  自动选择主库
    '''
    '''
    mysql_read = dict(host='10.10.10.16', 
                     user='moplus', passwd='Wd36sRpt182jENTTGxVf', 
                     db='uplusmain', charset='UTF8')
                     
    mysql_write = dict(host='10.10.10.123', 
                     user='moplus', passwd='Wd36sRpt182jENTTGxVf', 
                     db='uplusmain', charset='UTF8')
    '''
    global READ_MYSQL_HOST,READ_MYSQL_UNAME,READ_MYSQL_PASSWD,WRITER_MYSQL_HOST,WRITER_MYSQL_UNAME,WRITER_MYSQL_PASSWD
    global MYSQL_DB_NAME,MYSQL_DB_CHARSET
    mysql_read = dict(host=READ_MYSQL_HOST, 
                     user=READ_MYSQL_UNAME, passwd=READ_MYSQL_PASSWD, 
                     db=MYSQL_DB_NAME, charset=MYSQL_DB_CHARSET)
                     
    mysql_write = dict(host= WRITER_MYSQL_HOST, 
                     user=WRITER_MYSQL_UNAME, passwd=WRITER_MYSQL_PASSWD, 
                     db= MYSQL_DB_NAME, charset=MYSQL_DB_CHARSET)              

    def __rulemysql(self,readOnly):
        if readOnly: conf = self.mysql_read
        else: conf = self.mysql_write
        
        handle = MySQLdb.connect(host=conf['host'], user=conf['user'],
                    passwd = conf['passwd'], db = conf['db'],
                    charset=conf['charset']
                    )
        return handle
    
    @staticmethod
    def read(SQL):
        tempconn = AutoMySQLConn()
        handle = tempconn.__rulemysql(True)        
        #cursor = handle.cursor(MySQLdb.cursors.DictCursor)
        cursor = handle.cursor()
        cursor.execute(SQL)
        
        result = []
        
        for row in cursor.fetchall():
            result.append(row)
        
        handle.close()
        return result
    
    @staticmethod
    def write(SQL):
        tempconn = AutoMySQLConn()
        handle = tempconn.__rulemysql(False)
        cursor = handle.cursor()
        
        cursor.execute(SQL)
        status = cursor.commit()
        
        handle.close()
        return status
       

class SenderInfo:
    '''
    发送者信息整理
    使用方法
    a = SenderInfo()
    a.setId(userid)  //int  or  list[]   
    a.sender()
    '''
   
   
   
    Entrys = []    
    SQL = '''SELECT 
            a.id,
            b.name,
            b.nick_name,
            a.gender,
            b.birthday,
            b.avatarid,
            c.album_id,
            d.location
        FROM
            user a
                LEFT JOIN
            user_info b ON a.id = b.user_id
                LEFT JOIN
            photos c ON b.user_id = c.user_id
                LEFT JOIN
            user_geo d ON b.user_id = d.user_id
        WHERE
            {0} '''
    
    
    
      
    def setId(self, uid):
        if type(uid) == type([]): return self.__setIdList(uid)
        
        whereCause = " b.user_id = %s" % uid
        self.SQL = self.SQL.format(whereCause)
        self.__getData()
        
    def __setIdList(self, uidList):
        #print uidList
        whereCause = " b.user_id in (%s)" % ",".join([str(i) for i in uidList])
        #print whereCause
        self.SQL = self.SQL.format(whereCause)
        self.__getData()
        
    def __getData(self):
        for row in AutoMySQLConn.read(self.SQL):            
            sender = {  "id": row[0],"name": row[1], 
                        "nickname": row[2],"gender": row[3],
                        "age": self.__getAge(row[4]),
                        "photoid":  row[5] * 10,
                        "bphotoid": row[5] * 10 + 1 ,
                        "mphotoid":row[5] * 10 + 2 ,
                        "sphotoid": row[5] * 10 + 3,
                        "albumid": row[6],
                        "location": row[7],
                        "distance": random.randint(9, 900)/10, "block": "0",
                        "relation": "0",
                        }        
             
            self.Entrys.append(sender)
            
               
    def __getAge(self, brith):
        if brith is None: return 0
        thisYear = int(time.strftime('%Y'))
        birthYear = int(brith.strftime('%Y'))
        
        return thisYear - birthYear
        
    
#     def random(self):
#         return random.choice(self.Entrys)
        
    def sender(self):
        sender = self.Entrys.pop()
        self.Entrys.append(sender)
        return sender

class RedisMessage:
    '''
    离线消息to Redis
    dataSource = redis.Redis('redis02', db=5)   指定redis库地址
    messageHandle = RedisMessage(dataSource)    
    messageHandle.Sender = self.sender          设置发送者
    messageHandle.setMessage(message            设置消息内容
    
    messageHandle.adduserList(userlist)        设置接受者
    messageHandle.Send()                       执行发送
    '''
    
    RedisConn = None
    Message = None
    
    Sender =  None
    ReciverList = []
    
    __SenderInfo = None
    
    def __init__(self, redisConn):
        try:
            self.RedisConn = redisConn.pipeline()
        except:
            raise IOError
            
    def __del__(self):
        self.__send()
        del self.RedisConn
    
    def setSender(self,sender):
        self.Sender = sender
    def __getSender(self):
        if self.__SenderInfo is None:                   
            self.__SenderInfo = SenderInfo()            
            self.__SenderInfo.setId(self.Sender)
                        
        return self.__SenderInfo.sender()
    
    def setMessage(self, message):
        self.Message = message
        
    def adduserList(self, userList):
        self.ReciverList = userList
    
    def Send(self):
        #for count, reciverId in enumerate(self.ReciverList):
        for reciverId in  self.ReciverList:
            key = self.__getKey(reciverId)
            entry = self.__getEntrys(reciverId)   
            self.RedisConn.rpush(key, entry)
            #if count & 0xFF == 0:
            self.__send()
    
    def __send(self):
        self.RedisConn.execute()
               
    def __getKey(self, reciverId):
        return str(reciverId) + "_notice"
        
    def __getEntrys(self, reciverId):
        message  = self.Message
        #message['reciverId'] = reciverId
        
        sendtime = time.strftime('%Y%m%d%H%M%S')
        notice_json_template = {
            "noticeid": "0","type": "15",
            "content": message,"objectid": "",
            "resourceid": "","sendtime": sendtime,
            "sender": self.__getSender(),
            "receiverid": reciverId, "receiver": "you"
            }
        
        return  json.dumps(notice_json_template, 
                     encoding="utf-8")


class sendNotice():
    '''
     # 发送离线通知
     #sender 发送者ID 10000号为发送系统消息
     使用方法
    doSendNotice = sendNotice()
    doSendNotice.main()   
    '''
   
    sender = [10000]
    def getUser(self):
        '''
        查出所有  2013-01-01后登陆过用户，将设备类型设为3 android
        '''
        str_sql = STR_SQL
        uiddict = dict()
        

        
        for row in AutoMySQLConn.read(str_sql):
            #print row
            uiddict[row[0]]=3
            

       
        return uiddict
    
    def findIphoneUser(self,uiddict):        
        '''
        从user_info查出所有iphone用户，然后检索uiddict，若找到则将设备uiddict中value 设为2
        这样uiddict中的 就是  uid：client-type 的内容 ，就针对每个用户可以区分client-type决定是发离线消息还是push
        '''
        #str_sql = " select user_id,client_type from user_info where user_id in (%s)" % ",".join([str(i) for i in uiddict.keys()])
        str_sql = " select user_id,push_id from user_info where client_type ='2' "

        global uidpidDict
        for row in AutoMySQLConn.read(str_sql):
            '''
            效率比较  
            row[0] in uiddict            1.5s  
            row[0] in uiddict.keys()     very long time 
            uiddict.has_key( row[0] )    1.46s 
            '''
            
            # push_id 有None 、 ‘’ 无法发push 需要排除掉
            if uiddict.has_key( row[0] ) and None != row[1] and len( row[1] ) > 1 :
                uiddict[ row[0] ] = 2
                uidpidDict[ row[0] ] = row[1]
    
    def __send(self):
        users = self.getUser()
        message = NOTICE_MESSAGE

        self.findIphoneUser(users)       

        dictNum = len(users)
        
        print "dictNum:",dictNum
     
        androidUidList = []
        while dictNum:
            dictNum = dictNum - 1
            user = users.popitem()
            if 3 == user[1]:
                androidUidList.append(user[0])
                
        #self.__do_send(androidUidList, message)             
        self.__do_push( message)
 

   
    main = __send
    
    def __do_push(self, message):
        global uidpidDict
        global queue
        queue = Queue( len (uidpidDict) )
        for i in uidpidDict.keys():
            queue.put(i) 
            
        #####################################################################
        #   uidpidDictNum不空 表示有发送失败的 发送失败的重启线程重做
        #####################################################################
        

        global uidpidDictNum
        uidpidDictNum = len(uidpidDict)
        print '-==-    Begin Need Send=', uidpidDictNum
        while uidpidDictNum:
            threads = []
            ###线程数
            global THREADS_NUM 
            if uidpidDictNum < THREADS_NUM:
                THREADS_NUM = uidpidDictNum
                
            for i  in range( THREADS_NUM ):
                sendboot=sendBoot(message)            
                threads.append( sendboot )
                
            for i in threads:
                i.start()

            for i in threads:
                i.join()
                
            uidpidDictNum = len(uidpidDict)
            
            global USE_HTTP_POST
            if uidpidDictNum :
                #RabbitMQ 可能内存报警中....休息一会..准备下一轮..
                print "Try Again....."
                time.sleep(3)
            else:
                #全部完成...结束
                print '-==-    end Need send ', uidpidDictNum
                break

                 
    
        
    def __do_send(self,userlist, message):
        global REDIS_HOST,REDIS_DB_NUM
        dataSource = redis.Redis( REDIS_HOST, db=REDIS_DB_NUM )
        messageHandle = RedisMessage(dataSource)
        messageHandle.Sender = self.sender
        messageHandle.setMessage(message)
        
        messageHandle.adduserList(userlist)
        messageHandle.Send()


class sendBoot(threading.Thread):
    
    def __init__(self,message):
        super(sendBoot, self).__init__()  #注意：一定要显式的调用父类的初始化函数 threading.Thread.__init__() 否则报“ fix RuntimeError: thread.__init__() not called”
        self.message= message
        if not USE_HTTP_POST:                
            global MQ_EXCANGE,MQ_HOST,MQ_PORT,MQ_TYPE,MQ_AUTH
            self.connection =None
            while not self.connection : 
                try:                       
                    self.connection = BlockingConnection(ConnectionParameters(host= MQ_HOST ,port = MQ_PORT,credentials = MQ_AUTH))
                    self.channel = self.connection.channel()
                    self.channel.exchange_declare(exchange=MQ_EXCANGE, type= MQ_TYPE)
                except:
                    pass   
                
    def run(self):
        global queue
        global USE_HTTP_POST
        while True:
            uid = ''
            try:
                uid = queue.get(True,1)
            except :
                if not USE_HTTP_POST:
                    try: 
                        self.connection.close() 
                    except:
                        pass
                break 
            if uid :
                global uidpidDict
                if USE_HTTP_POST:
                    #http链接方式
                    self.__httppost(uid,uidpidDict[uid], self.message)
                else :
                    #直接使用RabbitMQ api
                    self.__connrabbitmp(uid,uidpidDict[uid], self.message)
            else:
                if not USE_HTTP_POST: 
                    self.connection.close() 
                break
            #time.sleep(1)
     
    def __connrabbitmp(self,uid,pushid,message ):
        global uidpidDict
        global queue
        megStr = "{'uid':'%d','pushId':'%s','message':'%s','bage':'3'}" % (uid,pushid,message ) 
        global MQ_EXCANGE
        try:
            self.channel.basic_publish(exchange= MQ_EXCANGE , routing_key='', body=megStr)  
        except :
            ####发送失败的重新进进入队列  准备再次发送            
            #queue.put(uid)
            #print 'push error try Again.',len(uidpidDict)
            return
         
        
        del uidpidDict[uid]    
            


            
    def __httppost(self,uid,pushid,message):
        httpClient = None    
        try:
             
            tofomartStr = "{'uid':'%d','pushid':'%s','message':'%s','bage':'3'}" % (uid,pushid,message )
             
            params = urlencode({'msg': tofomartStr})
            headers = {"Content-type": "application/x-www-form-urlencoded"
                            , "Accept": "text/plain"}
            
            url = "/upluspushios/producer/send/"
            global HTTP_POST_HOST , HTTP_POST_PORT, HTTP_POST_TIMEOUT
            httpClient = httplib.HTTPConnection( HTTP_POST_HOST , HTTP_POST_PORT, timeout= HTTP_POST_TIMEOUT )
            httpClient.request("POST", url, params, headers)
            
            response = httpClient.getresponse()
             
            status =  response.status
            reason = response.reason
            read = response.read()
            
            print status,'|',reason,'|',read
            # 从字典中清除成功的ID
            if status == 200 :
                global uidpidDict
                del uidpidDict[uid]             
        except Exception, e:
            print e
        finally:            
            if httpClient:
                httpClient.close()
                
if __name__ == '__main__':
    doSendNotice = sendNotice()
    doSendNotice.main()
    print "Finish"