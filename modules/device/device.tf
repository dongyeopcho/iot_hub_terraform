variable "deviceId" {
  description = "IoT Edge Device Id"
}

variable "iotHubName" {
  description = "IoT Hub Resource Name"
  default = "PNP-DATA-IOT-C01"
}

variable "resource_group_name" {
  description = "Resource Group Name"
  default = "PNP_HUB_RG"
}

resource "azurerm_template_deployment" "example_iot_device" {
  // 'azurerm_template_deployment' 리소스를 정의합니다. 이 리소스는 ARM 템플릿을 배포하는 데 사용됩니다.
  name                = "example-iot-device-deployment"
  // 배포할 리소스의 이름을 지정합니다. 이 이름은 Azure 내에서 해당 템플릿 배포를 식별하는 데 사용됩니다.
  resource_group_name = var.resource_group_name
  // 템플릿이 배포될 리소스 그룹의 이름을 지정합니다. 여기서는 이전에 정의된 'azurerm_resource_group' 리소스의 이름을 사용합니다.

  deployment_mode     = "Incremental"
  // 배포 모드를 지정합니다. 'Incremental' 모드는 기존 리소스를 유지하고, 변경사항만 적용합니다. ('Complete' 모드는 전체 리소스 그룹 내의 모든 리소스를 대체합니다.)

  template_body = <<TEMPLATE
  // ARM 템플릿의 본문을 정의합니다. 여기서는 헤어독(Heredoc) 구문을 사용하여 여러 줄에 걸쳐 JSON 형식의 템플릿을 정의합니다.
  {
    // ARM 템플릿 JSON 내용
    // 이 부분에는 Azure IoT Hub Device를 생성하는 데 필요한 실제 ARM 템플릿의 JSON 내용이 들어갑니다.
  }
  TEMPLATE
  // 헤어독 구문의 끝을 나타냅니다.

  parameters = {
    // 필요한 매개변수
    // ARM 템플릿에 전달할 매개변수를 정의합니다. 이 부분은 템플릿에서 필요로 하는 입력 변수에 따라 달라집니다.
  }
}
