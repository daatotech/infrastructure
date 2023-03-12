locals {
  auth0_config = jsondecode(data.vault_generic_secret.auth0.data_json)
}
//noinspection HILUnresolvedReference
provider "auth0" {
  domain        = local.auth0_config.domain
  client_id     = local.auth0_config.client_id
  client_secret = local.auth0_config.client_secret
}
provider "vault" {
  address = var.vault_address
}
provider "azurerm" {
  alias = "default"
  features {}
}
data "azurerm_subscriptions" "this" {
  provider              = azurerm.default
  display_name_contains = "common"
}
//noinspection HILUnresolvedReference
provider "azurerm" {
  subscription_id = data.azurerm_subscriptions.this.subscriptions[0].subscription_id
  features {}
}