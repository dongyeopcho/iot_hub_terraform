# Azure Function Apps 용도의 Storage Account 생성
resource "azurerm_storage_account" "pnp_hub_func_adls_d01" {
  name                     = "pnphubfuncadlsc01"  # Storage Account 이름
  resource_group_name      = azurerm_resource_group.pnp_hub_rg.name  # 리소스 그룹 이름
  location                 = var.resource_group_location  # 리소스 그룹 위치
  account_tier             = "Premium"  # 프리미엄 계층
  account_replication_type = "LRS"  # 로컬 복제  
  account_kind             = "BlockBlobStorage"
  is_hns_enabled = true # account_tier 가 Standard 또는 Premium이며, account_kind가 BlockBlobStorage일 때만 사용 가능

  network_rules { # Blob 서비스에 대한 CORS (Cross-Origin Resource Sharing) 규칙을 구성합니다.
    default_action = "Allow"  # 기본 동작 (Deny)
  }
}

# Application Insights 리소스 정의
resource "azurerm_application_insights" "pnp_hub_app_insight_c01" {
  name                = "PNP-HUB-APP-INSIGHT-C01"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name
  application_type    = "web"
}

# App Service Plan
resource "azurerm_service_plan" "pnp-hub-app-plan" {
  name                = "pnp-hub-app-plan"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name
  os_type             = "Linux"
  sku_name            = "S1"
}

# Azure Function App 정의
resource "azurerm_linux_function_app" "pnp_hub_function_app" {
  name                = "pnp-hub-device-to-cloud-func"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name
  service_plan_id     = azurerm_service_plan.pnp-hub-app-plan.id
  storage_account_name       = azurerm_storage_account.pnp_hub_func_adls_d01.name
  storage_account_access_key  = azurerm_storage_account.pnp_hub_func_adls_d01.primary_access_key

  # Function App의 구성 설정
  site_config {
    application_stack {
      python_version = "3.11"
    }
    # CORS 설정 추가
    cors {
      allowed_origins = [
        "https://portal.azure.com"
      ]
    }
  }
  
  # Function App의 환경 변수 및 설정
  app_settings = {
    # "FUNCTIONS_WORKER_RUNTIME"      = "python"
    # "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.pnp_hub_app_insight_c01.instrumentation_key
    # SCM_DO_BUILD_DURING_DEPLOYMENT  = true
  }
}
