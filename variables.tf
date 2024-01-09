variable "env" {
  type = string
  description = "Environment"
}

variable "project_name" {
  description = "Project Name"
  type = string
}

variable "location_name" {
  description = "Location Name"
  type = string
}

variable "com_var" {
  default = {
    location = "Korea Central"
    hub_resource_group_name = "PNP-HUB-RG"
    spoke_resource_group_name = "PNP-SPOKE-RG"
    hub_vnet_name = "pnp_hub_vnet"
    spoke_vnet_name = "pnp_spoke_vnet"
    conv = {
      env = "d"
      project_name = "pnp"
      location_name = "kr"
    }
    tags = {
      Environment = "dev"
      Owner = "Derik"
      ManagedBy = "Terraform"
    }
  }
}

variable "subscription_id" {
  description = "Azure subscription ID"
}