variable "com_var" {}
variable "conv" {}

resource "azurerm_databricks_workspace" "example" {
  name                = "pnp-adb"
  resource_group_name = var.com_var.spoke_resource_group_name
  location            = var.com_var.location
  sku                 = "premium" // 또는 다른 SKU
}