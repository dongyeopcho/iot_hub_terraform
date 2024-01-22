
### Output 설정
output "hub_vnet_id" {
  value = azurerm_virtual_network.pnp_hub_vnet.id
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.pnp_spoke_vnet.id
}

output "pnp_hub_bastion_pep_subnet_id" {
  value = azurerm_subnet.pnp_hub_bastion_pep_subnet.id
}

output "pnp_hub_iot_pep_subnet_id" {
  value = azurerm_subnet.pnp_hub_iot_pep_subnet.id
}

output "pnp_spoke_data_st_pep_subnet_id" {
  value = azurerm_subnet.pnp_spoke_data_st_pep_subnet.id
}

output "pnp_spoke_syn_pep_subnet_id" {
  value = azurerm_subnet.pnp_spoke_syn_pep_subnet.id
}

output "pnp_hub_plh_pep_subnet_id" {
  value = azurerm_subnet.pnp_hub_plh_pep_subnet.id
}

# output "pnp_hub_adb_auth_public_nsg_id" {
#   value = azurerm_network_security_group.pnp_hub_adb_auth_public_nsg.id
# }

# output "pnp_hub_adb_auth_private_nsg_id" {
#   value = azurerm_network_security_group.pnp_hub_adb_auth_private_nsg.id
# }

output "pnp_hub_adb_auth_nsg_id" {
  value = azurerm_network_security_group.pnp_hub_adb_auth_nsg.id
}

# output "pnp_spoke_adb_backend_public_nsg_id" {
#   value = azurerm_network_security_group.pnp_spoke_adb_backend_public_nsg.id
# }

# output "pnp_spoke_adb_backend_private_nsg_id" {
#   value = azurerm_network_security_group.pnp_spoke_adb_backend_private_nsg.id
# }

output "pnp_spoke_adb_backend_nsg_id" {
  value = azurerm_network_security_group.pnp_spoke_adb_backend_nsg.id
}

output "pnp_hub_adb_pep_subnet_id" {
  value = azurerm_subnet.pnp_hub_adb_pep_subnet.id
}

output "pnp_spoke_adb_pep_subnet_id" {
  value = azurerm_subnet.pnp_spoke_adb_pep_subnet.id
}