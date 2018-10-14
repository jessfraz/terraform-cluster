#
# Bastion Host
#
resource "azurerm_public_ip" "bastion_public_ip" {
  name                         = "${azurerm_resource_group.rg.0.name}-bastion-public_ip"
  resource_group_name          = "${azurerm_resource_group.rg.0.name}"
  location                     = "${azurerm_resource_group.rg.0.location}"
  public_ip_address_allocation = "Static"
  domain_name_label            = "${azurerm_resource_group.rg.0.name}-bastion"

  tags {
    app  = "nomad-cluster"
    type = "bastion"
  }
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${azurerm_resource_group.rg.0.name}-bastion-nsg"
  location            = "${azurerm_resource_group.rg.0.location}"
  resource_group_name = "${azurerm_resource_group.rg.0.name}"

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
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    app  = "nomad-cluster"
    type = "bastion"
  }
}

resource "azurerm_network_interface" "bastion_nic" {
  name                      = "${azurerm_resource_group.rg.0.name}-bastion-nic"
  location                  = "${azurerm_resource_group.rg.0.location}"
  resource_group_name       = "${azurerm_resource_group.rg.0.name}"
  network_security_group_id = "${azurerm_network_security_group.bastion_nsg.id}"

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.0.name}-bastion-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.0.id}"
    public_ip_address_id          = "${azurerm_public_ip.bastion_public_ip.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
  }

  tags {
    app  = "nomad-cluster"
    type = "bastion"
  }
}

resource "azurerm_virtual_machine" "bastion" {
  name                             = "${azurerm_resource_group.rg.0.name}-bastion"
  location                         = "${azurerm_resource_group.rg.0.location}"
  resource_group_name              = "${azurerm_resource_group.rg.0.name}"
  vm_size                          = "${var.master_vmsize}"
  network_interface_ids            = ["${azurerm_network_interface.bastion_nic.id}"]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  connection {
    type         = "ssh"
    bastion_host = "${azurerm_public_ip.bastion_public_ip.fqdn}"
    bastion_user = "${var.username}"
    agent        = true
  }

  os_profile {
    computer_name  = "${azurerm_resource_group.rg.0.name}-bastion"
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
    name              = "${azurerm_resource_group.rg.0.name}-bastion-osdisk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  provisioner "file" {
    source      = "../sleeping-beauty.hcl"
    destination = "/home/${var.username}/sleeping-beauty.hcl"
  }

  tags {
    app  = "nomad-cluster"
    type = "bastion"
  }
}
