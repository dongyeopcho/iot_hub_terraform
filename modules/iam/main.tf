variable "subscription_id" {}

resource "azurerm_role_definition" "test_role" {
  name        = "Test_Role" # Custom Role 이름 설정
  description = "Custom role description" # Custom role에 대한 설명 설정
  scope       = "/subscriptions/${var.subscription_id}" # Custom role이 적용되는 범위 설정
  
  # permissions 블록 시작 - Custom Role의 권한 설정  
  permissions { 
    actions = [
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
      "Microsoft.Storage/storageAccounts/listKeys/action"
    ]
  }
  # permission 블록 종료

  # assignable_scopes 속성 설정 - Custom role이 할당 가능한 범위 설정
  assignable_scopes = [
    "/subscriptions/${var.subscription_id}"
  ]
}