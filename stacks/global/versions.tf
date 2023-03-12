terraform {
  backend "azurerm" {
    resource_group_name  = "daato-tfstate"
    storage_account_name = "daatotfstate"
    container_name       = "instances"
    key                  = "global-secrets.tfstate"
  }
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}