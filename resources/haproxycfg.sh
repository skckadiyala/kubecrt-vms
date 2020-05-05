#! /bin/bash

cat <<EOF
	
	# Begin k8s HAConfig
	frontend kubernetes
	bind 0.0.0.0:6443
	option tcplog
	mode tcp
	default_backend kubernetes-master-nodes

	backend kubernetes-master-nodes
	mode tcp
	balance roundrobin
	option tcp-check
	server k8s-master-0 ${MASTER_NODE1}:6443 check fall 3 rise 2
	server k8s-master-1 ${MASTER_NODE2}:6443 check fall 3 rise 2
	server k8s-master-2 ${MASTER_NODE3}:6443 check fall 3 rise 2
	# End k8s HAConfig

EOF
