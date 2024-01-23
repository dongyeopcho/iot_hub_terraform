
### Output 설정

output "network_output" {
  value = {
    "hub_vnet" = azurerm_virtual_network.hub_vnet
    "hub_subnet" = {
      "bastion_id" = azurerm_subnet.hub_bastion_pep_subnet.id
      "iot_id" = azurerm_subnet.hub_iot_pep_subnet.id
      "plh_id" = azurerm_subnet.hub_plh_pep_subnet.id
      "adb_id" = azurerm_subnet.hub_adb_pep_subnet.id
    }
    "hub_nsg" = {
      "adb_auth_id" = azurerm_network_security_group.hub_adb_auth_nsg.id
    }
    "spoke_vnet" = azurerm_virtual_network.spoke_vnet
    "spoke_subnet" = {
      "data_st_id" = azurerm_subnet.spoke_data_st_pep_subnet.id
      "syn_id" = azurerm_subnet.spoke_syn_pep_subnet.id
      "adb_id" = azurerm_subnet.spoke_adb_pep_subnet.id
    }
    "spoke_nsg" = {
      "adb_backend_id" = azurerm_network_security_group.spoke_adb_backend_nsg.id
    }
  }
}

# output "hub_vnet_id" {
#   value = azurerm_virtual_network.hub_vnet.id
# }

# output "spoke_vnet_id" {
#   value = azurerm_virtual_network.spoke_vnet.id
# }

# output "hub_bastion_pep_subnet_id" {
#   value = azurerm_subnet.hub_bastion_pep_subnet.id
# }

# output "hub_iot_pep_subnet_id" {
#   value = azurerm_subnet.hub_iot_pep_subnet.id
# }

# output "hub_plh_pep_subnet_id" {
#   value = azurerm_subnet.hub_plh_pep_subnet.id
# }

# output "hub_adb_pep_subnet_id" {
#   value = azurerm_subnet.hub_adb_pep_subnet.id
# }

# output "spoke_data_st_pep_subnet_id" {
#   value = azurerm_subnet.spoke_data_st_pep_subnet.id
# }

# output "spoke_syn_pep_subnet_id" {
#   value = azurerm_subnet.spoke_syn_pep_subnet.id
# }

# output "spoke_adb_pep_subnet_id" {
#   value = azurerm_subnet.spoke_adb_pep_subnet.id
# }

# output "hub_adb_auth_nsg_id" {
#   value = azurerm_network_security_group.hub_adb_auth_nsg.id
# }

# output "spoke_adb_backend_nsg_id" {
#   value = azurerm_network_security_group.spoke_adb_backend_nsg.id
# }