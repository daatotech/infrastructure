output "clients" {
  value = {
    management = {
      client_id     = auth0_client.management.client_id
      client_secret = auth0_client.management.client_secret
    }
    api = {
      client_id     = auth0_client.api.client_id
      client_secret = auth0_client.api.client_secret
    }
    main = {
      client_id = auth0_client.main.client_id
    }
    core = {
      client_id     = auth0_client.core.client_id
      client_secret = auth0_client.core.client_secret
    }
  }
}
output "roles" {
  value = {
    contributor          = auth0_role.contributor.id
    isolated_contributor = auth0_role.isolated_contributor.id
    group_manager        = auth0_role.group_manager.id
    subsidiary_manager   = auth0_role.subsidiary_manager.id
    admin                = auth0_role.admin.id
  }
}
output "resource_servers" {
  value = {
    core = data.auth0_resource_server.core.identifier
    api  = auth0_resource_server.this.identifier
  }
}
output "organization_id" {
  value = auth0_organization.this.id
}