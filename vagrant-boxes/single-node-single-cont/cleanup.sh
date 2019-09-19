#!/bin/bash
echo "Cleaning up namespace and bridge"
ip netns delete cont1
ip netns delete cont2
ip link set dev br0 down
brctl delbr br0