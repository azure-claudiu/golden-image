variable "az_sub_id" {
  type = string
}
variable "az_tenant_id" {
  type = string
}
variable "az_client_id" {
  type = string
}
variable "az_client_secret" {
  type = string
  sensitive = true
}
variable "az_rg_name" {
  type = string
  default = "team3-rg"
}
variable "az_image_name" {
  type = string
  default = "ccomsa-image3w"
}

source "azure-arm" "experiment3" {
  azure_tags = {
    team = "Team3"
    task = "Image deployment"
  }
  subscription_id                   = var.az_sub_id
  tenant_id                         = var.az_tenant_id
  client_id                         = var.az_client_id
  client_secret                     = var.az_client_secret
  managed_image_resource_group_name = var.az_rg_name
  managed_image_name                = var.az_image_name

  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = "2019-Datacenter"
  location                          = "East US"
  os_type                           = "Windows"
  vm_size                           = "Standard_D2_v2"
  communicator                      = "winrm"
  winrm_use_ssl                     = true
  winrm_insecure                    = true
  winrm_timeout                     = "5m"
  winrm_username                    = "packer"
}

build {
  sources = ["source.azure-arm.experiment3"]

  provisioner "ansible" {
    playbook_file = "ansible/win-apache.yml"
  }
}
