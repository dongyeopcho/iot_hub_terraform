terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# provider "azuread" {
#   tenant_id = "97f42f55-f1db-4804-b1eb-08db083efd4f"
# }