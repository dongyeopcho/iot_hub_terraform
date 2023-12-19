variable "env" {
  type = string
  default = "dev"
  description = "Environment"
}

variable "com_var" {
  default = {
    location = "Korea Central"
    hub_resource_group_name = "PNP-HUB-RG"
    spoke_resource_group_name = "PNP-SPOKE-RG"
    hub_vnet_name = "pnp_hub_vnet"
    spoke_vnet_name = "pnp_spoke_vnet"
    tags = {
      Environment = "dev"
      Owner = "Derik"
      ManagedBy = "Terraform"
    }
  }
}
