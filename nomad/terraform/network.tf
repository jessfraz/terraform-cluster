resource "azurerm_virtual_network" "vnet" {
  count = "${length(var.locations)}"

  name                = "vnet-${count.index}"
  resource_group_name = "${element(azurerm_resource_group.rg.*.name, count.index)}"
  address_space       = ["${element(var.vnet_address_space, count.index)}"]
  location            = "${element(azurerm_resource_group.rg.*.location, count.index)}"

  tags {
    app = "nomad-cluster"
  }
}

resource "azurerm_subnet" "subnet" {
  count = "${length(var.locations)}"

  name                 = "subnet-${count.index}"
  resource_group_name  = "${element(azurerm_resource_group.rg.*.name, count.index)}"
  virtual_network_name = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
  address_prefix       = "${cidrsubnet("${element(azurerm_virtual_network.vnet.*.address_space[count.index], count.index)}", 13, 0)}"
}

# Enable global peering between the virtual networks.
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

resource "azurerm_virtual_network_peering" "peering0to3" {
  name                         = "peering-to-${var.locations[3]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 0)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 0)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 3)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering3to0" {
  name                         = "peering-to-${var.locations[0]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,3)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 3)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 0)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering0to4" {
  name                         = "peering-to-${var.locations[4]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 0)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 0)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 4)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering4to0" {
  name                         = "peering-to-${var.locations[0]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,4)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 4)}"
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

resource "azurerm_virtual_network_peering" "peering1to3" {
  name                         = "peering-to-${var.locations[3]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 1)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 1)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 3)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering3to1" {
  name                         = "peering-to-${var.locations[1]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,3)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 3)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 1)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering1to4" {
  name                         = "peering-to-${var.locations[4]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 1)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 1)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 4)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering4to1" {
  name                         = "peering-to-${var.locations[1]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,4)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 4)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 1)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering2to3" {
  name                         = "peering-to-${var.locations[3]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 2)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name,2)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 3)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering3to2" {
  name                         = "peering-to-${var.locations[2]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,3)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 3)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 2)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering2to4" {
  name                         = "peering-to-${var.locations[4]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 2)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name,2)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 4)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering4to2" {
  name                         = "peering-to-${var.locations[2]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,4)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 4)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 2)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering3to4" {
  name                         = "peering-to-${var.locations[4]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name, 3)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name,3)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 4)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "peering4to3" {
  name                         = "peering-to-${var.locations[3]}"
  resource_group_name          = "${element(azurerm_resource_group.rg.*.name,4)}"
  virtual_network_name         = "${element(azurerm_virtual_network.vnet.*.name, 4)}"
  remote_virtual_network_id    = "${element(azurerm_virtual_network.vnet.*.id, 3)}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet global peering.
  allow_gateway_transit = false
}
