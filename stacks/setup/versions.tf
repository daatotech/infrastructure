terraform {
  backend "azurerm" {
    resource_group_name  = "daato-tfstate"
    storage_account_name = "daatotfstate"
    container_name       = "instances"
  }
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 0.44.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.13.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.47.0"
    }
  }
}