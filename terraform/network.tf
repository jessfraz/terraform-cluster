resource "azurerm_virtual_network" "vnet" {
  count = "${length(var.locations)}"

  name                = "vnet-${count.index}"
  resource_group_name = "${element(azurerm_resource_group.rg.*.name, count.index)}"
  address_space       = ["${element(var.vnet_address_space, count.index)}"]
  location            = "${element(azurerm_resource_group.rg.*.location, count.index)}"

  tags {
    orchestrator = "${var.orchestrator}"
  }
}

resource "azurerm_subnet" "subnet" {
  count = "${length(var.locations)}"

  name                 = "subnet-${count.index}"
  resource_group_name  = "${element(azurerm_resource_group.rg.*.name, count.index)}"
  virtual_network_name = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
  address_prefix       = "${element(var.vnet_address_space, count.index)}"
}

# Enable global peering between the virtual networks.

/*resource "azurerm_virtual_network_peering" "peering" {
  count = "${length(var.locations) * 2}"

  name                         = "peering-to-${var.locations[floor(count.index / 2)]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 0)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 0)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 1)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}*/

resource "azurerm_virtual_network_peering" "peering0to1" {
  name                         = "peering-to-${var.locations[1]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 0)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 0)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 1)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering1to0" {
  name                         = "peering-to-${var.locations[0]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,1)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 1)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 0)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering0to2" {
  name                         = "peering-to-${var.locations[2]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 0)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 0)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 2)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering2to0" {
  name                         = "peering-to-${var.locations[0]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,2)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 2)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 0)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering1to2" {
  name                         = "peering-to-${var.locations[2]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 1)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 1)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 2)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering2to1" {
  name                         = "peering-to-${var.locations[1]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,2)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 2)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 1)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}
