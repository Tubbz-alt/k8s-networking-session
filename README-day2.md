# Introduction to k8s networking - The Hard way - Day 2

## [Day - 1 Recap.](README-day1.md)

## k8s networking using overlay solution

## Overlay network introduction

An overlay network is a computer network that is layered on top of another network. - [Wikipedia](https://en.wikipedia.org/wiki/Overlay_network). 

Like the **Internet** could be an example of overlay network on top of a layer of connected nodes.

**Virtual private cloud** could be another example  giving a layer of abstracted network topology through overlay network irrespective of actual network topology of the connected devices in the datacenter. 

An example of a service that operates on an overlay is **Voice-Over-IP (VoIP)**. VoIP uses the infrastructure of the Internet as the underlay, while the overlay is the virtual network of phone numbers used to address each phone

## What are the advantages and disadvantages of overlay network?

### Advantages

- Resilience
- Multicast

### Disadvantages

- Slow in spreading the data.
- Long latency.
- Duplicate packets at certain points.


## Different overlay netowrking solution

- [VXLAN](https://en.wikipedia.org/wiki/Virtual_Extensible_LAN)
- [Flannel](https://github.com/coreos/flannel)
- [Calico](https://docs.projectcalico.org/)


## Kubernetes and overlay network
Remember the k8s networking constraints -
- Container-to-container communication using localhost.
- Communication between Pod without NAT
- Communication between Nodes running pods without NAT (Exception when traffic comes inside Pods)
- Communication between Container without NAT
- No IP masking - The IP that the container sees is the same as how other container see it.

Irrespective of the the cloud provider's underlaying networking topology a kubernetes cluster has to provide an uniform networking solution guided by its design constraints. That leads to overlay solution.

## Demo of overlay network in the vagrant box

Refer Figure 6

- Step 1 - `make setup-mnol`
- Step 2 - `vagrant ssh follower` and `vagrant ssh leader` from the vagrant context.
- Step 3 - run `sudo /vagrant/cleanup.sh` in the follower and leader.
- Step 4 - run `sudo /vagrant/setup.sh` in the follower and leader.
- Step 5 - run `sudo ip netns exec cont1 ping 192.168.0.2` from leader and `sudo ip netns exec cont1 ping 192.168.1.2` from the follower.
- Step 6 - Capture packet in **enp0s8** interface using `sudo tcpdump -i enp0s8 src 10.0.0.11` and in the **tun0** interface using `sudo tcpdump -i tun0 src 192.168.1.2`.
- Step 7 - Observe the packet type in enp0s8 and  tun0 interfcaes.

## EKS networking solution



- Discuss about the possible problems of using previous kind of overlay network in EKS cluster like VPC flow log implementation for firewall rule complications.
- Possible solutions using [ENI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) and secondary IPs. Please refer to Figure 7

## Credits

- [Kubernetes is Hard by Rory Chatterton](https://www.contino.io/insights/kubernetes-is-hard-why-eks-makes-it-easier-for-network-and-security-architects)
- [Understanding Overlay Networks In Cloud Deployments](https://community.arm.com/developer/tools-software/tools/b/tools-software-ides-blog/posts/understanding-and-deploying-overlay-networks)