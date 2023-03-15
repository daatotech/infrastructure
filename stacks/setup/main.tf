module "auth0" {
  source              = "../../modules/auth0"
  api_host            = "api.${local.aws_zone}"
  core_api_identifier = local.core_api_identifier
  logo_url            = local.logo_url
  prefix              = local.identifier
  ui_host             = local.aws_zone
}
resource "vault_generic_secret" "config" {
  data_json = jsonencode(local.instance_config)
  path      = "secret/instances/${local.identifier}/config"
}
//noinspection HILUnresolvedReference
resource "vault_generic_secret" "auth0" {
  data_json = jsonencode(merge(module.auth0, { domain = local.auth0_config.domain }))
  path      = "secret/instances/${local.identifier}/auth0"
}
resource "azurerm_resource_group" "this" {
  location = var.az_location
  name     = local.identifier
}
resource "azurerm_storage_account" "this" {
  account_replication_type = "GRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = replace(local.identifier, "-", "" )
  resource_group_name      = azurerm_resource_group.this.name
}
resource "vault_generic_secret" "public_container_connection_string" {
  data_json = jsonencode({
    connection_string = azurerm_storage_account.this.primary_connection_string
  })
  path = "secret/instances/${local.identifier}/blob-storage"
}