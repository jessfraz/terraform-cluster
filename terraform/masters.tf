resource "azurerm_network_interface" "master-nic" {
  count = "${var.master_count * length(var.locations)}"

  name                = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.master_count))}-master-nic${count.index}"
  location            = "${element(azurerm_resource_group.rg.*.location, floor(count.index / var.master_count))}"
  resource_group_name = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.master_count))}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, floor(count.index / var.master_count))}"
    private_ip_address_allocation = "Static"

    # This expands to 10.0.0.0/16 for the first region and 10.1.0.0/16 for the second region...
    # And then the IP being accessed is the number of the master for that location:
    # 10.0.0.5
    # 10.0.0.6
    # ...
    # 10.1.0.5
    # 10.1.0.6
    # ...
    private_ip_address = "${cidrhost(format("10.%d.0.0/16", floor(count.index / var.master_count)), count.index - (floor(count.index / var.master_count) * length(var.locations)) + 5)}"
  }

  tags {
    orchestrator = "${var.orchestrator}"
    type         = "master"
  }
}

######################
# Master VM
######################
resource "azurerm_virtual_machine" "master" {
  count = "${var.master_count * length(var.locations)}"

  name                             = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.master_count))}-master${count.index}"
  location                         = "${element(azurerm_resource_group.rg.*.location, floor(count.index / var.master_count))}"
  resource_group_name              = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.master_count))}"
  vm_size                          = "${var.master_vmsize}"
  network_interface_ids            = ["${element(azurerm_network_interface.master-nic.*.id, count.index)}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    host         = "${element(azurerm_network_interface.master-nic.*.ip_configuration.0.private_ip_addresses, count.index)}"
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
    name              = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.master_count))}-master-osdisk${count.index}"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${element(azurerm_resource_group.rg.*.name, floor(count.index / var.master_count))}-master${count.index}"
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
    orchestrator = "${var.orchestrator}"
    type         = "master"
  }
}
