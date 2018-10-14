resource "azurerm_virtual_network" "vnet" {
  count = "${length(var.location)}"

  name                = "vnet-${count.index}"
  resource_group_name = "${element(azurerm_resource_group.rg.*.name, count.index)}"
  address_space       = ["${element(var.vnet_address_space, count.index)}"]
  location            = "${element(azurerm_resource_group.rg.*.location, count.index)}"

  tags {
    app = "nomad-cluster"
  }
}

resource "azurerm_subnet" "subnet" {
  count = "${length(var.location)}"

  name                 = "subnet-${count.index}"
  resource_group_name  = "${element(azurerm_resource_group.rg.*.name, count.index)}"
  virtual_network_name = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
  address_prefix       = "${cidrsubnet("${element(azurerm_virtual_network.vnet.*.address_space[count.index], count.index)}", 13, 0)}"
}

# Enable global peering between the virtual networks.
resource "azurerm_virtual_network_peering" "peering" {
  count = "${length(var.location)}"

  name                         = "peering-to-${element(azurerm_virtual_network.vnet.*.name, 1 - count.index)}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, count.index)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 1 - count.index)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}
