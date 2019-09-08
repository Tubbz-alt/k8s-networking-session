#!/bin/bash

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

	echo "Listing current network namespaces"
	ip netns list

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
	ip netns exec $NS_NAME ip route add default via 192.168.1.10

}


if [ -z "${CLEAN_UP}" ]
then
	is_bridge_exists=`brctl show | grep -c br0`

	if [ $is_bridge_exists -eq 1 ] 
	then
		ip link set dev br0 down
		brctl delbr br0
	fi

	echo "Adding bridge br0"
	ip link add name br0 type bridge
	echo "Adding ip 192.168.1.10/24 to bridge br0"
	ip addr add 192.168.1.10/24 dev br0
	echo "-----------------------------------------------"
	create_namespace "cont1" 192.168.1.1/24 192.168.1.2/24
	echo "-----------------------------------------------"
	create_namespace "cont2" 192.168.1.3/24 192.168.1.4/24
	echo "-----------------------------------------------"
	echo "Setting bridge up"
	ip link set dev br0 up
	echo "Setting route to another node"
	ip route add 192.168.0.0/24 via 10.0.0.11 dev enp0s8
	echo "Enabling IP forwarding"
	sysctl -w net.ipv4.ip_forward=1
	echo "Deleting some default route"
	sudo ip route del 192.168.1.0/24 dev veth-cont1
	sudo ip route del 192.168.1.0/24 dev veth-cont2
	exit 0
else

	echo "Cleaning up namespace and bridge"
	ip netns delete cont1
	ip netns delete cont2
	ip link set dev br0 down
	brctl delbr br0
	ip route del 192.168.0.0/24 via 10.0.0.11 dev enp0s8
	sysctl -w net.ipv4.ip_forward=1
	exit 0
fi




