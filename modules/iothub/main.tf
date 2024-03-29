variable "com_var" {}

variable "resource_group" {}
variable "network" {}
variable "azurerm_storage_account" {}

# variable "hub_vnet_id" {}
# variable "hub_iot_pep_subnet_id" {}
# variable "azurerm_storage_account_connection_string" {}
# variable "azurerm_storage_account_name" {}
# variable "azurerm_storage_account_id" {}

# Azure IoT Hub 리소스 생성
resource "azurerm_iothub" "data_iot_c01" {
  name                = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-data-iot-01" # IoT Hub 이름
  resource_group_name = var.resource_group.hub_rg.name # IoT Hub가 속한 리소스 그룹 이름
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
  scope                = var.azurerm_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_iothub.data_iot_c01.identity[0].principal_id
}


# IoT Hub Private Endpoint 생성
resource "azurerm_private_endpoint" "data_iot_c01_pep" {
  name                = "${var.com_var.conf.project_name}-hub-iot-iothub-pep" # Private Endpoint 이름
  resource_group_name = var.resource_group.hub_rg.name # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.com_var.location # Private Endpoint 위치
  subnet_id           = var.network.hub_subnet.iot_id # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection" # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_iothub.data_iot_c01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false # 수동 연결 여부
    subresource_names = ["iotHub"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [var.network.private_dns.iothub.id, var.network.private_dns.servicebus.id]  # Private DNS Zone ID
  }
}

# Strage Container에 대한 Endpoint 생성
resource "azurerm_iothub_endpoint_storage_container" "storage_container_endpoint" {
  resource_group_name = var.resource_group.hub_rg.name
  iothub_id           = azurerm_iothub.data_iot_c01.id
  name                = "stconep"

  container_name    = "iotraw"
  # connection_string = var.azurerm_storage_account_connection_string

  authentication_type = "identityBased"
  endpoint_uri = "https://${var.azurerm_storage_account.name}.blob.core.windows.net/"
  # System 할당 Managed Identity를 사용하려는 경우 identity_id 를 설정하지 않음.

  file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  batch_frequency_in_seconds = 60
  max_chunk_size_in_bytes    = 10485760
  encoding                   = "JSON"
}

resource "azurerm_iothub_route" "example" {
  resource_group_name = var.resource_group.hub_rg.name
  iothub_name         = azurerm_iothub.data_iot_c01.name
  name                = "example-route"
  source              = "DeviceMessages"
  condition           = "true"
  endpoint_names      = ["stconep"]
  enabled             = true
}