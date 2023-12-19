variable "create_yn" {
  default = {
    bastion = true
    datalake = true
    function = true
    iothub = true
    network = true
    synapse = true
  }
}

module "bastion_module" {  
  source                    = "./modules/bation"       # 모듈 소스 경로
  count = var.create_yn.bastion ? 1 : 0
  shared_var = var.com_var
}

module "datalake_module" {  
  source                    = "./modules/bation"       # 모듈 소스 경로
  count = var.create_yn.bastion ? 1 : 0
  shared_var = var.com_var
}

# Hub Resource Group 생성 
resource "azurerm_resource_group" "pnp_hub_rg" {
  location = var.shared_var.hub_resource_group_name # 리소스 그룹 위치 변수 사용
  name     = "PNP-HUB-RG" # 리소스 그룹 이름
}

# Spoke Resource Group 생성
resource "azurerm_resource_group" "pnp_spoke_rg" {
  location = var.shared_var.spoke_resource_group_name # 리소스 그룹 위치 변수 사용
  name     = "PNP-SPOKE-RG" # 리소스 그룹 이름
}