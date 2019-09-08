#!/bin/bash

create_namespace()
{	
	NS_NAME=$1
	INNER_IP=`echo $3|tr -d '"'`
	OUTER_IP=`echo $2|tr -d '"'`
	GATEWAY=`echo $2| cut -c1-10`
	
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

	echo "Up network interfaces inside the new namespace: $NS_NAME"
	ip netns exec $NS_NAME ip link set veth-$NS_NAME-c up
	ip netns exec $NS_NAME ip link set lo up

	echo "Up other end of the virtual ethernet pair"
	ip link set veth-$NS_NAME up

	echo "Add default route"
	ip netns exec $NS_NAME ip route add default via $GATEWAY
}

if [ -z "${CLEAN_UP}" ]
then
	create_namespace "cont1" 10.100.1.1/24 10.100.1.2/24
	exit 0
fi

echo "Cleaning up namespace"
ip netns delete cont1

