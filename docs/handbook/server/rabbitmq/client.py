#! /usr/bin/env python
# -*- coding: utf-8 -*-

import pika
try:
    connection = pika.BlockingConnection(pika.ConnectionParameters(host='iphone.rabbitmq.youja.cn'))
    channel = connection.channel()
    channel.exchange_declare(exchange='uplus.push.iphone', type='fanout')
    result = channel.queue_declare(exclusive=True)
    queue_name = result.method.queue
    channel.queue_bind(exchange='uplus.push.iphone', queue=queue_name)
    
    count=0
    print '[*] Waiting for messages. To exit press CTRL+C'
    def callback(ch, method, properties, body):
        global count
        count += 1
        print '[Jesse] %d times Received %r   ' % (count, body, )
        
    channel.basic_consume(callback, queue=queue_name, no_ack=True)
    channel.start_consuming()
except :
    pass

