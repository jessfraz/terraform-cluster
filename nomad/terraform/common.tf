resource "azurerm_resource_group" "rg" {
  count = "${length(var.locations)}"

  name     = "${var.prefix}-${var.rg}-${element(var.locations, count.index)}"
  location = "${element(var.locations, count.index)}"

  tags {
    app = "nomad-cluster"
  }
}
