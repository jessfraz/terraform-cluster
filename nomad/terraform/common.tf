resource "azurerm_resource_group" "rg" {
  count = "${length(var.location)}"

  name     = "${var.prefix}-${var.rg}-${element(var.location, count.index)}"
  location = "${element(var.location, count.index)}"

  tags {
    app = "nomad-cluster"
  }
}
