locals {
  backend_payload = {
    name          = "${local.identifier}-api"
    url           = "https://api.${local.subdomain}.${local.aws_zone}"
    auth0ClientId = module.auth0.clients.core.client_id
  }
  client_payload = {
    name           = "${local.identifier}-api"
    organizationId = module.auth0.organization_id
    backend        = "${local.identifier}-api"
    props          = [
      {
        key   = "vat"
        value = "N/A"
      }
    ]
  }
}
data "http" "core_token" {
  method          = "POST"
  //noinspection HILUnresolvedReference
  url             = "https://${local.auth0_config.domain}/oauth/token"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    grant_type    = "client_credentials"
    client_id     = module.auth0.clients.core.client_id
    client_secret = module.auth0.clients.core.client_secret
    audience      = module.auth0.resource_servers.core
  })
}
locals {
  core_token = jsondecode(data.http.core_token.response_body).access_token
}
data "http" "register_backend" {
  request_headers = {
    Authorization  = "Bearer ${local.core_token}"
    "Content-Type" = "application/json"
  }
  request_body = jsonencode(local.backend_payload)
  method       = "POST"
  url          = "${local.core_api_url}/v1/backend"
}
data "http" "register_client" {
  depends_on      = [data.http.register_backend]
  request_headers = {
    Authorization  = "Bearer ${local.core_token}"
    "Content-Type" = "application/json"
  }
  request_body = jsonencode(local.client_payload)
  method       = "POST"
  url          = "${local.core_api_url}/v1/client"
}

output "register_client" {
  value = {
    payload  = jsondecode(data.http.register_client.request_body)
    response = jsondecode(data.http.register_client.response_body)
  }
}
output "register_backend" {
  value = {
    payload  = jsondecode(data.http.register_backend.request_body)
    response = jsondecode(data.http.register_backend.response_body)
  }
}
output "payload" {
  value = {
    backend = local.backend_payload
    client  = local.client_payload
    token   = local.core_token
  }
}