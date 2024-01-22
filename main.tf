variable "create_yn" {
  default = {
    resource_group = true
    network = true
    bastion = true
    datalake = true
    function = true
    iothub = true
    synapse = true
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
  conv = var.conv
  depends_on = [module.resource_group]
}

module "bastion" {
  source = "./modules/bastion"
  count = var.create_yn.bastion ? 1 : 0

  bastion_subnet_id = module.network[0].pnp_hub_bastion_pep_subnet_id
  com_var = var.com_var
  conv = var.conv

  depends_on = [module.network]
}

module "datalake" {  
  source                    = "./modules/datalake"       # 모듈 소스 경로
  count = var.create_yn.datalake ? 1 : 0

  com_var = var.com_var
  conv = var.conv
  hub_vnet_id = module.network[0].hub_vnet_id
  spoke_vnet_id = module.network[0].spoke_vnet_id
  pnp_spoke_data_st_pep_subnet_id = module.network[0].pnp_spoke_data_st_pep_subnet_id

  depends_on = [module.network]
}

module "iothub_module" {  
  source                    = "./modules/iothub"       # 모듈 소스 경로
  count = var.create_yn.iothub ? 1 : 0
  
  com_var = var.com_var
  conv = var.conv
  hub_vnet_id = module.network[0].hub_vnet_id
  pnp_hub_iot_pep_subnet_id = module.network[0].pnp_hub_iot_pep_subnet_id
  azurerm_storage_account_connection_string = module.datalake[0].azurerm_storage_account_connection_string
  azurerm_storage_account_name = module.datalake[0].azurerm_storage_account_name
  azurerm_storage_account_id = module.datalake[0].azurerm_storage_account_id

  depends_on = [module.network, module.datalake]
}

module "synapse_module" {  
  source                    = "./modules/synapse"       # 모듈 소스 경로
  count = var.create_yn.synapse ? 1 : 0
  
  hub_vnet_id = module.network[0].hub_vnet_id
  spoke_vnet_id = module.network[0].spoke_vnet_id
  com_var = var.com_var
  conv = var.conv
  pnp_spoke_syn_pep_subnet_id = module.network[0].pnp_spoke_syn_pep_subnet_id
  pnp_hub_plh_pep_subnet_id = module.network[0].pnp_hub_plh_pep_subnet_id
  
  depends_on = [module.network]
}

module "databricks_module" {  
  source                    = "./modules/databricks"       # 모듈 소스 경로
  count = var.create_yn.synapse ? 1 : 0
  
  com_var = var.com_var
  conv = var.conv
  hub_vnet_id = module.network[0].hub_vnet_id
  spoke_vnet_id = module.network[0].spoke_vnet_id
  pnp_hub_adb_auth_nsg_id = module.network[0].pnp_hub_adb_auth_nsg_id
  pnp_spoke_adb_backend_nsg_id = module.network[0].pnp_spoke_adb_backend_nsg_id
  pnp_hub_adb_pep_subnet_id = module.network[0].pnp_hub_adb_pep_subnet_id
  pnp_spoke_adb_pep_subnet_id = module.network[0].pnp_spoke_adb_pep_subnet_id
  
  depends_on = [module.network]
}

module "function_module" {  
  source                    = "./modules/function"       # 모듈 소스 경로
  count = var.create_yn.function ? 1 : 0

  com_var = var.com_var
  conv = var.conv
  depends_on = [module.network]
}

module "iam_module" {  
  source                    = "./modules/iam"       # 모듈 소스 경로
  count = var.create_yn.function ? 1 : 0

  subscription_id = var.subscription_id
}


