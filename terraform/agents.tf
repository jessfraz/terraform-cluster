######################
# Agent VM Scale Set
######################
resource "azurerm_virtual_machine_scale_set" "agent" {
  depends_on = ["azurerm_virtual_machine.master", "azurerm_virtual_machine.bastion"]

  count = "${length(var.locations)}"

  name                = "agent"
  location            = "${element(azurerm_resource_group.rg.*.location, count.index)}"
  resource_group_name = "${element(azurerm_resource_group.rg.*.name, count.index)}"

  upgrade_policy_mode = "Manual"

  single_placement_group = false

  sku {
    name     = "${var.agent_vmsize}"
    tier     = "Standard"
    capacity = "${var.agent_count}"
  }

  network_profile {
    name    = "networkprofile"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      subnet_id = "${element(azurerm_subnet.subnet.*.id, count.index)}"
    }
  }

  storage_profile_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_publisher}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_profile_os_disk {
    name              = ""
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 500
  }

  os_profile {
    computer_name_prefix = "${element(azurerm_resource_group.rg.*.name, count.index)}-agent"
    admin_username       = "${var.username}"
    custom_data          = "${file(var.cloud_config_agent)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${file(var.public_key_path)}"
    }
  }

  tags {
    orchestrator = "${var.orchestrator}"
    type         = "agent"
    datacenter   = "${element(azurerm_resource_group.rg.*.location, count.index)}"
  }
}
