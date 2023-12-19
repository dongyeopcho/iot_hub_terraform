# Data Lake 용도의 Storage Account 생성
resource "azurerm_storage_account" "pnp_spoke_data_adls_d01" {
  name                     = "pnpspokedataadlsd01"  # Storage Account 이름
  resource_group_name      = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
  location                 = var.resource_group_location  # 리소스 그룹 위치
  account_tier             = "Premium"  # 프리미엄 계층
  account_replication_type = "LRS"  # 로컬 복제  
  account_kind             = "BlockBlobStorage"
  is_hns_enabled = true # account_tier 가 Standard 또는 Premium이며, account_kind가 BlockBlobStorage일 때만 사용 가능

  network_rules { # Blob 서비스에 대한 CORS (Cross-Origin Resource Sharing) 규칙을 구성합니다.
    default_action = "Deny"  # 기본 동작 (Deny)
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_adls_blob_dns_zone" {
  name                = "privatelink.blob.core.windows.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_blob_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_blob_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_blob_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_blob_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_data_st_blob_pep" {
  name                = "PNP-SPOKE-DATA-ST-BLOB-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_data_st_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-storage-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_storage_account.pnp_spoke_data_adls_d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["blob"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_adls_blob_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_adls_web_dns_zone" {
  name                = "privatelink.web.core.windows.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_web_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_web_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_web_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_web_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_data_st_web_pep" {
  name                = "PNP-SPOKE-DATA-ST-WEB-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_data_st_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-storage-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_storage_account.pnp_spoke_data_adls_d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["web"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_adls_web_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_adls_dfs_dns_zone" {
  name                = "privatelink.dfs.core.windows.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_dfs_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_dfs_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_dfs_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_dfs_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_data_st_dfs_pep" {
  name                = "PNP-SPOKE-DATA-ST-DFS-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_data_st_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_storage_account.pnp_spoke_data_adls_d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["dfs"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_adls_dfs_dns_zone.id]  # Private DNS Zone ID
  }
}