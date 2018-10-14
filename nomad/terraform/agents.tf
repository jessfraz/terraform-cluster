resource "azurerm_network_interface" "agent-nic" {
  count = "${var.agent_count * length(var.locations)}"

  name                = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.agent_count))}-agent-nic${count.index}"
  location            = "${element(azurerm_resource_group.rg.*.location, floor(count.index / var.agent_count))}"
  resource_group_name = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.agent_count))}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, floor(count.index / var.agent_count))}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${cidrhost(format("10.%d.0.0/16", floor(count.index / var.agent_count)), count.index + 5 + var.master_count)}"
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
  count = "${var.agent_count * length(var.locations)}"

  name                             = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.agent_count))}-agent${count.index}"
  location                         = "${element(azurerm_resource_group.rg.*.location, floor(count.index / var.agent_count))}"
  resource_group_name              = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.agent_count))}"
  vm_size                          = "${var.agent_vmsize}"
  network_interface_ids            = ["${element(azurerm_network_interface.agent-nic.*.id, count.index)}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.agent-nic.*.ip_configuration.0.private_ip_addresses, count.index)}"
    user         = "${var.username}"
    agent        = true
  }

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_publisher}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.agent_count))}-agent-osdisk${count.index}"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.agent_count))}-agent${count.index}"
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
