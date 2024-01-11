variable "com_var" {}
variable "conv" {}
variable "hub_vnet_id" {}
variable "pnp_hub_iot_pep_subnet_id" {}
variable "azurerm_storage_account_connection_string" {}
variable "azurerm_storage_account_name" {}
variable "azurerm_storage_account_id" {}

# Azure IoT Hub 리소스 생성
resource "azurerm_iothub" "pnp_data_iot_c01" {
  name                = "${var.conv.project_name}-${var.conv.env}-data-iot-01" # IoT Hub 이름
  resource_group_name = var.com_var.hub_resource_group_name # IoT Hub가 속한 리소스 그룹 이름
  location            = var.com_var.location # IoT Hub 위치

  sku {
    capacity = 1 # 용량 설정
    name     = "S1" # SKU 이름 (S1은 Standard SKU)
  }
  
  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_role_assignment" "example" {  
  scope                = var.azurerm_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_iothub.pnp_data_iot_c01.identity[0].principal_id
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "iothub_private_dns_zone" {
  name                = "privatelink.azure-devices.net"  # Private DNS Zone 이름
  resource_group_name = var.com_var.hub_resource_group_name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "iothub_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.com_var.hub_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.iothub_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.hub_vnet_id # 가상 네트워크 ID
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "iothub_servicebus_private_dns_zone" {
  name                = "privatelink.servicebus.windows.net"  # Private DNS Zone 이름
  resource_group_name = var.com_var.hub_resource_group_name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "iothub_servicebus_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = var.com_var.hub_resource_group_name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.iothub_servicebus_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = var.hub_vnet_id # 가상 네트워크 ID
}

# IoT Hub Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_data_iot_c01_pep" {
  name                = "${var.conv.project_name}-hub-iot-iothub-pep"               # Private Endpoint 이름
  resource_group_name = var.com_var.hub_resource_group_name    # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location                   # Private Endpoint 위치
  subnet_id           = var.pnp_hub_iot_pep_subnet_id          # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_iothub.pnp_data_iot_c01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["iotHub"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.iothub_private_dns_zone.id, azurerm_private_dns_zone.iothub_servicebus_private_dns_zone.id]  # Private DNS Zone ID
  }
}

# Strage Container에 대한 Endpoint 생성
resource "azurerm_iothub_endpoint_storage_container" "storage_container_endpoint" {
  resource_group_name = var.com_var.hub_resource_group_name
  iothub_id           = azurerm_iothub.pnp_data_iot_c01.id
  name                = "stconep"

  container_name    = "iotraw"
  # connection_string = var.azurerm_storage_account_connection_string

  authentication_type = "identityBased"
  endpoint_uri = "https://${var.azurerm_storage_account_name}.blob.core.windows.net/"
  # System 할당 Managed Identity를 사용하려는 경우 identity_id 를 설정하지 않음.

  file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  batch_frequency_in_seconds = 60
  max_chunk_size_in_bytes    = 10485760
  encoding                   = "JSON"
}

resource "azurerm_iothub_route" "example" {
  resource_group_name = var.com_var.hub_resource_group_name
  iothub_name         = azurerm_iothub.pnp_data_iot_c01.name
  name                = "example-route"
  source              = "DeviceMessages"
  condition           = "true"
  endpoint_names      = ["stconep"]
  enabled             = true
}