variable "com_var" {}

# Hub Resource Group 생성 
resource "azurerm_resource_group" "hub_rg" {
  location = var.com_var.location # 리소스 그룹 위치 변수 사용
  name     = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-${var.com_var.conf.location_name}-hub-rg" # 리소스 그룹 이름
}

# Spoke Resource Group 생성
resource "azurerm_resource_group" "spoke_rg" {
  location = var.com_var.location # 리소스 그룹 위치 변수 사용
  name     = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-${var.com_var.conf.location_name}-spoke-rg" # 리소스 그룹 이름
}
