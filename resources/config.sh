#! /bin/bash
# created for kubernetes v1.13.3
# use podNetwork_cidr default 10.30.0.0/24 for weave
# use podNetwork_cidr default 192.168.0.0/16 for calico
# api:
#   advertiseAddress: ${LB_NODE1}
cat <<EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
etcd:
  external:
    endpoints:
    - https://${MASTER_NODE1}:2379
    - https://${MASTER_NODE2}:2379
    - https://${MASTER_NODE3}:2379
    caFile: /etc/etcd/ca.pem
    certFile: /etc/etcd/kubernetes.pem
    keyFile: /etc/etcd/kubernetes-key.pem
networking:
  serviceSubnet: "10.96.0.0/12"
  podSubnet: "10.30.0.0/24"
  dnsDomain: "cluster.local"
clusterName: "k8s-cluster.axway.int"
apiServer:
  certSANs:
  - ${LB_NODE1}
  extraArgs:
    apiserver-count: "3"
controllerManager:
  extraArgs:
  address: 0.0.0.0
scheduler:
  extraArgs:
  address: 0.0.0.0
EOF