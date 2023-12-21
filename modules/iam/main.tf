variable "subscription_id" {}

resource "azurerm_role_definition" "test_role" {
  name        = "Test_Role"
  description = "Custom role description"
  scope       = "/subscriptions/${var.subscription_id}"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
      "Microsoft.Storage/storageAccounts/listKeys/action"
      # Add other necessary actions here
    ]
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}"
  ]
}