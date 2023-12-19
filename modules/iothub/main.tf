# # Azure IoT Hub 리소스 생성
# resource "azurerm_iothub" "pnp_data_iot_c01" {
#   name                = "PNP-DATA-IOT-C01" # IoT Hub 이름
#   resource_group_name = azurerm_resource_group.pnp_hub_rg.name # IoT Hub가 속한 리소스 그룹 이름
#   location            = var.resource_group_location # IoT Hub 위치

#   sku {
#     capacity = 1 # 용량 설정
#     name     = "S1" # SKU 이름 (S1은 Standard SKU)
#   }
# }

# # Private DNS Zone 정의
# resource "azurerm_private_dns_zone" "iothub_private_dns_zone" {
#   name                = "privatelink.azure-devices.net"  # Private DNS Zone 이름
#   resource_group_name = azurerm_resource_group.pnp_hub_rg.name  # 리소스 그룹 이름
# }

# # Private DNS Zone과 가상 네트워크 링크 설정
# resource "azurerm_private_dns_zone_virtual_network_link" "iothub_private_dns_zone_link_hub" {
#   name                  = "link_hub"                        # 링크 이름
#   resource_group_name   = azurerm_resource_group.pnp_hub_rg.name   # 리소스 그룹 이름
#   private_dns_zone_name = azurerm_private_dns_zone.iothub_private_dns_zone.name  # Private DNS Zone 이름
#   virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
# }

# # Private DNS Zone 정의
# resource "azurerm_private_dns_zone" "iothub_servicebus_private_dns_zone" {
#   name                = "privatelink.servicebus.windows.net"  # Private DNS Zone 이름
#   resource_group_name = azurerm_resource_group.pnp_hub_rg.name  # 리소스 그룹 이름
# }

# # Private DNS Zone과 가상 네트워크 링크 설정
# resource "azurerm_private_dns_zone_virtual_network_link" "iothub_servicebus_private_dns_zone_link_hub" {
#   name                  = "link_hub"                        # 링크 이름
#   resource_group_name   = azurerm_resource_group.pnp_hub_rg.name   # 리소스 그룹 이름
#   private_dns_zone_name = azurerm_private_dns_zone.iothub_servicebus_private_dns_zone.name  # Private DNS Zone 이름
#   virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
# }

# # IoT Hub Private Endpoint 생성
# resource "azurerm_private_endpoint" "pnp_data_iot_c01_pep" {
#   name                = "PNP-HUB-IOT-IOTHUB-PEP"                   # Private Endpoint 이름
#   resource_group_name = azurerm_resource_group.pnp_hub_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
#   location            = var.resource_group_location  # Private Endpoint 위치
#   subnet_id           = azurerm_subnet.pnp_hub_iot_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

#   # 연결된 서비스 구성
#   private_service_connection {
#     name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
#     private_connection_resource_id = azurerm_iothub.pnp_data_iot_c01.id # Private Endpoint 연결 리소스 ID
#     is_manual_connection           = false                          # 수동 연결 여부
#     subresource_names = ["iotHub"] # Private Endpoint 하위 리소스 
#   }

#   private_dns_zone_group {
#     name                           = "default"  # Private DNS Zone 연결 이름
#     private_dns_zone_ids            = [azurerm_private_dns_zone.iothub_private_dns_zone.id, azurerm_private_dns_zone.iothub_servicebus_private_dns_zone.id]  # Private DNS Zone ID
#   }
# }