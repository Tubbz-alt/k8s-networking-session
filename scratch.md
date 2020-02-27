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

