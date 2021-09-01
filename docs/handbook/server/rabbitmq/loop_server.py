#! /usr/bin/env python
# -*- coding: utf-8 -*-
 
from pika import BlockingConnection,ConnectionParameters
from datetime import datetime
from threading import Thread
from time import sleep

try: 
    connection = BlockingConnection(ConnectionParameters(host='127.0.0.1'))
    channel = connection.channel()
    channel.exchange_declare(exchange='uplus.push.test', type='fanout')
    m=100
    n=70000

    def send():
        message = '{"uid":"%d","pushId":"1234 - %d","message":"This is uplus.push.test push iphone message (i=%d,j=%d) - %s","bage":"4"}' % (i*n+j+1,i*n+j+1,i,j,str(dt))     
        channel.basic_publish(exchange='uplus.push.test', routing_key='', body=message)
        print '[Jesse] Send %r' % message
     
    for i in range(0, m): 
        dt = datetime.now().strftime('%Y%m%d%H%M%S')
        for j in range(0, n): 
            #Thread(target=send).start()
            send()

        #sleep(10)
    connection.close()

except Exception as e :
    pass
