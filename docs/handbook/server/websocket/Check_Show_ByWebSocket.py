#! /usr/bin/env python
#  -*- coding: utf-8 -*-
# author: jesse
# date: 2014-03-26

"""
APM Test

comment:
    check show login function.

checkCode: 
    9999, default code
    9998, websocket connect exception
    9997, receive data error
    0~ N, code is ok
"""

import sys, websocket, httplib2, datetime

def show():
    checkMsg = ''
    checkCode = '9999'
    checkSource = 'SOURCE'
    checkNetType= 'NETTYPE'
    checkTime = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    ws = None
    try:
        websocket.setdefaulttimeout(10)
        url = 'ws://uplus.dpocket.cn:8112/uplusIM/mywebsocket.do?hallid=1&token=670632-20002&user_type=3&client_ver=3.4.0-g&from=client'
        sendMsg = '{"hallid":"1","uid":"20002","req":"login","seq":"1005","sid":"0","commandId":242,"pkgState":1,"seqID":1005,"socketType":3}'
        print 'Create websocket connectin'
        ws = websocket.create_connection(url)
        print 'Sending...'
        ws.send(sendMsg)
        print 'Receiving...'
        data =  dict(eval(ws.recv()))
        checkCode =  data['ecode']
        print 'Received data : '
    except websocket.WebSocketException, e:
        checkCode = '9998'
        checkMsg = 'WebSocket Exception: %s' % str(e)
    except Exception, e:
        checkCode = '9997'
        checkMsg = 'Other Exception: %s' % str(e)
    finally:
        if ws:
            ws.close()
    try:
        con = httplib2.Http()
        callUrl = 'http://apm.yw.dpocket.cn/ws/%s/%s/%s/%s?m=%s' % (checkCode,checkTime,checkSource,checkNetType,checkMsg)
        print 'Call data: %s' % callUrl
        res, body = con.request(callUrl)
    except Exception, e:
        pass

if __name__ == '__main__':
    show()
