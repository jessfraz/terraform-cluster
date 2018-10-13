variable "prefix" {}

variable "location" {
  description = "The location/region where the resources are created. Changing this forces a new resource to be created."
  default     = "West US"
}

variable "rg" {
  description = "The name of the resource group in which to create the resources."
  default     = "nomad-cluster"
}

variable "hostname" {
  description = "Virtual machine name."
  default     = "vm"
}

variable "master_vmsize" {
  description = "Specifies the size of the virtual machine for the masters."
  default     = "Standard_D8_v3"
}

variable "agent_vmsize" {
  description = "Specifies the size of the virtual machine for the agents."
  default     = "Standard_D3_v2"
}

variable "username" {
  description = "The system administrator user name."
  default     = "vmuser"
}

variable "public_key_path" {
  description = "Path to your SSH Public Key"
  default     = "~/.azure/ssh_key"
}

variable "cloud_config_master" {
  default = "../cloud-config-master.yml"
}

variable "cloud_config_agent" {
  default = "../cloud-config-agent.yml"
}

variable "cloud_config_bastion" {
  default = "../cloud-config-bastion.yml"
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
