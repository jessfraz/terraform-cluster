#
# Bastion Host
#
resource "azurerm_public_ip" "bastion_public_ip" {
  name                         = "${azurerm_resource_group.rg.name}-bastion-public_ip"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  location                     = "${azurerm_resource_group.rg.location}"
  public_ip_address_allocation = "Static"
  domain_name_label            = "${azurerm_resource_group.rg.name}-bastion"

  tags {
    app = "mesos-cluster"
  }
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${azurerm_resource_group.rg.name}-bastion-nsg"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow_SSH_in_all"
    description                = "Allow SSH in from all locations"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTP_in_all"
    description                = "Allow HTTP in from all locations"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    app = "mesos-cluster"
  }
}

resource "azurerm_network_interface" "bastion_nic" {
  name                      = "${azurerm_resource_group.rg.name}-bastion-nic"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.bastion_nsg.id}"

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-bastion-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    public_ip_address_id          = "${azurerm_public_ip.bastion_public_ip.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.4"
  }

  tags {
    app = "mesos-cluster"
  }
}

resource "azurerm_virtual_machine" "bastion" {
  name                             = "${azurerm_resource_group.rg.name}-bastion"
  location                         = "${azurerm_resource_group.rg.location}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  vm_size                          = "${var.vmsize}"
  network_interface_ids            = ["${azurerm_network_interface.bastion_nic.id}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "${var.prefix}-${var.hostname}-bastion"
    admin_username = "${var.username}"
    custom_data    = "${file(var.cloud_config_bastion)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${file(var.public_key_path)}"
    }
  }

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-${var.hostname}-bastion-osdisk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  tags {
    app = "mesos-cluster"
  }
}
