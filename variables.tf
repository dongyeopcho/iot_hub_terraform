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
    hub_vnet_name = "PNP-HUB-VNET"
    spoke_vnet_name = "PNP-SPOKE-VNET"
    tags = {
      Environment = "dev"
      Owner = "Derik"
      ManagedBy = "Terraform"
      DeploymentTimestamp = timeadd(timestamp(), "9h")
    }
  }
}
