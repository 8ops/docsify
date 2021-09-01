#!/usr/bin/env python
# encoding=utf8
 
# 需要给python安装redis插件，安装方法：#easy_install redis
import redis  # @UnresolvedImport
import sys
import getopt
 
def usage():
	print """
Usage:
 
check_redis_mem [-h|--help][-H|--hostname][-P|--port][-M|-maxmemory][-w|--warning][-c|--critical]
 
Options:
	--help|-h)
		print check_redis_mem help.
	--host|-H)
		Sets connect host.
	--port|-P)
		Sets connect port.
	--maxmemory|-M)
		Sets max memory.
	--warning|-w)
		Sets a warning level for redis mem userd. Default is: on
	--critical|-c)
		Sets a critical level for redis mem userd. Default is: on
Example:
	./check_redis_mem -H 127.0.0.1 -P 6379 -w 80 -c 90 or ./check_redis_mem -H 127.0.0.1 -P 6379
	This should output: mem is ok and used 10.50%"""
	sys.exit(3)
 
try:
	options, args = getopt.getopt(sys.argv[1:], "hH:P:M:w:c:", ["help", "host=", "port=", "maxmemory=", "warning=", "critical="])
except getopt.GetoptError as e:
	usage()
 
host = '127.0.0.1'
port = 6379
maxmem = 17179869184  # 默认16G内存使用大小
warning = 70
critical = 80
 
for name, value in options:
	if name in ("-h", "--help"):
		usage()
	if name in ("-H", "--host"):
		host = value
	if name in ("-P", "--port"):
		port = int(value)
	if name in ("-M", "--maxmemory"):
		maxmem = int(value)
	if name in ("-w", "--warning"):
		warning = value
	if name in ("-c", "--critical"):
		critical = value
 
if host == '' or port == 0:
	usage()
 
try:
	r = redis.Redis(host=host, port=port)
	if r.ping() == True:
  		tmpmaxmem = r.config_get(pattern='maxmemory').get('maxmemory')
  		if int(tmpmaxmem) > 0 :
  			maxmem = tmpmaxmem
		usedmem = r.info().get('used_memory')
		temp = float(usedmem) / float(maxmem)
		tmp = temp * 100
 
		if tmp >= warning and tmp < critical:
			print "mem is used %.2f%%" % (tmp)
			sys.exit(1)
		elif tmp >= critical:
			print "mem is used %.2f%%" % (tmp)
			sys.exit(2)
		else:
			print "It's ok and mem is used %.2f%%" % (tmp)
			sys.exit(0)
	else:
		print "can't connect."
		sys.exit(2)
except Exception as e:
	print e.message
	sys.exit(3)
	# usage()
