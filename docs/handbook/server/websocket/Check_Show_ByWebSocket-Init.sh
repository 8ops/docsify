#! /bin/bash

# Downloading script file
DIR=/opt/scripts
mkdir -p ${DIR}
cd ${DIR}
FILE=${DIR}/websocket-1.0.tar.gz
PY_FILE=${DIR}/Check_Show_ByWebSocket.py
SH_FILE=${DIR}/Check_Show_ByWebSocket-Daemon.sh
[ -e ${FILE} ] || curl -o ${FILE} http://apm.yw.dpocket.cn/get/websocket-1.0.tar.gz && tar xvzf ${FILE}

# Check envirment for websocket.py 
python -c "import websocket, httplib2" || exit 1 

read -p "Input from address: " from
[ -z $from ] && echo "Not input from address." && exit 1 
read -p "Input net type: " nettype
[ -z $nettype ] && echo "Not input net type." && exit 1
sed -i '24s/SOURCE/'${from}'/' ${PY_FILE}
sed -i '25s/NETTYPE/'${nettype}'/' ${PY_FILE}

# Test run 
python ${PY_FILE}

read -p "Is start daemon?[Y/n]: " isOk
[ -z $isOk ] && echo "Not run daemon." && exit 1
if [[ "x$isOk" == "xY" ]] || [[ "x$isOk" == "xy" ]]; then
    echo "Start daemon."
    nohup ${SH_FILE} 2>&1 > /tmp/websocket.log &
fi


 
