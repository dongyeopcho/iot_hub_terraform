
### Output 설정
output "azurerm_storage_account_connection_string" {
  value = azurerm_storage_account.pnp_spoke_data_adls_d01.primary_blob_connection_string
}

output "azurerm_storage_account_name" {
  value = azurerm_storage_account.pnp_spoke_data_adls_d01.name
}

output "azurerm_storage_account_id" {
  value = azurerm_storage_account.pnp_spoke_data_adls_d01.id
}
