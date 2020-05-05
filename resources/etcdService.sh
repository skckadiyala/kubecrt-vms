#!/bin/bash

cat <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \
  --name ${HOST_IP} \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${HOST_IP}:2380 \
  --listen-peer-urls https://${HOST_IP}:2380 \
  --listen-client-urls https://${HOST_IP}:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://${HOST_IP}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster ${MASTER_NODE1}=https://${MASTER_NODE1}:2380,${MASTER_NODE2}=https://${MASTER_NODE2}:2380,${MASTER_NODE3}=https://${MASTER_NODE3}:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF