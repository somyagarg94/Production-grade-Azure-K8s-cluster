# Kubernetes on Azure using KET

This guide will walk you through setting up a production Kubernetes cluster on 
Azure infrastructure using the [Kismatic Enterprise Toolkit (KET)](https://github.com/apprenda/kismatic).

The cluster will use WeaveNet as the CNI provider.

# Azure Architecture
* Nodes live in a single VNet.
* Nodes live in a single subnet.
* Nodes use Azure Managed Disks
* Nodes do not have a public IP address.
* Bastion host (aka. jump box) is the only virtual machine that has a public IP address.
* Etcd, master and worker nodes are in their own Availability Set.
* The kubernetes API is accessible through a load balancer that has a public IP address.
* Default network security groups are created for etcd, master and worker nodes. The master node security group allows access to the API Server port from the internet.
* The default Linux user account is `ketadmin`

# Setup
* 2 Master nodes (load-balancer behind a dedicated load balancer).
* 3 Etcd node
* 2 Worker nodes

# Requirements
* Azure account
* Azure subscription ID jotted down somewhere
* Azure CLI installed
* Terraform installed

# Create the cluster
To create a cluster, follow the steps [here](docs/1-cluster-creation.md)

# Destroy the cluster

To destroy the cluster, `exit` from the bastion node and run the command below:

```
make destroy-cluster
```
