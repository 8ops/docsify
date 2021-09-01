#! /usr/bin/env python

import socket,sys

try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error, msg:
    print 'Failed to create socket. Error code: ' + str(msg[0]) + ' , Error message : ' + msg[1]
    sys.exit();
print 'Socket Created'

host = 'echo.websocket.org'
port = 80

try:
    remote_ip = socket.gethostbyname( host )

except socket.gaierror:
    print 'Hostname could not be resolved. Exiting'
    sys.exit()
print 'IP address of ' + host + ' is ' + remote_ip

#Connect to remote server
s.connect((remote_ip , port))

print 'Socket Connected to ' + host + ' on ip ' + remote_ip

message = "GET / HTTP/1.1\r\n\r\n"

try :
    s.sendall(message)
    data = s.recv(1024)
    print data
except socket.error:
    print 'Send failed'
    sys.exit()

print 'Message send successfully'
