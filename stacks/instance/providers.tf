provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
provider "vault" {
  address = var.vault_address
}