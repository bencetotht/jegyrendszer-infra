variable "key_secret" {
  type = string
  description = "The secret key for the DNS provider"
  sensitive = true
}

terraform {
  required_providers {
    dns = {
      source = "hashicorp/dns"
      version = "3.3.0"
    }
  }
}

provider "dns" {
  update {
    server = "192.168.88.61"
    key_name = "tsig-key."
    key_algorithm = "hmac-sha256"
    key_secret = var.key_secret
  }
}