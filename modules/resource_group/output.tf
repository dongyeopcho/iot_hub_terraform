
### Output 설정
output "resource_group_output" {
  value = {
    "hub_rg" = azurerm_resource_group.hub_rg
    "spoke_rg" = azurerm_resource_group.spoke_rg
  }  
}

