variable "deviceId" {
  description = "Input IoT Edge Device Id"
}

resource "azurerm_iothub_device" "device" {
  device_id           = "example-device"
  iothub_name         = azurerm_iothub.example.name
  resource_group_name = azurerm_resource_group.example.name
  authentication_type = "sas"
  type                = "Edge"
}