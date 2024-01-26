variable "com_var" {}
variable "network" {}
variable "resource_group" {}
variable "common_tags" {}

resource "azurerm_mssql_server" "sql-server-mdm" {
  name                         = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-${var.com_var.conf.location_name}-sql-server-mdm"
  resource_group_name          = var.resource_group.spoke_rg.name
  location                     = var.com_var.location
  version                      = "12.0"   # SQL Server 버전
  administrator_login          = "sqladmin"
  administrator_login_password = "aprkwhs123!@#"

}

resource "azurerm_mssql_database" "sql-database-mdm" {
  name                = "mdm"
  server_id         = azurerm_mssql_server.sql-server-mdm.id
}

# IoT Hub Private Endpoint 생성
resource "azurerm_private_endpoint" "data_sql_pep" {
  name                = "${var.com_var.conf.project_name}-spoke-sql-pep" # Private Endpoint 이름
  resource_group_name = var.resource_group.spoke_rg.name # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location # Private Endpoint 위치
  subnet_id           = var.network.spoke_subnet.sql_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-sqlserver-pe-connection" # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_mssql_server.sql-server-mdm.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false # 수동 연결 여부
    subresource_names = ["SqlServer"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [var.network.private_dns.sql.id]  # Private DNS Zone ID
  }
}
