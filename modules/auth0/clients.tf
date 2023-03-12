resource "auth0_client" "management" {
  name                                = "${var.prefix}-management"
  description                         = "${var.prefix}-management (managed by terraform)"
  app_type                            = "non_interactive"
  cross_origin_auth                   = false
  custom_login_page_on                = true
  grant_types                         = ["client_credentials"]
  is_first_party                      = true
  is_token_endpoint_ip_header_trusted = false
  oidc_conformant                     = true
  sso_disabled                        = false
  token_endpoint_auth_method          = "client_secret_post"
  jwt_configuration {
    alg = "RS256"
  }
}
resource "auth0_client" "core" {
  name                                = "${var.prefix}-core"
  description                         = "${var.prefix}-core (managed by terraform)"
  app_type                            = "non_interactive"
  cross_origin_auth                   = false
  custom_login_page_on                = true
  grant_types                         = ["client_credentials"]
  is_first_party                      = true
  is_token_endpoint_ip_header_trusted = false
  oidc_conformant                     = true
  sso_disabled                        = false
  token_endpoint_auth_method          = "client_secret_post"
  jwt_configuration {
    alg = "RS256"
  }
}
resource "auth0_client" "api" {
  name                                = "${var.prefix}-api"
  description                         = "${var.prefix}-api (managed by terraform)"
  app_type                            = "non_interactive"
  cross_origin_auth                   = false
  custom_login_page_on                = true
  grant_types                         = ["client_credentials"]
  is_first_party                      = true
  is_token_endpoint_ip_header_trusted = false
  oidc_conformant                     = true
  sso_disabled                        = false
  token_endpoint_auth_method          = "client_secret_post"
  jwt_configuration {
    alg = "RS256"
  }
}
resource "auth0_client" "main" {
  name                                = var.prefix
  description                         = "${var.prefix} (managed by terraform)"
  app_type                            = "spa"
  allowed_logout_urls                 = ["https://${var.ui_host}"]
  allowed_origins                     = ["https://${var.ui_host}"]
  web_origins                         = ["https://${var.ui_host}"]
  callbacks                           = ["https://${var.ui_host}"]
  grant_types                         = ["authorization_code", "implicit", "refresh_token"]
  cross_origin_auth                   = true
  custom_login_page_on                = true
  initiate_login_uri                  = "https://${var.ui_host}/login"
  is_first_party                      = true
  is_token_endpoint_ip_header_trusted = false
  oidc_conformant                     = true
  organization_require_behavior       = "no_prompt"
  organization_usage                  = "require"
  sso_disabled                        = false
  token_endpoint_auth_method          = "none"
  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_client_grant" "this" {
  audience  = auth0_resource_server.this.identifier
  client_id = auth0_client.management.client_id
  scope     = []
}
resource "auth0_client_grant" "api" {
  audience  = auth0_resource_server.this.identifier
  client_id = auth0_client.api.client_id
  scope     = ["create:organization", "list:organizations"]
}
resource "auth0_client_grant" "management" {
  audience  = "https://daato.eu.auth0.com/api/v2/"
  client_id = auth0_client.management.client_id
  scope     = local.permissions.management
}
resource "auth0_client_grant" "core" {
  audience  = data.auth0_resource_server.core.identifier
  client_id = auth0_client.core.client_id
  scope     = ["core:m2m", "core:backend:add", "core:backend:read:all"]
}