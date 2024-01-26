variable "com_var" {}
variable "resource_group" {}
variable "network" {}

# Azure Synapse 용도의 Storage Account 생성
resource "azurerm_storage_account" "spoke_syn_adls_d01" {
  name                     = "${var.com_var.conf.project_name}${var.com_var.conf.env}spokesynwadls01"  # Storage Account 이름
  resource_group_name      = var.resource_group.spoke_rg.name  # 리소스 그룹 이름
  location                 = var.com_var.location  # 리소스 그룹 위치
  account_tier             = "Premium"  # 프리미엄 계층
  account_replication_type = "LRS"  # 로컬 복제  
  account_kind             = "BlockBlobStorage"
  is_hns_enabled = true # account_tier 가 Standard 또는 Premium이며, account_kind가 BlockBlobStorage일 때만 사용 가능

  network_rules { # Blob 서비스에 대한 CORS (Cross-Origin Resource Sharing) 규칙을 구성합니다.
    default_action = "Allow"  # 기본 동작 (Deny)
  }
}

# Azure Storage에 대한 Container(filesystem) 생성
resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_filesystem" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.spoke_syn_adls_d01.id
}

# Network Rule Deny로 변경
# resource "azurerm_storage_account_network_rules" "spoke_syn_adls_d01_network_deny" {
#   storage_account_id  = azurerm_storage_account.spoke_syn_adls_d01.id
#   default_action      = "Deny"
#   depends_on          = [azurerm_storage_data_lake_gen2_filesystem.synapse_filesystem]
# }

# Synapse Workspace 정의
resource "azurerm_synapse_workspace" "pnp-spoke-syn-d01" {
  name                = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-spoke-syn-01"  # Synapse Workspace 이름
  resource_group_name = var.resource_group.spoke_rg.name  # 리소스 그룹 이름
  location            = var.com_var.location  # 리소스 그룹 위치
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_filesystem.id # 연결할 ADLS 스토리지 계정
  sql_administrator_login = "iotsynadmin"
  sql_administrator_login_password = "aprkwhs123!@#"
  managed_virtual_network_enabled = true
  
  # Managed Identity 설정 (시스템 할당)
  # Synapse Workspace을 생성할 때 시스템 할당된 관리 ID를 사용하려면
  # 아래의 identity 블록을 주석 해제하고, type을 "SystemAssigned"로 지정합니다.
  identity {
    type = "SystemAssigned"
  }
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "spoke_syn_dev_pep" {
  name                = "${var.com_var.conf.project_name}-spoke-syn-dev-pep"                   # Private Endpoint 이름
  resource_group_name = var.resource_group.spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.network.spoke_subnet.syn_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["dev"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [var.network.private_dns.syn_dev.id]  # Private DNS Zone ID
  }
}

# Synapse SQL Private Endpoint 생성
resource "azurerm_private_endpoint" "spoke_syn_sql_pep" {
  name                = "${var.com_var.conf.project_name}-spoke-syn-sql-pep"                   # Private Endpoint 이름
  resource_group_name = var.resource_group.spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.network.spoke_subnet.syn_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["sql"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [var.network.private_dns.syn_sql.id]  # Private DNS Zone ID
  }
}

# Synapse SQL On Demand Private Endpoint 생성
resource "azurerm_private_endpoint" "spoke_syn_ondemand_pep" {
  name                = "${var.com_var.conf.project_name}-spoke-syn-ondemand-pep"                   # Private Endpoint 이름
  resource_group_name = var.resource_group.spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.network.spoke_subnet.syn_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["sqlondemand"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [var.network.private_dns.syn_sql.id]  # Private DNS Zone ID
  }
}

# Private Link Hub 정의
resource "azurerm_synapse_private_link_hub" "hub_plh_c01" {
  name                = "pnphubplhc01"  # Private Link Hub 이름
  resource_group_name = var.resource_group.hub_rg.name  # 리소스 그룹 이름
  location            = var.com_var.location  # 리소스 그룹 위치
}

# Synapse Private Link Web Private Endpoint 생성
resource "azurerm_private_endpoint" "hub_plh_web_pep" {
  name                = "${var.com_var.conf.project_name}-hub-plh-web-pep"                   # Private Endpoint 이름
  resource_group_name = var.resource_group.hub_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.network.hub_subnet.plh_id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_private_link_hub.hub_plh_c01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["web"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [var.network.private_dns.plh.id]  # Private DNS Zone ID
  }
}

# Dedicated SQL Pool 생성
# resource "azurerm_synapse_sql_pool" "dedicated_sql_pool" {
#   name                 = "${var.com_var.conf.project_name}dedicatedsqlpool"
#   synapse_workspace_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id
#   sku_name             = "DW100c"
#   create_mode          = "Default"
# }