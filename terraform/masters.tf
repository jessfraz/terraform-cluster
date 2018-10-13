######################
# Master VM 0
######################
resource "azurerm_virtual_machine" "master0" {
  name                  = "${azurerm_resource_group.rg.name}-master0"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.master_vmsize}"
  network_interface_ids = ["${azurerm_network_interface.nic0.id}"]

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.nic0.*.private_ip_address, count.index)}"
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
    name              = "${var.prefix}-${var.hostname}-osdisk0"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.hostname}-master0"
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

  provisioner "file" {
    source      = "../zookeeper"
    destination = "/home/${var.username}/"

    connection {
      type  = "ssh"
      user  = "${var.username}"
      agent = true
    }
  }

  tags {
    app = "mesos-cluster"
  }
}

######################
# Master VM 1
######################
resource "azurerm_virtual_machine" "master1" {
  name                  = "${azurerm_resource_group.rg.name}-master1"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.master_vmsize}"
  network_interface_ids = ["${azurerm_network_interface.nic1.id}"]

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.nic1.*.private_ip_address, count.index)}"
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
    name              = "${var.prefix}-${var.hostname}-osdisk1"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.hostname}-master1"
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

  provisioner "file" {
    source      = "../zookeeper"
    destination = "/home/${var.username}/"

    connection {
      type  = "ssh"
      user  = "${var.username}"
      agent = true
    }
  }

  tags {
    app = "mesos-cluster"
  }
}

######################
# Master VM 2
######################
resource "azurerm_virtual_machine" "master2" {
  name                  = "${azurerm_resource_group.rg.name}-master2"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.master_vmsize}"
  network_interface_ids = ["${azurerm_network_interface.nic2.id}"]

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.nic2.*.private_ip_address, count.index)}"
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
    name              = "${var.prefix}-${var.hostname}-osdisk2"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.hostname}-master2"
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

  provisioner "file" {
    source      = "../zookeeper"
    destination = "/home/${var.username}/"

    connection {
      type  = "ssh"
      user  = "${var.username}"
      agent = true
    }
  }

  tags {
    app = "mesos-cluster"
  }
}
