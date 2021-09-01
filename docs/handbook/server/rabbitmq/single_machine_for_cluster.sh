#! /bin/bash

# RABBITMQ_NODE_PORT=5671 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15671}]" RABBITMQ_NODENAME=r1 rabbitmq-server -detached
# RABBITMQ_NODE_PORT=5672 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15672}]" RABBITMQ_NODENAME=r2 rabbitmq-server -detached
# RABBITMQ_NODE_PORT=5673 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15673}]" RABBITMQ_NODENAME=r3 rabbitmq-server -detached

# /usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_r1.config
#[
#  {rabbit, [{vm_memory_high_watermark, 0.95}]}
#].
#
#or
#[
#  {rabbit, [
#    {cluster_nodes, {['r1@s151', 'r2@s151', 'r3@s151'], disc}},
#    {vm_memory_high_watermark, 0.95}
#  ]}
#].

#rabbitmqctl -n r2@s151 stop_app
#rabbitmqctl -n r2@s151 join_cluster --ram r1@s151
#rabbitmqctl -n r2@s151 start_app
#rabbitmqctl -n r2@s151 cluster_status

#rabbitmqctl -n r3@s151 stop_app
#rabbitmqctl -n r3@s151 join_cluster --ram r1@s151
#rabbitmqctl -n r3@s151 start_app
#rabbitmqctl -n r3@s151 cluster_status

RABBITMQ_CONFIG_FILE=/usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_r1 RABBITMQ_NODE_PORT=5671 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15671}]" RABBITMQ_NODENAME=r1 /usr/local/rabbitmq_server-3.2.4/sbin/rabbitmq-server -detached
sleep 5
RABBITMQ_CONFIG_FILE=/usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_r2 RABBITMQ_NODE_PORT=5672 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15672}]" RABBITMQ_NODENAME=r2 /usr/local/rabbitmq_server-3.2.4/sbin/rabbitmq-server -detached
sleep 5
RABBITMQ_CONFIG_FILE=/usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_r3 RABBITMQ_NODE_PORT=5673 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15673}]" RABBITMQ_NODENAME=r3 /usr/local/rabbitmq_server-3.2.4/sbin/rabbitmq-server -detached

rabbitmqctl -n r2@s151 stop_app
rabbitmqctl -n r2@s151 change_cluster_node_type ram
rabbitmqctl -n r2@s151 start_app
rabbitmqctl -n r2@s151 cluster_status

rabbitmqctl -n r3@s151 stop_app
rabbitmqctl -n r3@s151 change_cluster_node_type ram
rabbitmqctl -n r3@s151 start_app
rabbitmqctl -n r3@s151 cluster_status

rabbitmqctl -n r1 stop
rabbitmqctl -n r2 stop
rabbitmqctl -n r3 stop

rabbitmqctl -n r1@s151 set_policy ha-all "^ha\." '{"ha-mode":"all"}'
rabbitmqctl -n r1@s151 set_policy ha-queue "^queue" '{"ha-mode":"all"}'
rabbitmqctl -n r1@s151 set_policy ha-uplus "^uplus" '{"ha-mode":"all"}'

rabbitmqctl -n r1@s151 set_policy ha-uplus "^amq" '{"ha-mode":"all"}'

RABBITMQ_CONFIG_FILE=/usr/local/rabbitmq_server-3.2.4/etc/rabbitmq/rabbitmq_r4 RABBITMQ_NODE_PORT=5674 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15674}]" RABBITMQ_NODENAME=r4 /usr/local/rabbitmq_server-3.2.4/sbin/rabbitmq-server -detached

rabbitmqctl -n r4 stop



