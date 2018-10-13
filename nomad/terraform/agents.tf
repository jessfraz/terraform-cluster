resource "azurerm_network_interface" "agent-nic" {
  count = 10

  name                = "${azurerm_resource_group.rg.name}-agent-nic${count.index}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.${count.index+8}"
  }

  tags {
    app  = "nomad-cluster"
    type = "agent"
  }
}

######################
# Agent VM
######################
resource "azurerm_virtual_machine" "agent" {
  count = 10

  name                  = "${azurerm_resource_group.rg.name}-agent${count.index}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.agent_vmsize}"
  network_interface_ids = ["${element(azurerm_network_interface.agent-nic.*.id, count.index)}"]

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.agent-nic.*.0.private_ip_addresses, count.index)}"
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
    name              = "${var.prefix}-${var.hostname}-agent-osdisk${count.index}"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.hostname}-agent${count.index}"
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
