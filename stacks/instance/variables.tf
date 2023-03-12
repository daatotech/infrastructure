variable "instance_identifier" {
  type = string
}
variable "aws_profile" {
  type    = string
  default = "default"
}
variable "vault_address" {
  type    = string
  default = "https://vault-public-vault-667e5c79.bd5844f2.z1.hashicorp.cloud:8200"
}
variable "aws_region" {
  type    = string
  default = "eu-central-1"
}
variable "api_port" {
  type    = number
  default = 80
}
variable "frontend_port" {
  type    = number
  default = 80
}