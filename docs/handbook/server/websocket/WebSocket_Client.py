#! /usr/bin/env python
# author: jesse
# date: 2014-03-26

import sys, websocket

def demo():
    ws = None
    try:
        websocket.setdefaulttimeout(10)
        print '[Demo] Create websocket connectin'
        ws = websocket.create_connection('ws://echo.websocket.org/?encoding=text')
        print '[Demo] Sending...'
        ws.send('Send Message')
        print '[Demo] Receving...'
        result = ws.recv()
        print '[Demo] Receved data: %s' % result['ecode']
    except websocket.WebSocketException, e:
        print 'WebSocket Exception: %s' % str(e)
    except Exception, e:
        print 'Other Exception: %s' % str(e)
    finally:
        if ws:
            ws.close()
        print '[Demo] Closed websocket connection'

def show():
    url = 'ws://uplus.dpocket.cn:8112/uplusIM/mywebsocket.do?hallid=1&token=670632-20002&user_type=3&client_ver=3.4.0-g&from=client'
    sendMsg = '{"hallid":"1","uid":"20002","req":"login","seq":"1005","sid":"0","commandId":242,"pkgState":1,"seqID":1005,"socketType":3}'
    print 'Create websocket connectin'
    ws = websocket.create_connection(url)
    print 'Sending...[login]'
    ws.send(sendMsg)
    print 'Receiving...'
    result =  ws.recv()
    print 'Received %s' % result


    #sendMsg = '{"count":"20","lastmsgid":"0","top":"0","req":"history","seq":"1021","sid":"139774","commandId":243,"pkgState":1,"seqID":1021,"socketType":3}'
    #print 'Sending...[history]'
    #ws.send(sendMsg)
    #print 'Receiving...'
    #result =  ws.recv()
    #print 'Received %s' % result

    #sendMsg = '{"command":245,"req":"active","seq":"1033","sid":"139774","commandId":0,"pkgState":1,"seqID":1033,"socketType":3}'
    #print 'Sending...[active]'
    #ws.send(sendMsg)
    #print 'Receiving...'
    #result =  ws.recv()
    #print 'Received %s' % result
    #result =  ws.recv()
    #print "Received '%s'" % result

    #sendMsg = '{"command":244,"req":"hung","seq":"1061","sid":"139723","commandId":0,"pkgState":1,"seqID":1061,"socketType":3}'
    #print 'Sending...[hung]'
    #ws.send(sendMsg)
    #print 'Receiving...'
    #result =  ws.recv()
    #print 'Received %s' % result

if __name__ == '__main__':
    #demo()

    show()
