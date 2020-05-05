package main

import (
	"flag"
	"os"

	utils "git.ecd.axway.int/apigov/kubecrt-vms/utils"
	"golang.org/x/crypto/ssh"
)

var mode string

func init() {

	flag.StringVar(&mode, "m", "", "Mode for Deployment \n"+
		"\treset	: Reset the entire cluster with new k8s cluster \n"+
		"\tinstall	: Create k8s Cluster \n"+
		"\tprechecks: Verify the Pre-Requisites on Nodes \n"+
		"\tjoin	: Join worker nodes to cluster\n"+
		"\tdelete	: Deletes the entire cluster")
}
func main() {

	flag.Parse()

	kube := utils.ReadConfFile("resources/k8sConfig.json")
	sshConfig := &ssh.ClientConfig{
		User: kube.SSHInfo.Username,
		Auth: []ssh.AuthMethod{
			ssh.Password(kube.SSHInfo.Password),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	switch mode {
	case "prechecks":
		kube.VerifyNodes(sshConfig)
	case "install":
		kube.ConfigureHAProxy(sshConfig)
		kube.Createk8sCluster(sshConfig)
		utils.RemoveTempFiles()
	case "reset":
		kube.Deletek8sCluster(sshConfig)
		kube.ConfigureHAProxy(sshConfig)
		kube.Createk8sCluster(sshConfig)
		utils.RemoveTempFiles()
	case "join":
		kube.JoinWorkerstoMaster(sshConfig)
	case "delete":
		kube.Deletek8sCluster(sshConfig)
	default:
		utils.PrettyPrintWarn("Please provide valid mode for deployment")
		flag.Usage()
		os.Exit(1)
	}
}
