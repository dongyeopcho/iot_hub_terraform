
# Hub Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "pnp_hub_vnet" {
  name                = "pnp_hub_vnet" # 가상 네트워크 이름
  address_space       = ["10.0.0.0/16"] # 가상 네트워크 주소 공간
  location            = var.shared_var.location # 가상 네트워크 위치
  resource_group_name = var.shared_var.hub_resource_group_name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "pnp_hub_bastion_pep_subnet" {
  name                 = "PNP-HUB-BASTION-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = var.shared_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.shared_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.1.0/24"] # 서브넷 주소 공간
}

resource "azurerm_subnet" "pnp_hub_iot_pep_subnet" {
  name                 = "PNP-HUB-IOT-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = var.shared_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.shared_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.2.0/24"] # 서브넷 주소 공간
}

resource "azurerm_subnet" "pnp_hub_plh_pep_subnet" {
  name                 = "PNP-HUB-PLH-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = var.shared_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.shared_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.3.0/24"] # 서브넷 주소 공간
}

# Spoke Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "pnp_spoke_vnet" {
  name                = "pnp_spoke_vnet" # 가상 네트워크 이름
  address_space       = ["10.1.0.0/16"] # 가상 네트워크 주소 공간
  location            = var.shared_var.location # 가상 네트워크 위치
  resource_group_name = var.shared_var.spoke_resource_group_name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "pnp_spoke_syn_pep_subnet" {
  name                 = "PNP-SPOKE-SYN-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = var.shared_var.spoke_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.shared_var.spoke_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.1.0/24"] # 서브넷 주소 공간
}

resource "azurerm_subnet" "pnp_spoke_data_st_pep_subnet" {
  name                 = "PNP-SPOKE-DATA-ST-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = var.shared_var.spoke_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.shared_var.spoke_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.2.0/24"] # 서브넷 주소 공간
}

# 가상 네트워크 피어링 설정 (Hub Vnet에서 Spoke Vnet으로)
resource "azurerm_virtual_network_peering" "peer_hub_to_spoke" {
  name                         = "peer_hub_to_spoke"
  resource_group_name          = var.shared_var.hub_resource_group_name
  virtual_network_name         = var.shared_var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

# 가상 네트워크 피어링 설정 (Spoke Vnet에서 Hub Vnet으로)
resource "azurerm_virtual_network_peering" "peer_spoke_to_hub" {
  name                         = "peer_spoke_to_hub"
  resource_group_name          = var.shared_var.spoke_resource_group_name
  virtual_network_name         = var.shared_var.spoke_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id
  allow_forwarded_traffic      = false
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}