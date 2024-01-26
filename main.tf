variable "create_yn" {
  default = {
    resource_group = true
    network = true
    bastion = true
    datalake = true
    function = true
    iothub = true
    synapse = true
    sqldatabase = true
    eventhub = true
  }
}

module "resource_group" {
  source                    = "./modules/resource_group"       # 모듈 소스 경로
  count = var.create_yn.network ? 1 : 0

  com_var = var.com_var
}

module "network" {  
  source                    = "./modules/network"       # 모듈 소스 경로
  count = var.create_yn.network ? 1 : 0

  com_var = var.com_var
  resource_group = module.resource_group[0].resource_group_output

  depends_on = [module.resource_group]
}

module "bastion" {
  source = "./modules/bastion"
  count = var.create_yn.bastion ? 1 : 0

  com_var = var.com_var
  resource_group = module.resource_group[0].resource_group_output
  network = module.network[0].network_output

  depends_on = [module.network]
}

module "datalake" {  
  source                    = "./modules/datalake"       # 모듈 소스 경로
  count = var.create_yn.datalake ? 1 : 0

  com_var = var.com_var
  resource_group = module.resource_group[0].resource_group_output
  network = module.network[0].network_output

  depends_on = [module.network]
}

module "iothub_module" {  
  source                    = "./modules/iothub"       # 모듈 소스 경로
  count = var.create_yn.iothub ? 1 : 0
  
  com_var = var.com_var
  resource_group = module.resource_group[0].resource_group_output
  network = module.network[0].network_output
  azurerm_storage_account = module.datalake[0].azurerm_storage_account
  
  depends_on = [module.network, module.datalake]
}

module "synapse_module" {  
  source                    = "./modules/synapse"       # 모듈 소스 경로
  count = var.create_yn.synapse ? 1 : 0
  
  com_var = var.com_var
  resource_group = module.resource_group[0].resource_group_output
  network = module.network[0].network_output
  
  depends_on = [module.network]
}

module "databricks_module" {  
  source                    = "./modules/databricks"       # 모듈 소스 경로
  count = var.create_yn.synapse ? 1 : 0
  
  com_var = var.com_var
  resource_group = module.resource_group[0].resource_group_output
  network = module.network[0].network_output

  depends_on = [module.network]
}

module "sqldatabase_module" {  
  source                    = "./modules/sqldatabase"       # 모듈 소스 경로
  count = var.create_yn.sqldatabase ? 1 : 0
  
  com_var = var.com_var
  common_tags = local.common_tags
  resource_group = module.resource_group[0].resource_group_output
  network = module.network[0].network_output

  depends_on = [module.network]
}

module "eventhub_module" {  
  source                    = "./modules/eventhub"       # 모듈 소스 경로
  count = var.create_yn.eventhub ? 1 : 0
  
  com_var = var.com_var
  resource_group = module.resource_group[0].resource_group_output
  network = module.network[0].network_output
  common_tags = local.common_tags
  
  depends_on = [module.network]
}

# module "function_module" {  
#   source                    = "./modules/function"       # 모듈 소스 경로
#   count = var.create_yn.function ? 1 : 0

#   com_var = var.com_var
#   conv = var.conv
#   depends_on = [module.network]
# }

# module "iam_module" {  
#   source                    = "./modules/iam"       # 모듈 소스 경로
#   count = var.create_yn.function ? 1 : 0

#   subscription_id = var.subscription_id
# }


