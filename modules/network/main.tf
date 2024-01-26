variable "com_var" {}
variable "resource_group" {}

# Hub Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-${var.com_var.conf.location_name}-hub-vnet" # 가상 네트워크 이름
  address_space       = ["10.0.0.0/16"] # 가상 네트워크 주소 공간
  location            = var.com_var.location # 가상 네트워크 위치
  resource_group_name = var.resource_group.hub_rg.name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "hub_bastion_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-hub-bastion-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.1.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.hub_vnet ]
}

resource "azurerm_subnet" "hub_iot_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-hub-iot-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.2.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.hub_vnet ]
}

resource "azurerm_subnet" "hub_plh_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-hub-plh-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.3.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.hub_vnet ]
}

# Azure Auth 용도의 Public Subnet 생성
resource "azurerm_subnet" "hub_adb_auth_public_subnet" {
  name                 = "${var.com_var.conf.project_name}-hub-adb-auth-public-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.4.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.hub_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Auth 용도의 Private Subnet 생성
resource "azurerm_subnet" "hub_adb_auth_private_subnet" {
  name                 = "${var.com_var.conf.project_name}-hub-adb-auth-private-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.5.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.hub_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Databricks Hub Private Endpoint 용도의 Subnet 생성
resource "azurerm_subnet" "hub_adb_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-hub-adb-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.6.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.hub_vnet ]
}

# # Azure Auth 용도의 Public Subnet의 Network Security Group 생성
# resource "azurerm_network_security_group" "hub_adb_auth_public_nsg" {
#   name = "pnp-hub-adb-auth-public-nsg"
#   location = var.com_var.location
#   resource_group_name = var.resource_group.hub_rg.name
# }

# # Azure Auth 용도의 Private Subnet의 Network Security Group 생성
# resource "azurerm_network_security_group" "hub_adb_auth_private_nsg" {
#   name = "pnp-hub-adb-auth-private-nsg"
#   location = var.com_var.location
#   resource_group_name = var.resource_group.hub_rg.name
# }

# Azure Auth 용도의 Network Security Group 생성
resource "azurerm_network_security_group" "hub_adb_auth_nsg" {
  name = "pnp-hub-adb-auth-nsg"
  location = var.com_var.location
  resource_group_name = var.resource_group.hub_rg.name
}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "hub_adb_auth_public_subnet_nsg" {
  subnet_id = azurerm_subnet.hub_adb_auth_public_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_adb_auth_nsg.id

}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "hub_adb_auth_private_subnet_nsg" {
  subnet_id = azurerm_subnet.hub_adb_auth_private_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_adb_auth_nsg.id
}

# Spoke Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-${var.com_var.conf.location_name}-spoke-vnet" # 가상 네트워크 이름
  address_space       = ["10.1.0.0/16"] # 가상 네트워크 주소 공간
  location            = var.com_var.location # 가상 네트워크 위치
  resource_group_name = var.resource_group.spoke_rg.name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "spoke_syn_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-spoke-syn-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.1.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.spoke_vnet ]
}

resource "azurerm_subnet" "spoke_data_st_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-spoke-data-st-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.2.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.spoke_vnet ]
}

# Azure Backend 용도의 Public Subnet 생성
resource "azurerm_subnet" "spoke_adb_backend_public_subnet" {
  name                 = "${var.com_var.conf.project_name}-spoke-adb-backend-public-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.3.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.spoke_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Backend 용도의 private Subnet 생성
resource "azurerm_subnet" "spoke_adb_backend_private_subnet" {
  name                 = "${var.com_var.conf.project_name}-spoke-adb-backend-private-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.4.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.spoke_vnet ]

  delegation {
    name = "databricks_delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Databricks Spoke Private Endpoint 용도의 Subnet 생성
resource "azurerm_subnet" "spoke_adb_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-spoke-adb-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.5.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.spoke_vnet ]
}

# Azure SQL Database Spoke Private Endpoint 용도의 Subnet 생성
resource "azurerm_subnet" "spoke_sql_pep_subnet" {
  name                 = "${var.com_var.conf.project_name}-spoke-sql-pep-subnet" # 서브넷 이름
  resource_group_name  = var.resource_group.spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.6.0/24"] # 서브넷 주소 공간
  depends_on = [ azurerm_virtual_network.spoke_vnet ]
}

# Azure Backend 용도의 Network Security Group 생성
resource "azurerm_network_security_group" "spoke_adb_backend_nsg" {
  name = "pnp-spoke-adb-backend-nsg"
  location = var.com_var.location
  resource_group_name = var.resource_group.spoke_rg.name
}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "spoke_adb_backend_public_subnet_nsg" {
  subnet_id = azurerm_subnet.spoke_adb_backend_public_subnet.id
  network_security_group_id = azurerm_network_security_group.spoke_adb_backend_nsg.id
}

# Azure Subnet에 NSG 할당
resource "azurerm_subnet_network_security_group_association" "spoke_adb_backend_private_subnet_nsg" {
  subnet_id = azurerm_subnet.spoke_adb_backend_private_subnet.id
  network_security_group_id = azurerm_network_security_group.spoke_adb_backend_nsg.id
}

# 가상 네트워크 피어링 설정 (Hub Vnet에서 Spoke Vnet으로)
resource "azurerm_virtual_network_peering" "peer_hub_to_spoke" {
  name                         = "peer_hub_to_spoke"
  resource_group_name          = var.resource_group.hub_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

# 가상 네트워크 피어링 설정 (Spoke Vnet에서 Hub Vnet으로)
resource "azurerm_virtual_network_peering" "peer_spoke_to_hub" {
  name                         = "peer_spoke_to_hub"
  resource_group_name          = var.resource_group.spoke_rg.name
  virtual_network_name         = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_forwarded_traffic      = false
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

# Private DNS Zone 생성

# IoT Hub Private DNS Zone 정의
resource "azurerm_private_dns_zone" "iothub_private_dns_zone" {
  name                = "privatelink.azure-devices.net"  # Private DNS Zone 이름
  resource_group_name = var.resource_group.hub_rg.name  # 리소스 그룹 이름
}

# ServiceBus Private DNS Zone 정의
resource "azurerm_private_dns_zone" "servicebus_private_dns_zone" {
  name                = "privatelink.servicebus.windows.net"  # Private DNS Zone 이름
  resource_group_name = var.resource_group.hub_rg.name  # 리소스 그룹 이름
}

# IoT Hub Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "iothub_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.resource_group.hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.iothub_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id # 가상 네트워크 ID
}

# Service Bus Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "servicebus_private_dns_zone_link_hub" {
  name                  = "link_hub" # 링크 이름
  resource_group_name   = var.resource_group.hub_rg.name # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.servicebus_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id # 가상 네트워크 ID
}

# Service Bus Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "servicebus_private_dns_zone_link_spoke" {
  name                  = "link_spoke" # 링크 이름
  resource_group_name   = var.resource_group.hub_rg.name # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.servicebus_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id # 가상 네트워크 ID
}

# SQL Private DNS Zone 정의
resource "azurerm_private_dns_zone" "sql_private_dns_zone" {
  name                = "privatelink.database.windows.net"  # Private DNS Zone 이름
  resource_group_name = var.resource_group.spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "sql_private_dns_zone_link_hub" {
  name                  = "link_hub" # 링크 이름
  resource_group_name   = var.resource_group.spoke_rg.name # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.sql_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "sql_private_dns_zone_link_spoke" {
  name                  = "link_spoke" # 링크 이름
  resource_group_name   = var.resource_group.spoke_rg.name # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.sql_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "spoke_syn_dev_dns_zone" {
  name                = "privatelink.dev.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = var.resource_group.spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "spoke_syn_dev_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.resource_group.spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.spoke_syn_dev_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "spoke_syn_dev_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.resource_group.spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.spoke_syn_dev_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "spoke_syn_sql_dns_zone" {
  name                = "privatelink.sql.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = var.resource_group.spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "spoke_syn_sql_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.resource_group.spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.spoke_syn_sql_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "spoke_syn_sql_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.resource_group.spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.spoke_syn_sql_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "hub_plh_private_dns_zone" {
  name                = "privatelink.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = var.resource_group.hub_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "hub_plh_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.resource_group.hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.hub_plh_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "hub_plh_private_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.resource_group.hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.hub_plh_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id # 가상 네트워크 ID
}