variable "com_var" {}
variable "resource_group" {}
variable "network" {}

resource "azurerm_databricks_workspace" "d_kr_hub_adb_auth" {
  name                = "pnp-d-kr-hub-adb-auth"
  resource_group_name = var.resource_group.hub_rg.name
  location            = var.com_var.location
  sku                 = "premium" // 또는 다른 SKU

  public_network_access_enabled = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip = true
    virtual_network_id = var.network.hub_vnet.id
    public_subnet_name = "${var.com_var.conf.project_name}-hub-adb-auth-public-subnet"
    private_subnet_name = "${var.com_var.conf.project_name}-hub-adb-auth-private-subnet"
    public_subnet_network_security_group_association_id = var.network.hub_nsg.adb_auth_id
    private_subnet_network_security_group_association_id = var.network.hub_nsg.adb_auth_id
  }

}

resource "azurerm_databricks_workspace" "d_kr_spoke_adb_backend" {
  name                = "pnp-d-kr-spoke-adb-backend"
  resource_group_name = var.resource_group.spoke_rg.name
  location            = var.com_var.location
  sku                 = "premium" // 또는 다른 SKU

  public_network_access_enabled = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip = true
    virtual_network_id = var.network.spoke_vnet.id
    public_subnet_name = "${var.com_var.conf.project_name}-spoke-adb-backend-public-subnet"
    private_subnet_name = "${var.com_var.conf.project_name}-spoke-adb-backend-private-subnet"
    public_subnet_network_security_group_association_id = var.network.spoke_nsg.adb_backend_id
    private_subnet_network_security_group_association_id = var.network.spoke_nsg.adb_backend_id
  }

}

# resource "azurerm_databricks_access_connector" "example" {
#   name                = "pnp-adb-access-connector"
#   resource_group_name = var.resource_group.hub_rg.name
#   location            = var.com_var.location

#   identity {
#     type = "SystemAssigned"
#   }

#   tags = {
#     Environment = "Production"
#   }
# }


# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "hub_adb_dns_zone" {
  name                = "privatelink.azuredatabricks.net"  # Private DNS Zone 이름
  resource_group_name = var.resource_group.hub_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "hub_adb_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.resource_group.hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.hub_adb_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.network.hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "hub_adb_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.resource_group.hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.hub_adb_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.network.spoke_vnet.id # 가상 네트워크 ID
}


# Azure Databricks Frontend Browser Private Endpoint 생성
resource "azurerm_private_endpoint" "hub_adb_auth_browser_pep" {
  name                = "${var.com_var.conf.project_name}-hub-adb-browser-pep"                   # Private Endpoint 이름
  resource_group_name = var.resource_group.hub_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.network.hub_subnet.adb_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-adb-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_databricks_workspace.d_kr_hub_adb_auth.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["browser_authentication"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.hub_adb_dns_zone.id]  # Private DNS Zone ID
  }
}

# Azure Databricks Frontend Browser Private Endpoint 생성
resource "azurerm_private_endpoint" "hub_adb_auth_api_pep" {
  name                = "${var.com_var.conf.project_name}-hub-adb-api-pep"                   # Private Endpoint 이름
  resource_group_name = var.resource_group.hub_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.network.hub_subnet.adb_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "api-adb-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_databricks_workspace.d_kr_hub_adb_auth.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["databricks_ui_api"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.hub_adb_dns_zone.id]  # Private DNS Zone ID
  }
}

# Azure Databricks Backend API Private Endpoint 생성
resource "azurerm_private_endpoint" "spoke_adb_backend_api_pep" {
  name                = "${var.com_var.conf.project_name}-spoke-adb-backend-api-pep"                   # Private Endpoint 이름
  resource_group_name = var.resource_group.spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.network.spoke_subnet.adb_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "api-adb-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_databricks_workspace.d_kr_spoke_adb_backend.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["databricks_ui_api"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.hub_adb_dns_zone.id]  # Private DNS Zone ID
  }
}