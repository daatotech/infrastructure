resource "auth0_organization" "this" {
  display_name = replace(title(var.prefix), "-", " " )
  name         = var.prefix
  branding {
    logo_url = var.logo_url
  }
}
resource "auth0_organization_connection" "this" {
  organization_id            = auth0_organization.this.id
  connection_id              = data.auth0_connection.username_password.id
  assign_membership_on_login = true
}