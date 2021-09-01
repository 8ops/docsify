#! /usr/bin/env python
# -*- coding: utf8 -*-

"""
本机 Git 提交情况

……

"""

from fabric.api import execute, local, run
from fabric.colors import cyan, red, green
from fabric.context_managers import cd, show
import fabric

DIRS = ['~/bin', '~/workspace/python-demo', '~/uplusmian-pushiphone', '~/pushiphone-demo2', '~/workspace/uplusmain-server', '~/workspace/uplusmain-dao', '~/workspace/uplusmain-dao', '~/workspace/uplusmain-model', '~/workspace/uplusmain-util', '~/workspace/youjia_admin_site']

def comm():
    dir = DIRS[index]
    dir = '/home/jesse/bin/apps'
    with cd('/home/jesse/bin/apps'):
        run('ls')
#     with cd(str(DIRS[index] + '/')):
#        local('pwd')

def view():
    print(cyan('请选择待扫描的目录编号：\n'))
    for x, val in enumerate(DIRS):
        print(cyan('%3d, %s' % (x + 1, val)))
    print('\n')

def scan():
    global index        
    index = local('read -p "请输入一个目录编号: [default. 1]" index             ; echo $index', capture=True)
    try:
        index = int(index)
        if index < 1 or index > len(DIRS):
            print(red("编号选择范围错误 [%s]，已设为默认" % index))
            index = 1
    except:
        print(red("编号选择输入错误 [%s]，已设为默认" % index))
        index = 1
    index = index - 1
    print '被选中的目录是: %s' % DIRS[index]
        
def do():
    execute(view)
    execute(scan)
    execute(comm)


