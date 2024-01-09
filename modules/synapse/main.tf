variable "com_var" {}
variable "hub_vnet_id" {}
variable "spoke_vnet_id" {}
variable "pnp_spoke_syn_pep_subnet_id" {}
variable "pnp_hub_plh_pep_subnet_id" {}

# Azure Synapse 용도의 Storage Account 생성
resource "azurerm_storage_account" "pnp_spoke_syn_adls_d01" {
  name                     = "pnpspokesynadlsd01"  # Storage Account 이름
  resource_group_name      = var.com_var.spoke_resource_group_name  # 리소스 그룹 이름
  location                 = var.com_var.location  # 리소스 그룹 위치
  account_tier             = "Premium"  # 프리미엄 계층
  account_replication_type = "LRS"  # 로컬 복제  
  account_kind             = "BlockBlobStorage"
  is_hns_enabled = true # account_tier 가 Standard 또는 Premium이며, account_kind가 BlockBlobStorage일 때만 사용 가능

  network_rules { # Blob 서비스에 대한 CORS (Cross-Origin Resource Sharing) 규칙을 구성합니다.
    default_action = "Allow"  # 기본 동작 (Deny)
  }
}

# Azure AD 사용자의 Object ID 또는 서비스 주체의 Object ID를 지정
# variable "user_object_id" {
#   description = "권한 부여할 계정 Object Id"
#   type = string
#   default = "derik@megazone.com"
# }

# Azure 리소스 그룹에 리소스 관리자 역할 부여
# resource "azurerm_role_assignment" "example" {
#   principal_id   = var.user_object_id
#   role_definition_name = "Blob Contributor"  # 역할 정의 (Owner, Contributor, Reader 등)
#   scope          = azurerm_storage_account.pnp_spoke_syn_adls_d01.primary_blob_connection_string
# }

# Azure Storage에 대한 Container(filesystem) 생성
resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_filesystem" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.pnp_spoke_syn_adls_d01.id
}

# Network Rule Deny로 변경
# resource "azurerm_storage_account_network_rules" "pnp_spoke_syn_adls_d01_network_deny" {
#   storage_account_id  = azurerm_storage_account.pnp_spoke_syn_adls_d01.id
#   default_action      = "Deny"
#   depends_on          = [azurerm_storage_data_lake_gen2_filesystem.synapse_filesystem]
# }

# Synapse Workspace 정의
resource "azurerm_synapse_workspace" "pnp-spoke-syn-d01" {
  name                = "pnp-spoke-syn-d01"  # Synapse Workspace 이름
  resource_group_name = var.com_var.spoke_resource_group_name  # 리소스 그룹 이름
  location            = var.com_var.location  # 리소스 그룹 위치
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_filesystem.id # 연결할 ADLS 스토리지 계정
  sql_administrator_login                                = "iotsynadmin"
  sql_administrator_login_password                       = "aprkwhs123!@#"
  managed_virtual_network_enabled = true
  
  # Managed Identity 설정 (시스템 할당)
  # Synapse Workspace을 생성할 때 시스템 할당된 관리 ID를 사용하려면
  # 아래의 identity 블록을 주석 해제하고, type을 "SystemAssigned"로 지정합니다.
  identity {
    type = "SystemAssigned"
  }
}

# Synapse SQL Pool 정의
# resource "azurerm_synapse_sql_pool" "dedicated01" {
#   name                = "dedicated01"  # SQL Pool 이름
#   workspace_name      = azurerm_synapse_workspace.pnp-spoke-syn-d01.name  # Synapse Workspace 이름
#   resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
#   performance_level   = "DW100c"  # 성능 레벨
#   collation           = "SQL_Latin1_General_CP1_CI_AS"  # Collation 설정
# }

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_syn_dev_dns_zone" {
  name                = "privatelink.dev.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = var.com_var.spoke_resource_group_name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_dev_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.com_var.spoke_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_dev_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.hub_vnet_id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_dev_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.com_var.spoke_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_dev_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.spoke_vnet_id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_syn_dev_pep" {
  name                = "PNP-SPOKE-SYN-DEV-PEP"                   # Private Endpoint 이름
  resource_group_name = var.com_var.spoke_resource_group_name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.pnp_spoke_syn_pep_subnet_id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["dev"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_syn_dev_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_syn_sql_dns_zone" {
  name                = "privatelink.sql.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = var.com_var.spoke_resource_group_name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_sql_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.com_var.spoke_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.hub_vnet_id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_sql_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.com_var.spoke_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.spoke_vnet_id # 가상 네트워크 ID
}

# Synapse SQL Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_syn_sql_pep" {
  name                = "PNP-SPOKE-SYN-SQL-PEP"                   # Private Endpoint 이름
  resource_group_name = var.com_var.spoke_resource_group_name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.pnp_spoke_syn_pep_subnet_id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["sql"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.id]  # Private DNS Zone ID
  }
}

# Synapse SQL On Demand Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_syn_ondemand_pep" {
  name                = "PNP-SPOKE-SYN-ONDEMAND-PEP"                   # Private Endpoint 이름
  resource_group_name = var.com_var.spoke_resource_group_name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.pnp_spoke_syn_pep_subnet_id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["sqlondemand"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private Link Hub 정의
resource "azurerm_synapse_private_link_hub" "pnp_hub_plh_c01" {
  name                = "pnphubplhc01"  # Private Link Hub 이름
  resource_group_name = var.com_var.hub_resource_group_name  # 리소스 그룹 이름
  location            = var.com_var.location  # 리소스 그룹 위치
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_hub_plh_private_dns_zone" {
  name                = "privatelink.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = var.com_var.hub_resource_group_name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_hub_plh_c01_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.com_var.hub_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_hub_plh_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.hub_vnet_id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_hub_plh_c01_private_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.com_var.hub_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_hub_plh_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.spoke_vnet_id # 가상 네트워크 ID
}

# Synapse Private Link Web Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_hub_plh_web_pep" {
  name                = "PNP-HUB-PLH-WEB-PEP"                   # Private Endpoint 이름
  resource_group_name = var.com_var.hub_resource_group_name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.pnp_hub_plh_pep_subnet_id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_private_link_hub.pnp_hub_plh_c01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["web"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_hub_plh_private_dns_zone.id]  # Private DNS Zone ID
  }
  
}

# Dedicated SQL Pool 생성
resource "azurerm_synapse_sql_pool" "dedicated_sql_pool" {
  name                 = "pnpdedicatedsqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}