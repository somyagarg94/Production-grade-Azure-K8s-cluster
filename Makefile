ssh-keypair:
	mkdir ssh
	cd ssh && ssh-keygen -t rsa -f cluster.pem -N ""
	chmod 600 ssh/cluster.pem

plan-cluster:
	cd terraform && terraform init && terraform plan

cluster:
	cd terraform && terraform init && terraform apply

destroy-cluster:
	cd terraform && terraform init && terraform destroy --force
	rm -rf ansible generated runs ssh helm kismatic kubeconfig kubectl provision

# ################################################
# Commands to execute from bastion node
# ################################################

pre-validate-cluster:
	chmod 600 cluster.pem
	kismatic install validate -f kismatic-cluster.yaml

provision-cluster:
	chmod 600 cluster.pem
	kismatic install apply -f kismatic-cluster.yaml
	cp generated/kubeconfig .
	mkdir ~/.kube/
	cp kubeconfig ~/.kube/config

