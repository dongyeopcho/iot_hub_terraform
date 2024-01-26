variable "com_var" {}
variable "network" {}
variable "resource_group" {}
variable "common_tags" {}

# Event Hubs Namespace 생성
resource "azurerm_eventhub_namespace" "spoke_eventhub_namespace" {
  name                = "${var.com_var.conf.project_name}-${var.com_var.conf.env}-${var.com_var.conf.location_name}-evhub"
  resource_group_name = var.resource_group.spoke_rg.name
  location            = var.com_var.location
  sku                 = "Standard"
}

# Event Hub 생성
resource "azurerm_eventhub" "spoke_eventhub" {
  name                = "${azurerm_eventhub_namespace.spoke_eventhub_namespace.name}"
  namespace_name      = azurerm_eventhub_namespace.spoke_eventhub_namespace.name
  resource_group_name = var.resource_group.spoke_rg.name
  partition_count     = 2
  message_retention   = 1
}

