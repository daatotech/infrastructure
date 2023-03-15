data "vault_generic_secret" "auth0" {
  path = "secret/global/auth0"
}
//noinspection HILUnresolvedReference
locals {
  instance_config     = jsondecode(file("${path.root}/../../instances/${var.instance_identifier}.json"))
  identifier          = local.instance_config.identifier
  aws_zone            = local.instance_config.domain
  logo_url            = local.instance_config.logo_url
  core_api_identifier = local.instance_config.core_api_identifier
  core_api_url        = local.instance_config.core_api_url
}