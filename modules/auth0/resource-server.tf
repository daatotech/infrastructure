resource "auth0_resource_server" "this" {
  name                                            = "${var.prefix}-api"
  identifier                                      = "https://${var.api_host}"
  signing_alg                                     = "RS256"
  allow_offline_access                            = false
  token_lifetime                                  = 86400
  skip_consent_for_verifiable_first_party_clients = true
  enforce_policies                                = true
  dynamic "scopes" {
    for_each = toset(local.permissions.scopes)
    content {
      value       = scopes.value
      description = scopes.value
    }
  }
  token_dialect          = "access_token_authz"
  token_lifetime_for_web = 7200
}