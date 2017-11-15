cluster:
  name: kubernetes
  admin_password: 
  cloud_provider:
    provider: azure
    config: "/home/ketadmin/azure-cloud-provider.conf"

  networking:
    pod_cidr_block: 172.16.0.0/16
    service_cidr_block: 172.20.0.0/16

  certificates:
    expiry: 17520h
    ca_expiry: 17520h

  ssh:
    user: ketadmin
    ssh_key: /home/ketadmin/cluster.pem
    ssh_port: 22

add_ons:
  cni:
    disable: false
    provider: weave

etcd:                                    # Here you will identify all of the nodes that should play the etcd role on your cluster.
  expected_count: 3
  nodes:
  - host: etcd-0                            # The (short) hostname of a node, e.g. etcd01.
    ip: ${etcd0_ip} 
  - host: etcd-1
    ip: ${etcd1_ip}
  - host: etcd-2
    ip: ${etcd2_ip}
                         # The ip address the installer should use to manage this node, e.g. 8.8.8.8.
master:                                  # Here you will identify all of the nodes that should play the master role.
  expected_count: 2
  load_balanced_fqdn: ${loadbalancer_ip}                  # If you have set up load balancing for master nodes, enter the FQDN name here. Otherwise, use the IP address of a single master node.
  load_balanced_short_name: ${loadbalancer_ip}            # If you have set up load balancing for master nodes, enter the short name here. Otherwise, use the IP address of a single master node.
  nodes:
  - host: master-0
    ip: ${master0_ip}
  - host: master-1
    ip: ${master1_ip}
worker:                                  # Here you will identify all of the nodes that will be workers.
  expected_count: 2
  nodes:
  - host: worker-0
    ip: ${worker0_ip}
  - host: worker-1
    ip: ${worker1_ip}
ingress:
  expected_count: 1
  nodes:
  - host: worker-0
    ip: ${worker0_ip}
nfs:                                     # A set of NFS volumes for use by on-cluster persistent workloads, managed by Kismatic.
  nfs_volume: []
