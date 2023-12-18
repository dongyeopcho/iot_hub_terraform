module "infra_module" {  
  source                    = "./modules/infra"       # 모듈 소스 경로
  resource_group_location   = "Korea Central"         # 모듈에 전달할 리소스 그룹 location
  count = var.create_infra_module ? 1 : 0
}

module "device_module" {
  source                    = "./modules/device"      # 모듈 소스 경로
  deviceId                  = "Device01"              # 모듈에 전달할 리소스 그룹 location
  count = var.create_device_module ? 1 : 0
}

variable "create_device_module" {
  default = false
}

variable "create_infra_module" {
  default = false
}