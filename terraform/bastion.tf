# Interpolate the generate values
data "template_file" "kismatic_cluster" {
  template = "${file("${path.module}/user-data/kismatic-cluster.yaml.tpl")}"

  vars {
    etcd0_ip        = "${azurerm_network_interface.etcd.0.private_ip_address}"
    etcd1_ip        = "${azurerm_network_interface.etcd.1.private_ip_address}"
    etcd2_ip        = "${azurerm_network_interface.etcd.2.private_ip_address}"
    master0_ip      = "${azurerm_network_interface.master.0.private_ip_address}"
    master1_ip      = "${azurerm_network_interface.master.1.private_ip_address}"
    worker0_ip      = "${azurerm_network_interface.worker.0.private_ip_address}"
    worker1_ip      = "${azurerm_network_interface.worker.1.private_ip_address}"
    ingress0_ip     = "${azurerm_network_interface.worker.0.private_ip_address}"
    loadbalancer_ip = "${azurerm_public_ip.kube_api.ip_address}"
  }
}

resource "azurerm_public_ip" "bastion" {
  name                         = "bastion"
  location                     = "East US 2"
  resource_group_name          = "${azurerm_resource_group.ket.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "bastion" {
  name                      = "bastion"
  location                  = "East US 2"
  resource_group_name       = "${azurerm_resource_group.ket.name}"
  network_security_group_id = "${azurerm_network_security_group.bastion.id}"

  ip_configuration {
    name                          = "bastion"
    subnet_id                     = "${azurerm_subnet.kubenodes.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.bastion.id}"
  }
}

resource "azurerm_network_security_group" "bastion" {
  name                = "bastion"
  location            = "${azurerm_resource_group.ket.location}"
  resource_group_name = "${azurerm_resource_group.ket.name}"

  security_rule {
    name                       = "allow_ssh_in_all"
    description                = "Allow SSH access from anywhere"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_virtual_machine" "bastion" {
  name                  = "bastion"
  location              = "East US 2"
  resource_group_name   = "${azurerm_resource_group.ket.name}"
  network_interface_ids = ["${azurerm_network_interface.bastion.id}"]
  vm_size               = "${var.bastion_vm_size}"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "bastion"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    admin_username = "${var.admin_username}"
    computer_name  = "bastion"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = "${file("${var.ssh_key}")}"
    }
  }
  connection {
    type        = "ssh"
    private_key = "${file("${path.module}/../ssh/cluster.pem")}"
    user        = "${var.admin_username}"
    host        = "${azurerm_public_ip.bastion.ip_address}"
    timeout     = "2m"
  }

  # ########################################################
  # Upload all the files and directories required.
  # ########################################################

   provisioner "file" {
    source      = "${path.module}/../ssh/cluster.pem"
    destination = "/home/ketadmin/cluster.pem"
  }

  provisioner "file" {
    content = "${data.template_file.kismatic_cluster.rendered}"
    destination = "/home/ketadmin/kismatic-cluster.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/../Makefile"
    destination = "/home/ketadmin/Makefile"
  }

  provisioner "file" {
     source      = "${path.module}/user-data/kismatic-v${var.kismatic_version}-linux-amd64.tar.gz"
     destination = "/home/ketadmin/kismatic-v${var.kismatic_version}-linux-amd64.tar.gz"
  }

  provisioner "file" {
    source      = "${path.module}/user-data/bastion-script.sh"
    destination = "/home/ketadmin/bastion-script.sh"
  }

  provisioner "file" {
    source      = "${path.module}/user-data/azure-cloud-provider.conf"
    destination = "/home/ketadmin/azure-cloud-provider.conf"
  }

  # ########################################################
  # Execute the necessary commands to setup the cluster.
  # ########################################################

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ketadmin/bastion-script.sh",
      "/home/ketadmin/bastion-script.sh args",
    ]
  }

  # Extract the Kismatic tar file and setup both Kubectl and Helm
  provisioner "remote-exec" {
    inline = [
      "tar -xvzf ${var.kismatic_tar_file}",
      "sudo cp helm /usr/local/bin/helm",
      "sudo cp kubectl /usr/local/bin/kubectl",
      "echo 'source <(kubectl completion bash)' >> ~/.bashrc",
      "sudo cp kismatic /usr/local/bin/kismatic",
      "rm ${var.kismatic_tar_file}"
    ]
  }
}