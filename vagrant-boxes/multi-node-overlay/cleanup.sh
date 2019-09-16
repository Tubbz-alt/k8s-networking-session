#!/bin/bash
source ./env.sh
pkill socat
echo "Cleaning up namespace and bridge"
ip netns delete $NS_NAME
ip link set dev br0 down
brctl delbr br0
sysctl -w net.ipv4.ip_forward=0