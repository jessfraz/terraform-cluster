resource "azurerm_network_interface" "master-nic3" {
  count = "${var.master_count}"

  name                = "${azurerm_resource_group.rg.3.name}-master-nic${count.index}"
  location            = "${azurerm_resource_group.rg.3.location}"
  resource_group_name = "${azurerm_resource_group.rg.3.name}"

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.3.name}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.3.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.3.0.${count.index+5}"
  }

  tags {
    app  = "nomad-cluster"
    type = "master"
  }
}

######################
# Master VM
######################
resource "azurerm_virtual_machine" "master3" {
  count = "${var.master_count}"

  name                  = "${azurerm_resource_group.rg.3.name}-master${count.index}"
  location              = "${azurerm_resource_group.rg.3.location}"
  resource_group_name   = "${azurerm_resource_group.rg.3.name}"
  vm_size               = "${var.master_vmsize}"
  network_interface_ids = ["${element(azurerm_network_interface.master-nic3.*.id, count.index)}"]

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.master-nic3.*.ip_configuration.0.private_ip_addresses, count.index)}"
    user         = "${var.username}"
    agent        = true
  }

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${azurerm_resource_group.rg.3.name}-master-osdisk${count.index}"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${azurerm_resource_group.rg.3.name}-master${count.index}"
    admin_username = "${var.username}"
    custom_data    = "${file(var.cloud_config_master)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${file(var.public_key_path)}"
    }
  }

  tags {
    app  = "nomad-cluster"
    type = "master"
  }
}
