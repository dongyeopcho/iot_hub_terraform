variable "com_var" {}

# Hub Resource Group 생성 
resource "azurerm_resource_group" "pnp_hub_rg" {
  location = var.com_var.location # 리소스 그룹 위치 변수 사용
  name     = var.com_var.hub_resource_group_name # 리소스 그룹 이름
}

# Spoke Resource Group 생성
resource "azurerm_resource_group" "pnp_spoke_rg" {
  location = var.com_var.location # 리소스 그룹 위치 변수 사용
  name     = var.com_var.spoke_resource_group_name # 리소스 그룹 이름
}
