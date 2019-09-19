#!/bin/bash
echo "Cleaning up namespace"
ip netns delete cont1
ip netns delete cont2
ip link set dev br0 down
brctl delbr br0