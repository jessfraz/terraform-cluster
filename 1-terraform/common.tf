resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.rg}"
  location = "${var.location}"

  tags {
    app = "mesos-cluster"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["172.18.4.0/24"]
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    app = "mesos-cluster"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${azurerm_resource_group.rg.name}-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "172.18.4.0/24"
}

resource "azurerm_public_ip" "public_ip" {
  name                         = "${azurerm_resource_group.rg.name}-ip"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Dynamic"

  tags {
    app = "mesos-cluster"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${azurerm_resource_group.rg.name}-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig0"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.4"
    primary                       = true
  }

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.5"
  }

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig2"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.6"
  }

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig3"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.7"
  }

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig4"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.8"
  }

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig5"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.18.4.9"
  }

  tags {
    app = "mesos-cluster"
  }
}
