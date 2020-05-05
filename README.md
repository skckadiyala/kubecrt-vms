# Create multi-master Kubernetes cluster on Ubuntu VMs using kubeadm and golang (ssh package) 

This repo can be used to create multi master kubernetes cluster on ubuntu VMs (bare-metal). 
Note: For this lab we tested on Ubuntu 16.04 as a base image for all the machines (VMs) needed. 
      All these machines are configured on the same network and this network `SHOULD HAVE INTERNET ACCESS` .

## Pre-Requisites

* 1 or more VMs for Master nodes  
* 1 or more VMs for Worker nodes 
* 1 node for loadBalancer and client.

Tools and software required on Master Nodes:
* sudo access to the ssh user
* docker (version 17.03) 
* kubeadm
* kubelet
* kubectl
* etcd
* Disable swap
  * sudo swapoff -a
  * sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab 

Tools and software required on Worker Nodes:
* sudo access to the ssh user
* docker (version 17.03)
* kubeadm
* kubelet
* kubectl
* Disable swap
  * sudo swapoff -a
  * sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab 

Tools and software required on loadBalencer Nodes:
In this execrsice we use this node as a client node to create the certificates for kubernetes cluster.

* sudo access to the ssh user
* HaProxy
* cfssl
* cfssljson


## Deploy Kubernetes on VM's using barekube tool



* Clone this repository
* All you need is barekube tool and resources folder for creating k8s cluster on VMs

* Prepare/update the k8s Config file(k8sConfig.json) under resources folder. 

Note: This tool supports only calico || weave cni plugins 

```
{
	"sshInfo":{
		"username": "*****",
		"password": "*********"
    },
    "masterNodes":["<Provide IP Addess>", "<Provide IP Addess>", "<Provide IP Addess>" ],
    "minionNodes":["<Provide IP Addess>","<Provide IP Addess>","<Provide IP Addess>"],
    "loadBalancer":["<Provide IP Addess>"],
    "ca-config":"ca-config.json",
    "ca-csr":"ca-csr.json",
    "kubernetes-csr":"kubernetes-csr.json",
    "etcdService":"etcdService.sh",
    "configFile": "config.sh",
    "haProxyCfg": "haproxycfg.sh"
    "cniNetwork": "weave",
}

```

* Update the etcdService.sh file under resources folder

```
  * Based on the number of Master nodes update the below line. 
  * If you are creating a cluster with two master nodes remove the `,${MASTER_NODE3}=https://${MASTER_NODE3}:2380` from the file and save it. 
  * No change required if using 3 master nodes

   --initial-cluster ${MASTER_NODE1}=https://${MASTER_NODE1}:2380,${MASTER_NODE2}=https://${MASTER_NODE2}:2380,${MASTER_NODE3}=https://${MASTER_NODE3}:2380 \

```
* Update the config.sh file under resources folder

```
  * Based on the number of Master nodes update the endpoints . 
  * If using two master nodes remove the `- https://${MASTER_NODE3}:2379` from the file and save it.  
  * No change required if using 3 master nodes

etcd:
  endpoints:
  - https://${MASTER_NODE1}:2379
  - https://${MASTER_NODE2}:2379
  - https://${MASTER_NODE3}:2379

```
* Update haproxycfg.sh file under resources folder

```
  * Based on the number of Master nodes update the servers
  * If using two master nodes remove the `server k8s-master-2 ${MASTER_NODE3}:6443 check fall 3 rise 2` from the file and save it.
  * No change required if using 3 master nodes

server k8s-master-0 ${MASTER_NODE1}:6443 check fall 3 rise 2
server k8s-master-1 ${MASTER_NODE2}:6443 check fall 3 rise 2
server k8s-master-2 ${MASTER_NODE3}:6443 check fall 3 rise 2 

```

## Run the program to create the k8s cluster

``` 

Usage of ./barekube:
  -m string
        Mode for Deployment
                reset        : Reset the entire cluster with new k8s cluster
                install      : Create k8s Cluster
                prechecks    : Verify the Pre-Requisites on Nodes
                join         : Join worker nodes to cluster
                delete       : Deletes the entire cluster

e.g: barekube -m prechecks

```

# Verify k8s cluster

ssh to the primary master (first IP address provided for `masterNodes of k8sConfig.json`) and run 

```
$ kubectl get nodes

NAME       STATUS    ROLES     AGE       VERSION
master1   Ready     master    1h        v1.11.2
master2   Ready     master    1h        v1.11.2
master3   Ready     master    1h        v1.11.2
worker1   Ready     <none>    1h        v1.11.2
worker2   Ready     <none>    1h        v1.11.2
worker3   Ready     <none>    1h        v1.11.2
worker4   Ready     <none>    1h        v1.11.2
worker5   Ready     <none>    1h        v1.11.2

$ kubectl get pods --all-namespaces
NAMESPACE     NAME                               READY     STATUS    RESTARTS   AGE
kube-system   weave-net-6qckm                    2/2       Running   0          1h
kube-system   weave-net-9w7tk                    2/2       Running   0          1h
kube-system   weave-net-cvct7                    2/2       Running   0          1h
kube-system   weave-net-h9g5d                    2/2       Running   0          1h
kube-system   weave-net-kp9dm                    2/2       Running   0          1h
kube-system   weave-net-l9g4j                    2/2       Running   0          1h
kube-system   weave-net-ljsnz                    2/2       Running   0          1h
kube-system   coredns-78fcdf6894-dq2lh           1/1       Running   0          1h
kube-system   coredns-78fcdf6894-mmhlv           1/1       Running   0          1h
kube-system   kube-apiserver-master1             1/1       Running   0          1h
kube-system   kube-apiserver-master2             1/1       Running   0          1h
kube-system   kube-apiserver-master3             1/1       Running   0          1h
kube-system   kube-controller-manager-master1    1/1       Running   0          1h
kube-system   kube-controller-manager-master2    1/1       Running   0          1h
kube-system   kube-controller-manager-master3    1/1       Running   0          1h
kube-system   kube-proxy-4txb7                   1/1       Running   0          1h
kube-system   kube-proxy-7v2nx                   1/1       Running   0          1h
kube-system   kube-proxy-9mh7m                   1/1       Running   0          1h
kube-system   kube-proxy-hghpt                   1/1       Running   0          1h
kube-system   kube-proxy-nz487                   1/1       Running   0          1h
kube-system   kube-proxy-qjg9s                   1/1       Running   0          1h
kube-system   kube-proxy-wck8v                   1/1       Running   0          1h
kube-system   kube-scheduler-master1             1/1       Running   0          1h
kube-system   kube-scheduler-master2             1/1       Running   0          1h
kube-system   kube-scheduler-master3             1/1       Running   0          1h

```

After successful creation of the cluster, copy $HOME/.kube/config file from the primary master node to the client machine ($HOME/.kube/config) to perfrom kubectl operations. 



# Install and configure MetalLB 

Since Kubernetes does not offer an implementation of network load-balancers for bare-metal, MetalLB can be your load-balancer implementation.  As a reference, metalLB-config.yaml (layer 2 configuration file) is saved in resources folder.  For more detailed information, refer to https://metallb.universe.tf/.

Install MetalLB by applying the manifest
```
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
```
Configure MetalLB by creating config from a yaml file (ex: metalLB-config.yaml)
```
kubectl create -f metalLB-config.yaml
```
Delete MetalLB config
```
kubectl delete cm config -n metallb-system
```