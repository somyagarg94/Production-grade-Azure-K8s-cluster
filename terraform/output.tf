output "bastion_ip" {
    value = "${azurerm_public_ip.bastion.ip_address}"
}

output "master_0_ip" {
    value = "${azurerm_network_interface.master.0.private_ip_address}"
}

output "master_1_ip" {
    value = "${azurerm_network_interface.master.1.private_ip_address}"
}

output "etcd_0_ip" {
    value = "${azurerm_network_interface.etcd.0.private_ip_address}"
}

output "etcd_1_ip" {
    value = "${azurerm_network_interface.etcd.1.private_ip_address}"
}

output "etcd_2_ip" {
    value = "${azurerm_network_interface.etcd.2.private_ip_address}"
}

output "worker_0_ip" {
    value = "${azurerm_network_interface.worker.0.private_ip_address}"
}

output "worker_1_ip" {
    value = "${azurerm_network_interface.worker.1.private_ip_address}"
}

output "ingress_0_ip" {
    value = "${azurerm_network_interface.worker.0.private_ip_address}"
}

output "loadbalacer_ip" {
    value = "${azurerm_public_ip.kube_api.ip_address}"
}

