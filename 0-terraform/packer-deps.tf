resource "azurerm_resource_group" "packer-resource-group" {
  name     = "${var.rg}"
  location = "${var.location}"

  tags {
    app = "${var.prefix}-mesos-cluster"
  }
}

resource "azurerm_storage_account" "packer-storage-account" {
  name                     = "${var.prefix}${var.storageaccount}"
  resource_group_name      = "${azurerm_resource_group.packer-resource-group.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    app = "mesos-cluster"
  }
}
