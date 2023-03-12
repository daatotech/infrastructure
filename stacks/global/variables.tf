variable "vault_address" {
  type    = string
  default = "https://vault-public-vault-667e5c79.bd5844f2.z1.hashicorp.cloud:8200"
}

variable "auth0" {
  type = object({
    domain        = string
    client_id     = string
    client_secret = string
  })
}

variable "acr" {
  type = object({
    username = string
    password = string
  })
}
variable "api_keys" {
  type = object({
    sendgrid_token        = string
    google_places_api_key = string
  })
}