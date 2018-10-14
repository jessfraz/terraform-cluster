resource "azurerm_network_interface" "agent-nic2" {
  count = "${var.agent_count}"

  name                = "${element(azurerm_resource_group.rg.*.name, 2)}-agent-nic${count.index}"
  location            = "${element(azurerm_resource_group.rg.*.location, 2)}"
  resource_group_name = "${element(azurerm_resource_group.rg.*.name, 2)}"

  ip_configuration {
    name                          = "${element(azurerm_resource_group.rg.*.name, 2)}-ipconfig"
    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, 2)}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${cidrhost(10.2.0.0/16, count.index+5+var.master_count)}"
  }

  tags {
    app  = "nomad-cluster"
    type = "agent"
  }
}

######################
# Agent VM
######################
resource "azurerm_virtual_machine" "agent2" {
  count = "${var.agent_count}"

  name                  = "${element(azurerm_resource_group.rg.*.name, 2)}-agent${count.index}"
  location              = "${element(azurerm_resource_group.rg.*.location, 2)}"
  resource_group_name   = "${element(azurerm_resource_group.rg.*.name, 2)}"
  vm_size               = "${var.agent_vmsize}"
  network_interface_ids = ["${element(azurerm_network_interface.agent-nic2.*.id, count.index)}"]

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.agent-nic2.*.ip_configuration.0.private_ip_addresses, count.index)}"
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
    name              = "${element(azurerm_resource_group.rg.*.name, 2)}-agent-osdisk${count.index}"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${element(azurerm_resource_group.rg.*.name, 2)}-agent${count.index}"
    admin_username = "${var.username}"
    custom_data    = "${file(var.cloud_config_agent)}"
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
    type = "agent"
  }
}
