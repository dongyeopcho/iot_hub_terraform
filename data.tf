# Vnet 및 Subnet Data
# data "azurerm_virtual_network" "pnp_hub_vnet" {
#   name                = "pnp_hub_vnet" # 가상 네트워크 이름
#   resource_group_name = var.com_var.hub_resource_group_name # 가상 네트워크가 속한 리소스 그룹 이름
# }

# # Vnet 및 Subnet Data
# data "azurerm_virtual_network" "pnp_spoke_vnet" {
#   name                = "pnp_spoke_vnet" # 가상 네트워크 이름
#   resource_group_name = var.com_var.spoke_resource_group_name # 가상 네트워크가 속한 리소스 그룹 이름
# }

# # Hub Resource Group Data 
# data "azurerm_resource_group" "pnp_hub_rg" {
#   name     = "PNP-HUB-RG" # 리소스 그룹 이름
# }

# # Spoke Resource Group Data
# data "azurerm_resource_group" "pnp_spoke_rg" {
#   name     = "PNP-SPOKE-RG" # 리소스 그룹 이름
# }