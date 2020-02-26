### Topics to be covered
- Kubernetes networking - An introduction
- Container level networking
- Pod level networking
- Concept of overlay Network
- Node level networking


### Docker networking
Run alpine image `docker run -it alpine`
Run `nc -l -p 1234`
Start another process with `docker exec -it <containerid> /bin/sh`
Run `nc localhost 1234`



## Login to mac docker VM
screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
CTRL+A CTRL+\ followed by “y” to exit the vm and the screen session

Show the network namespace getting created `watch lsns -t net`




### Container level networking

#### Experiment - 1 

`docker run --rm -p 1234:1234 --name server  alpine -it /bin/sh -c "ip addr; nc -l -p 1234"`

`docker run --rm --name client alpine -it /bin/sh -c "ip addr; nc 172.17.0.2 1234"`

On the client side type some message and that should be echoed in the server.

#### Experiment - 2 

`docker run --rm -p 1234:1234 --name server  alpine -it /bin/sh -c "ip addr; nc -l -p 1234"`

`docker run --rm --net=container:server --name client alpine -it /bin/sh -c "ip addr; nc localhost 1234"`

On the client side type some message and that should be echoed in the server.

#### Experiment - 3

`docker run --rm --name app -p 1234:1234 -p 1235:1235 alpine -it /bin/sh -c "ip addr; nc -l -p 1234"`

`docker run --rm --name side-car --net=container:app alpine -it /bin/sh -c "ip addr; nc -l -p 1235"`

From the host machine run `nc localhost 1234` and type some message. The message should be echoed on app side.

From the host machine run `nc localhost 1235` and type some message. The message should be echoed on side-car.


### Pod level networking















Understand the hierarchy - 

	Nodes - A
		pods - A.a
			container - A.a.1
			container - A.a.2
	Nodes - B
		pods - B.a
			container - B.a.3

Kubernetes networking requirements - 
	Connecting pods across the nodes (East-West traffic)
	Need to discover services and load balancing
	Exposing services for external clients (North-south traffic)
	Segmenting network to increase pod security

Kubernetes netwiorking constraints/design goals - 
	Container-to-container communication using localhost.
	Communication between Pod without NAT
	Communication between Nodes running pods without NAT (Exception when traffic comes inside Pods)
	Communication between Container without NAT
	No IP masking - The IP that the container sees is the same as how other container see it.


Kubernetes networking - 
	Networking between containers inside pod
	Networking between pods
	External exposure of services

Understanding process - 
	Single network namespace
	Single node - two network NS
	Multiple node same L2 network
	Multiple node, overlay network



--------Observations----
kubectl get pods -o json | jq '.items[].status.podIP' ## See the IP is 172.17.0.4
kubectl get pods -o json | jq '.items[].status.hostIP' ## See the IP is 10.0.2.15
kubectl get nodes -o json | jq '.items[].status.addresses' ## See the IP is 10.0.2.15





Credit ----
https://kccna18.sched.com/speaker/kristen.f.jacobs
https://www.youtube.com/watch?v=6v_BDHIgOY8&t=694s Container Networking From Scratch - Kristen Jacobs, Oracle
https://github.com/kristenjacobs/container-networking
https://www.gabriel.urdhr.fr/2016/01/12/ip-over-udp-with-socat/
https://www.rubyguides.com/2012/07/socat-cheatsheet/
https://medium.com/@copyconstruct/socat-29453e9fc8a6
http://www.dest-unreach.org/socat/doc/socat-tun.html
Vagrant----
vagrant box list

docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Status}}" --filter status=running --filter ancestor=k8s.gcr.io/pause:3.1

docker ps -a --format "table {{.ID}}\t{{.Command}}\t{{.Names}}" --filter status=running --filter ancestor=k8s.gcr.io/pause:3.1 | grep bitcoin

sudo iptables-save | grep echoserver

sudo iptables -t nat -L  KUBE-SERVICES


### SNAT IP packets destined for echoserver
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/echoserver:" -m tcp --dport 31347 -j KUBE-MARK-MASQ
-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
-A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -m mark --mark 0x4000/0x4000 -j MASQUERADE
-A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -m mark --mark 0x4000/0x4000 -j MASQUERADE --random-fully


-A KUBE-NODEPORTS -p tcp -m comment --comment "default/echoserver:" -m tcp --dport 31347 -j KUBE-SVC-ZFAVNEBGNVMBQPKH
-A KUBE-SVC-ZFAVNEBGNVMBQPKH -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-IE5SAZQDPUKC7AA6
-A KUBE-SVC-ZFAVNEBGNVMBQPKH -j KUBE-SEP-33IL5XJZLXNDM2VG
-A KUBE-SEP-IE5SAZQDPUKC7AA6 -s 172.17.0.2/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-IE5SAZQDPUKC7AA6 -p tcp -m tcp -j DNAT --to-destination 172.17.0.2:8080
-A KUBE-SEP-33IL5XJZLXNDM2VG -s 172.17.0.8/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-33IL5XJZLXNDM2VG -p tcp -m tcp -j DNAT --to-destination 172.17.0.8:8080

-A KUBE-SERVICES -d 10.111.118.92/32 -p tcp -m comment --comment "default/echoserver: cluster IP" -m tcp --dport 8080 -j KUBE-SVC-ZFAVNEBGNVMBQPKH

