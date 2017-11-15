# Build the Kubernetes cluster

## 1. Login to the azure cli

```
 $ az login
```
Jot down the returned json 

## 2. Changing cluster node location

It is possible to change the physical location of the nodes created within Azure.

This is possible by changing the `region` variable within `/terraform/variables.tf`

## 3. Create SSH keypair

Before creating our infrastructure we need to create an SSH keypair.

This key will be used by both Terraform and the Kismatic Toolkit. To create this execute:

```
$ make ssh-keypair
```

## 4. Create a Service Principal

```
az account set --subscription="${SUBSCRIPTION_ID}"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```
(NOTE: ${SUBSCRIPTION_ID} will be replaced by your subscription_id)

This will return an `appId` and `password`. Make sure to save these as we will need them when setting up the cloud provider integration.

## 5. Create Infrastructure

To create our infrastructure execute the following commands:

```
$ make cluster
```

## 6. Provisioning the Kubernetes cluster using Kismatic

To provision the cluster follow the steps [here](2-provision-cluster.md)