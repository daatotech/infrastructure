resource "vault_generic_secret" "auth0" {
  data_json = jsonencode(var.auth0)
  path      = "secret/global/auth0"
}
resource "vault_generic_secret" "acr" {
  data_json = jsonencode(var.acr)
  path      = "secret/global/acr"
}
resource "vault_generic_secret" "api_keys" {
  data_json = jsonencode(var.api_keys)
  path      = "secret/global/api-keys"
}