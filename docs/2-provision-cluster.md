# Provisioning the Kubernetes cluster

## SSH into the bastion node

The output from Terraform should look something like below:

```
Outputs:

bastion_ip = 104.208.239.99
etcd_0_ip = 10.0.1.5
etcd_1_ip = 10.0.1.3
etcd_2_ip = 10.0.1.7
master_0_ip = 10.0.1.6
master_1_ip = 10.0.1.9
worker_0_ip = 10.0.1.4
worker_1_ip = 10.0.1.8
ingress_0_ip = 10.0.1.4
loadbalacer_ip = 104.208.236.238
```

Execute the following command to obtain access to the bastion node.

```
$ ssh -i ssh/cluster.pem ketadmin@<bastion_ip>
```

## Kismatic-cluster.yaml changes

If you `less kismatic-cluster.yaml` and scroll to the bottom you should see that Terraform has interpolated the IP addresses for the nodes.

Use your favorite editor to enter the following information in `kismatic-cluster.yaml`:

* Admin Password: Admin password will be `password` retrieved from Service Principal

## Update the cloud provider config file

Kubernetes can integrate with Azure to create Load Balancers and Persitent Volumes on demand. To enable this capabilities, set the required information in the `azure-cloud-provider.conf` file.

The following fields must be updated with your Azure account information:

* tenantId: Your Azure tenant ID 
* subscriptionId: Your Azure subscription ID
* aadClientId: The `appId` of the Service Principal created above
* aadClientSecret: The `password` of the Service Principal created above.

## Provision the cluster using Kismatic

Once you have updated the `kismatic-cluster.yaml` file execute the following command:

```
$ make provision-cluster
```

## Validate cluster provisioning

To validate all is well execute `kubectl get nodes`

You should be shown:

```
NAME       STATUS                     ROLES     AGE       VERSION
master-0   Ready,SchedulingDisabled   master    6m        v1.8.0
master-1   Ready,SchedulingDisabled   master    6m        v1.8.0
worker-0   Ready                      <none>    6m        v1.8.0
worker-1   Ready                      <none>    6m        v1.8.0
```