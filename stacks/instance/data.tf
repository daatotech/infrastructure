data "vault_generic_secret" "acr" {
  path = "secret/global/acr"
}
data "vault_generic_secret" "api_keys" {
  path = "secret/global/api-keys"
}
data "vault_generic_secret" "blob_storage" {
  path = "secret/instances/${local.identifier}/blob-storage"
}
data "vault_generic_secret" "auth0" {
  path = "secret/instances/${local.identifier}/auth0"
}
data "vault_generic_secret" "instance_config" {
  path = "secret/instances/${var.instance_identifier}/config"
}
//noinspection HILUnresolvedReference
locals {
  instance_config                    = jsondecode(data.vault_generic_secret.instance_config.data_json)
  acr_credentials                    = jsondecode(data.vault_generic_secret.acr.data_json)
  api_keys                           = jsondecode(data.vault_generic_secret.api_keys.data_json)
  blob_storage                       = jsondecode(data.vault_generic_secret.blob_storage.data_json)
  auth0                              = jsondecode(data.vault_generic_secret.auth0.data_json)
  identifier                         = local.instance_config.identifier
  subdomain                          = local.instance_config.subdomain
  aws_zone                           = local.instance_config.domain
  logo_url                           = local.instance_config.logo_url
  core_api_identifier                = local.instance_config.core_api_identifier
  core_api_url                       = local.instance_config.core_api_url
  sendgrid_token                     = local.api_keys.sendgrid_token
  public_container_connection_string = local.blob_storage.connection_string
  api_image                          = "daato.azurecr.io/api"
  frontend_image                     = "daato.azurecr.io/frontend"
  api_env                            = {
    DB_URL                             = "mongodb://daato:${random_password.db.result}@${aws_docdb_cluster.this.endpoint}:27017?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
    JWT_AUDIENCE                       = local.auth0.resource_servers.api
    AUTH0_DOMAIN                       = local.auth0.domain
    AUTH0_MANAGEMENT_CLIENT_ID         = local.auth0.clients.management.client_id
    AUTH0_MANAGEMENT_CLIENT_SECRET     = local.auth0.clients.management.client_secret
    AUTH0_ORGANIZATION_ID              = local.auth0.organization_id
    AUTH0_CONTRIBUTOR_ROLE_ID          = local.auth0.roles.contributor
    AUTH0_ISOLATED_CONTRIBUTOR_ROLE_ID = local.auth0.roles.isolated_contributor
    AUTH0_GROUP_MANAGER_ROLE_ID        = local.auth0.roles.group_manager
    AUTH0_SUBSIDIARY_MANAGER_ROLE_ID   = local.auth0.roles.subsidiary_manager
    AUTH0_ADMIN_ROLE_ID                = local.auth0.roles.admin
    AUTH0_CLIENT_ID                    = local.auth0.clients.main.client_id
    CORE_AUTH0_M2M_CLIENT_ID           = local.auth0.clients.core.client_id
    CORE_AUTH0_M2M_CLIENT_SECRET       = local.auth0.clients.core.client_secret
    CORE_AUTH0_M2M_AUDIENCE            = local.auth0.resource_servers.core
    FRONTEND_URL                       = "https://${local.subdomain}.${local.aws_zone}"
    PUBLIC_CONTAINER_CONNECTION_STRING = local.public_container_connection_string
    SENDGRID_TOKEN                     = local.sendgrid_token
    SINGLE_ORG                         = "true"
    CORE_URL                           = local.core_api_url
    FRONTEND_DOMAIN                    = local.aws_zone
    PORT                               = tostring(var.api_port)
    ENABLE_LOGS                        = "true"
    ENABLE_MAIL_ON_ERROR               = "true"
    FEATURE_FLAG_FRAMEWORKS            = "1"
    NO_COLOR                           = "1"
    SERVER_ERROR_EMAIL_SENDER          = "serverlogs@daato.io"
    SERVER_ERROR_EMAILS                = "sreeganesh@daato.net mariusz.wozniak@codete.com maciej.chamera@codete.com emil.tomczuk@daato.net ilham.muhammad@daato.net giulia.fumagalli@daato.net alina.buzhynskaya@codete.com"
  }
}