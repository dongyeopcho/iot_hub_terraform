
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
      "sql_id" = azurerm_subnet.spoke_sql_pep_subnet.id
    }
    "spoke_nsg" = {
      "adb_backend_id" = azurerm_network_security_group.spoke_adb_backend_nsg.id
    }
    "private_dns" = {
      "iothub" = azurerm_private_dns_zone.iothub_private_dns_zone
      "servicebus" = azurerm_private_dns_zone.servicebus_private_dns_zone
      "sql" = azurerm_private_dns_zone.sql_private_dns_zone
      "syn_dev" = azurerm_private_dns_zone.spoke_syn_dev_dns_zone
      "syn_sql" = azurerm_private_dns_zone.spoke_syn_sql_dns_zone
      "plh" = azurerm_private_dns_zone.hub_plh_private_dns_zone
    }
  }
}
