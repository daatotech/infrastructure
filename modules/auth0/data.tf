data "auth0_resource_server" "core" {
  identifier = var.core_api_identifier
}
data "auth0_connection" "username_password" {
  name = "Username-Password-Authentication"
}