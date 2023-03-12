resource "auth0_role" "contributor" {
  name        = "${var.prefix}-contributor"
  description = replace(title("${var.prefix}-contributor"), "-", " ")
  dynamic "permissions" {
    for_each = toset(local.permissions.contributor)
    content {
      name                       = permissions.value
      resource_server_identifier = auth0_resource_server.this.identifier
    }
  }
}

resource "auth0_role" "isolated_contributor" {
  name        = "${var.prefix}-isolated-contributor"
  description = replace(title("${var.prefix}-isolated-contributor"), "-", " ")
  dynamic "permissions" {
    for_each = toset(local.permissions.isolated_contributor)
    content {
      name                       = permissions.value
      resource_server_identifier = auth0_resource_server.this.identifier
    }
  }
}

resource "auth0_role" "group_manager" {
  name        = "${var.prefix}-group-manager"
  description = replace(title("${var.prefix}-group-manager"), "-", " ")
  dynamic "permissions" {
    for_each = toset(local.permissions.group_manager)
    content {
      name                       = permissions.value
      resource_server_identifier = auth0_resource_server.this.identifier
    }
  }
}

resource "auth0_role" "subsidiary_manager" {
  name        = "${var.prefix}-subsidiary-manager"
  description = replace(title("${var.prefix}-subsidiary-manager"), "-", " ")
  dynamic "permissions" {
    for_each = toset(local.permissions.subsidiary_manager)
    content {
      name                       = permissions.value
      resource_server_identifier = auth0_resource_server.this.identifier
    }
  }
}

resource "auth0_role" "admin" {
  name        = "${var.prefix}-admin"
  description = replace(title("${var.prefix}-admin"), "-", " ")
  dynamic "permissions" {
    for_each = toset(local.permissions.admin)
    content {
      name                       = permissions.value
      resource_server_identifier = auth0_resource_server.this.identifier
    }
  }
}