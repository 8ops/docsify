#! /usr/bin/env python
# -*- coding: utf8 -*-

"""
RabbitMQ 运行详情

检测机器运行状态：fab -w  -f check_pushiphone_fabfile.py server_status
获取当天推送数量：fab -w  -f check_pushiphone_fabfile.py push_num
获取当天推送成功：fab -w  -f check_pushiphone_fabfile.py push_success_num
获取当天推送失败：fab -w  -f check_pushiphone_fabfile.py push_failure_num
清零统计日志：    fab -w  -f check_pushiphone_fabfile.py clean_log
查看日志详情：    fab -w  -f check_pushiphone_fabfile.py view_log

"""

from fabric.api import run, env, roles, execute, sudo
from fabric.colors import red, green
from fabric.context_managers import cd

env.roledefs = {
                    'rabbitmq_server':['10.10.10.66', '10.10.10.81'],
                    'rabbitmq_consumer':[ '10.10.10.61', '10.10.10.81', '10.10.10.66']
                    }
env.user = ''
env.password = ''
env.port = 50022

count = 0

@roles('rabbitmq_server')
def server_status():
    with cd('/tmp'):
        print(green('[检测机器运行状态……]'))
        sudo('netstat -nutlp')

@roles('rabbitmq_consumer')
def push_success_num():
    with cd('/data/logs/push'):
        print(green('[扫描推送成功的消息……]'))
        num = run('grep -c success iphone-info.log')
        global count
        count += int(num)
        print(green('累积推送消息数： %d ' % count))

@roles('rabbitmq_consumer')
def push_failure_num():
    with cd('/data/logs/push'):
        print(green('[扫描推送失败的消息……]'))
        num = run('grep -c failure iphone-error.log')
        global count
        count += int(num)
        print(green('累积推送消息数： %d ' % count))
        
@roles('rabbitmq_consumer')
def clean_log():
    with cd('/data/logs/push'):
        print(green('[清除日志……]'))
        run('ls -lh *')
        run('wc -l *')
        run('echo -n "" > iphone-info.log')
        run('echo -n "" > iphone-error.log')
        run('rm -f iphone-info.log.*')
        run('rm -f iphone-error.log.*')

@roles('rabbitmq_consumer')
def view_log():
    with cd('/data/logs/push'):
        print(green('[查看日志……]'))
        run('ls -ilh *')
        
def push_num():
    global count
    execute(push_success_num)
    print(red('累积推送成功消息数： %d ' % count, bold=True))
    count = 0
    execute(push_failure_num)
    print(red('累积推送失败消息数： %d ' % count, bold=True))
    
            
