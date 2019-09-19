#!/bin/bash
source /vagrant/env.sh
echo "Cleaning up namespace and bridge"
ip netns delete $NS_NAME_1
ip netns delete $NS_NAME_2
ip link set dev br0 down
brctl delbr br0
ip route del $TO_NETWORK_IP/24 via $TO_NODE_IP dev enp0s8
sysctl -w net.ipv4.ip_forward=0