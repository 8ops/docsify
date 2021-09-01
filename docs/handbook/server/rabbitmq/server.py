#! /usr/bin/env python
# -*- coding: utf-8 -*-
 
import pika, datetime

try: 
    connection = pika.BlockingConnection(pika.ConnectionParameters(host='iphone.rabbitmq.youja.cn',port=5672))
    channel = connection.channel()
    channel.exchange_declare(exchange='uplus.push.iphone', type='fanout')
     
    dt = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    message = '{"uid":"123456","pushId":"80a48ff6 5efac2f9 6127afee 3c9966a3 640fc24a a34221ac 335fe36f 365a71d1","message":"This is test exchange=uplus.push.iphone push iphone message - %s","bage":"4"}' % (str(dt))     
     
    channel.basic_publish(exchange='uplus.push.iphone', routing_key='', body=message)
    print '[Jesse] Send %r' % message
     
    connection.close()
except Exception as e :
    print e.message
