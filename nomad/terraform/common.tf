resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.rg}"
  location = "${var.location}"

  tags {
    app = "nomad-cluster"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["172.18.4.0/24"]
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    app = "nomad-cluster"
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
    app = "nomad-cluster"
  }
}
