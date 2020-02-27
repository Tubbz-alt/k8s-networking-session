# Introduction to k8s networking - The Hard way - Day 1

## Kubernetes networking requirements
- Connecting pods across the nodes (East-West traffic)
- Need to discover services and load balancing
- Exposing services for external clients (North-south traffic)
- Segmenting network to increase pod security

## Kubernetes netwiorking constraints/design goals
- Container-to-container communication using localhost.
- Communication between Pod without NAT
- Communication between Nodes running pods without NAT (Exception when traffic comes inside Pods)
- Communication between Container without NAT
- No IP masking - The IP that the container sees is the same as how other container see it.

## Container networking primitives

When docker contrainer runs on a linux machine, along with different other namespaces (like PID, IPC, mount etc) a new network namespace is created. This namespace is a new network stack altogether separated from the host network stack. One could use virtual ethernet pair to connect the new network to the host network.

- Login to mac docker machine
`screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty`
`CTRL+A CTRL+\ followed by “y” ` to exit the vm and the screen session
- Show the network namespace getting created 
`watch lsns -t net`
- Run `docker run -it alpine`
- Observe the new namespace gets created
- Observe the docker0 bridge
- Observe virtual interface pair

### Networking between two different namespaces

- `docker run --rm -it -p 1234:1234 --name server  alpine /bin/sh -c "ip addr; nc -l -p 1234"`

- `docker run --rm -it --name client alpine /bin/sh -c "nc <ipaddress of server> 1234"`

On the client side type some message and that should be echoed in the server and observe the two different net namespace in the `watch lsns -t net`


### Concept of network namespace sharing

- `docker run --rm -it -p 1234:1234 --name server  alpine /bin/sh -c "nc -l -p 1234"`

- `docker run --rm -it --net=container:server --name client alpine /bin/sh -c "nc localhost 1234"`

On the client side type some message and that should be echoed in the server and observe the `NPROCS` column in the `watch lsns -t net`

## Kubernetes networking the big picture

We will use minikube to understand the concept of Node/Pod/Container in the context of kubernetes and try to corelate the same with the ealier section.

- Login to the minikube machine `minikube ssh`
- Demonstrate the different namespaces.
- Show the pause containers.
`docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Status}}" --filter status=running --filter ancestor=k8s.gcr.io/pause:3.1`

## Pod level networking on single nodes
- Run two pods
`kubectl run busybox-server --image=busybox -it /bin/sh` and ``kubectl run busybox-server --image=busybox -it /bin/sh``
- Capture packet at docker0
`docker run --net=host corfr/tcpdump -i docker0 dst 172.17.0.13`

## Pod level networking on two nodes(L2)
- Run make `setup-mnl2`
- Go to the `vagrant-boxes/multi-node-l2` and run `vagrant ssh follower` and `vagrant ssh master`
- Now show the communication is happening
- Capture packet on different interface to understand the path


## Credits
- [Container Networking From Scratch - Kristen Jacobs, Oracle](https://www.youtube.com/watch?v=6v_BDHIgOY8&t=694s)