variable "com_var" {}
variable "conv" {}

# Hub Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "pnp_hub_vnet" {
  name                = var.com_var.hub_vnet_name # 가상 네트워크 이름
  address_space       = ["10.0.0.0/16"] # 가상 네트워크 주소 공간
  location            = var.com_var.location # 가상 네트워크 위치
  resource_group_name = var.com_var.hub_resource_group_name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "pnp_hub_bastion_pep_subnet" {
  name                 = "${var.conv.project_name}-hub-bastion-pep-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.1.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_hub_vnet ]
}

resource "azurerm_subnet" "pnp_hub_iot_pep_subnet" {
  name                 = "${var.conv.project_name}-hub-iot-pep-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.2.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_hub_vnet ]
}

resource "azurerm_subnet" "pnp_hub_plh_pep_subnet" {
  name                 = "${var.conv.project_name}-hub-plh-pep-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.3.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_hub_vnet ]
}

# Azure Auth 용도의 Public Subnet 생성
resource "azurerm_subnet" "pnp_hub_adb_auth_public_subnet" {
  name                 = "${var.conv.project_name}-hub-adb-auth-public-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.4.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_hub_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Auth 용도의 Private Subnet 생성
resource "azurerm_subnet" "pnp_hub_adb_auth_private_subnet" {
  name                 = "${var.conv.project_name}-hub-adb-auth-private-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.5.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_hub_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Databricks Hub Private Endpoint 용도의 Subnet 생성
resource "azurerm_subnet" "pnp_hub_adb_pep_subnet" {
  name                 = "${var.conv.project_name}-hub-adb-pep-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.hub_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.hub_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.6.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_hub_vnet ]
}

# # Azure Auth 용도의 Public Subnet의 Network Security Group 생성
# resource "azurerm_network_security_group" "pnp_hub_adb_auth_public_nsg" {
#   name = "pnp-hub-adb-auth-public-nsg"
#   location = var.com_var.location
#   resource_group_name = var.com_var.hub_resource_group_name
# }

# # Azure Auth 용도의 Private Subnet의 Network Security Group 생성
# resource "azurerm_network_security_group" "pnp_hub_adb_auth_private_nsg" {
#   name = "pnp-hub-adb-auth-private-nsg"
#   location = var.com_var.location
#   resource_group_name = var.com_var.hub_resource_group_name
# }

# Azure Auth 용도의 Network Security Group 생성
resource "azurerm_network_security_group" "auth_nsg" {
  name = "pnp-hub-adb-auth-nsg"
  location = var.com_var.location
  resource_group_name = var.com_var.hub_resource_group_name
}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "pnp_hub_adb_auth_public_subnet_nsg" {
  subnet_id = azurerm_subnet.pnp_hub_adb_auth_public_subnet.id
  network_security_group_id = azurerm_network_security_group.pnp_hub_adb_auth_public_nsg.id

}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "pnp_hub_adb_auth_private_subnet_nsg" {
  subnet_id = azurerm_subnet.pnp_hub_adb_auth_private_subnet.id
  network_security_group_id = azurerm_network_security_group.pnp_hub_adb_auth_private_nsg.id
}

# Spoke Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "pnp_spoke_vnet" {
  name                = var.com_var.spoke_vnet_name # 가상 네트워크 이름
  address_space       = ["10.1.0.0/16"] # 가상 네트워크 주소 공간
  location            = var.com_var.location # 가상 네트워크 위치
  resource_group_name = var.com_var.spoke_resource_group_name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "pnp_spoke_syn_pep_subnet" {
  name                 = "${var.conv.project_name}-spoke-syn-pep-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.spoke_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.spoke_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.1.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_spoke_vnet ]
}

resource "azurerm_subnet" "pnp_spoke_data_st_pep_subnet" {
  name                 = "${var.conv.project_name}-spoke-data-st-pep-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.spoke_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.spoke_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.2.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_spoke_vnet ]
}

# Azure Backend 용도의 Public Subnet 생성
resource "azurerm_subnet" "pnp_spoke_adb_backend_public_subnet" {
  name                 = "${var.conv.project_name}-spoke-adb-backend-public-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.spoke_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.spoke_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.3.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_spoke_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Backend 용도의 private Subnet 생성
resource "azurerm_subnet" "pnp_spoke_adb_backend_private_subnet" {
  name                 = "${var.conv.project_name}-spoke-adb-backend-private-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.spoke_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.spoke_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.4.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_spoke_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Databricks Hub Private Endpoint 용도의 Subnet 생성
resource "azurerm_subnet" "pnp_spoke_adb_pep_subnet" {
  name                 = "${var.conv.project_name}-spoke-adb-pep-subnet" # 서브넷 이름
  resource_group_name  = var.com_var.spoke_resource_group_name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = var.com_var.spoke_vnet_name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.5.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.pnp_spoke_vnet ]
}

# # Azure Backend 용도의 Public Subnet의 Network Security Group 생성
# resource "azurerm_network_security_group" "pnp_spoke_adb_backend_public_nsg" {
#   name = "pnp-spoke-adb-backend-public-nsg"
#   location = var.com_var.location
#   resource_group_name = var.com_var.spoke_resource_group_name
# }

# # Azure Backend 용도의 Private Subnet의 Network Security Group 생성
# resource "azurerm_network_security_group" "pnp_spoke_adb_backend_private_nsg" {
#   name = "pnp-spoke-adb-backend-private-nsg"
#   location = var.com_var.location
#   resource_group_name = var.com_var.spoke_resource_group_name
# }

# Azure Backend 용도의 Network Security Group 생성
resource "azurerm_network_security_group" "pnp_spoke_adb_backend_nsg" {
  name = "pnp-spoke-adb-backend-nsg"
  location = var.com_var.location
  resource_group_name = var.com_var.spoke_resource_group_name
}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "pnp_spoke_adb_backend_public_subnet_nsg" {
  subnet_id = azurerm_subnet.pnp_spoke_adb_backend_public_subnet.id
  network_security_group_id = azurerm_network_security_group.pnp_spoke_adb_backend_public_nsg.id
}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "pnp_spoke_adb_backend_private_subnet_nsg" {
  subnet_id = azurerm_subnet.pnp_spoke_adb_backend_private_subnet.id
  network_security_group_id = azurerm_network_security_group.pnp_spoke_adb_backend_private_nsg.id
}

# 가상 네트워크 피어링 설정 (Hub Vnet에서 Spoke Vnet으로)
resource "azurerm_virtual_network_peering" "peer_hub_to_spoke" {
  name                         = "peer_hub_to_spoke"
  resource_group_name          = var.com_var.hub_resource_group_name
  virtual_network_name         = var.com_var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

# 가상 네트워크 피어링 설정 (Spoke Vnet에서 Hub Vnet으로)
resource "azurerm_virtual_network_peering" "peer_spoke_to_hub" {
  name                         = "peer_spoke_to_hub"
  resource_group_name          = var.com_var.spoke_resource_group_name
  virtual_network_name         = var.com_var.spoke_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id
  allow_forwarded_traffic      = false
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}
