#!/bin/bash

source ./env.sh

create_namespace()
{	
	NS_NAME=$1
	INNER_IP=`echo $3|tr -d '"'`
	OUTER_IP=`echo $2|tr -d '"'`

	is_ns_exists=`ip netns list | grep -c $NS_NAME`
	if [ $is_ns_exists -eq 1 ]
	then
		ip netns delete $NS_NAME
	fi

	echo "Adding a new network namespace: $NS_NAME"
	ip netns add $NS_NAME

	echo "Getting network namespaces"
	ip netns list

	echo "Adding virtual ethernet pair veth-$NS_NAME:veth-$NS_NAME-c"
	ip link add veth-$NS_NAME type veth peer name veth-$NS_NAME-c

	echo "Move one end of veth to new network NS: $NS_NAME"
	ip link set veth-$NS_NAME-c netns $NS_NAME

	echo "Add IP to both the end of the virtual etherent pair: $2(outside), $3(namespaced)"
	ip addr add $OUTER_IP dev veth-$NS_NAME
	ip netns exec $NS_NAME ip addr add $INNER_IP dev veth-$NS_NAME-c

	echo "Up other end of the virtual ethernet pair"
	ip link set veth-$NS_NAME up
	
	echo "Add virtual ethernet pair end to bridge" 	
	ip link set dev veth-$NS_NAME master br0

	echo "Up network interfaces inside the new namespace: $NS_NAME"
	ip netns exec $NS_NAME ip link set veth-$NS_NAME-c up
	ip netns exec $NS_NAME ip link set lo up

	echo "Add default route"
	ip netns exec $NS_NAME ip route add default via $BRIDGE_IP
	

}



is_bridge_exists=`brctl show | grep -c br0`

if [ $is_bridge_exists -eq 1 ] 
then
	ip link set dev br0 down
	brctl delbr br0
fi

echo "Adding bridge br0"
ip link add name br0 type bridge
echo "Adding ip $BRIDGE_IP/$CONTAINER_CIDR to bridge br0"
ip addr add $BRIDGE_IP/$CONTAINER_CIDR dev br0
echo "-----------------------------------------------"
create_namespace "cont1" $ROOT_NS_IP/$CONTAINER_CIDR $CONTAINER_NS_IP/$CONTAINER_CIDR
echo "Setting bridge up"
ip link set dev br0 up

echo "Setting route to another node"
socat TUN:$TUN_DEVICE_IP/$CONTAINER_CIDR,iff-up UDP:$TO_NODE_IP:9000,bind=$FROM_NODE_IP:9000 &
ip route add $TO_NETWORK_IP/$CONTAINER_CIDR dev tun0
echo "Setting the MTU on the tun interface"
ip link set dev tun0 mtu 1492


echo "Disables reverse path filtering"
bash -c 'echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter'
bash -c 'echo 0 > /proc/sys/net/ipv4/conf/enp0s8/rp_filter'
bash -c 'echo 0 > /proc/sys/net/ipv4/conf/br0/rp_filter'
bash -c 'echo 0 > /proc/sys/net/ipv4/conf/tun0/rp_filter'
echo "Enabling IP forwarding"
sysctl -w net.ipv4.ip_forward=1
echo "Deleting some default route"
ip route del $NETWORK_IP/$CONTAINER_CIDR dev veth-cont1
ip route del $NETWORK_IP/$CONTAINER_CIDR dev tun0
