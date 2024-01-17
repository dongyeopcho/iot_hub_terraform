variable "com_var" {}
variable "conv" {}
variable "hub_vnet_id" {}
variable "spoke_vnet_id" {}
variable "pnp_hub_adb_auth_public_nsg_id" {}
variable "pnp_hub_adb_auth_private_nsg_id" {}
variable "pnp_spoke_adb_backend_public_nsg_id" {}
variable "pnp_spoke_adb_backend_private_nsg_id" {}
variable "pnp_hub_adb_pep_subnet_id" {}
variable "pnp_spoke_adb_pep_subnet_id" {}

resource "azurerm_databricks_workspace" "pnp_d_kr_hub_adb_auth" {
  name                = "pnp-d-kr-hub-adb-auth"
  resource_group_name = var.com_var.hub_resource_group_name
  location            = var.com_var.location
  sku                 = "premium" // 또는 다른 SKU

  public_network_access_enabled = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip = true
    virtual_network_id = var.hub_vnet_id
    public_subnet_name = "${var.conv.project_name}-hub-adb-auth-public-subnet"
    private_subnet_name = "${var.conv.project_name}-hub-adb-auth-private-subnet"
    public_subnet_network_security_group_association_id = var.pnp_hub_adb_auth_public_nsg_id
    private_subnet_network_security_group_association_id = var.pnp_hub_adb_auth_private_nsg_id
  }

}

resource "azurerm_databricks_workspace" "pnp_d_kr_spoke_adb_backend" {
  name                = "pnp-d-kr-spoke-adb-backend"
  resource_group_name = var.com_var.spoke_resource_group_name
  location            = var.com_var.location
  sku                 = "premium" // 또는 다른 SKU

  public_network_access_enabled = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip = true
    virtual_network_id = var.spoke_vnet_id
    public_subnet_name = "${var.conv.project_name}-spoke-adb-backend-public-subnet"
    private_subnet_name = "${var.conv.project_name}-spoke-adb-backend-private-subnet"
    public_subnet_network_security_group_association_id = var.pnp_spoke_adb_backend_public_nsg_id
    private_subnet_network_security_group_association_id = var.pnp_spoke_adb_backend_private_nsg_id
  }

}

# resource "azurerm_databricks_access_connector" "example" {
#   name                = "pnp-adb-access-connector"
#   resource_group_name = var.com_var.hub_resource_group_name
#   location            = var.com_var.location

#   identity {
#     type = "SystemAssigned"
#   }

#   tags = {
#     Environment = "Production"
#   }
# }


# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_hub_adb_dns_zone" {
  name                = "privatelink.azuredatabricks.net"  # Private DNS Zone 이름
  resource_group_name = var.com_var.hub_resource_group_name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_hub_adb_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.com_var.hub_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_hub_adb_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.hub_vnet_id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_hub_adb_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = var.com_var.spoke_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_hub_adb_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.spoke_vnet_id # 가상 네트워크 ID
}


# Azure Databricks Frontend Browser Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_hub_adb_auth_browser_pep" {
  name                = "${var.conv.project_name}-spoke-data-st-blob-pep"                   # Private Endpoint 이름
  resource_group_name = var.com_var.hub_resource_group_name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location  # Private Endpoint 위치
  subnet_id           = var.pnp_hub_adb_pep_subnet_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-adb-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_databricks_workspace.pnp_d_kr_hub_adb_auth.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["browser_authentication"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_hub_adb_dns_zone.id]  # Private DNS Zone ID
  }
}
