variable "prefix" {}

variable "location" {
  description = "The location/region where the resources are created. Changing this forces a new resource to be created."
  default     = "West US"
}

variable "rg" {
  description = "The name of the resource group in which to create the resources."
  default     = "mesos-cluster-packer"
}

variable "storageaccount" {
  description = "Name of the storage account to create."
  default     = "packerimages"
}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

provider "azurerm" {
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
}
