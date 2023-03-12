resource "aws_secretsmanager_secret" "azure_registry" {
  name = "daato-acr-credentials"
}
//noinspection HILUnresolvedReference
resource "aws_secretsmanager_secret_version" "azure_registry" {
  secret_id     = aws_secretsmanager_secret.azure_registry.id
  secret_string = jsonencode({
    username = local.acr_credentials.username
    password = local.acr_credentials.password
  })
}