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
  default = "ccomsa-image3b"
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

  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "16.04-LTS"
  location                          = "East US"
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.experiment3"]

  #provisioner "shell" {
  #  script = "${path.root}/scripts/base.sh"
  #}

  provisioner "ansible" {
    playbook_file = "ansible/nginx.yml"
  }
}
