#! /bin/bash

RABBITMQ_CONFIG_FILE=/usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_node1 RABBITMQ_NODE_PORT=5671 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15671}]" RABBITMQ_NODENAME=node1 /usr/local/rabbitmq_server-3.2.4/sbin/rabbitmq-server -detached
#sleep 2
#RABBITMQ_CONFIG_FILE=/usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_node2 RABBITMQ_NODE_PORT=5672 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15672}]" RABBITMQ_NODENAME=node2 /usr/local/rabbitmq_server-3.2.4/sbin/rabbitmq-server -detached
sleep 2
RABBITMQ_CONFIG_FILE=/usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_node3 RABBITMQ_NODE_PORT=5673 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15673}]" RABBITMQ_NODENAME=node3 /usr/local/rabbitmq_server-3.2.4/sbin/rabbitmq-server -detached

#rabbitmqctl -n node1@xen_vm_websocket_61.youjia.cn stop_app
#rabbitmqctl -n node1@xen_vm_websocket_61.youjia.cn change_cluster_node_type ram
#rabbitmqctl -n node1@xen_vm_websocket_61.youjia.cn start_app
#rabbitmqctl -n node1@xen_vm_websocket_61.youjia.cn cluster_status

#rabbitmqctl -n node1@xen_vm_websocket_61.youjia.cn set_policy ha-uplus "^uplus" '{"ha-mode":"all"}'




