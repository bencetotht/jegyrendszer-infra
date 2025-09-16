terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2025.8.1"
    }
  }
}

variable "authentik_url" {
  type = string
  description = "The URL of the Authentik instance"
  default = "https://auth.bnbdevelopment.hu"
}

variable "authentik_token" {
  type = string
  description = "The token of the Authentik instance"
  sensitive = true
}

provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
  # Optionally set insecure to ignore TLS Certificates
  # insecure = true
  # Optionally add extra headers
  # headers {
  #   X-my-header = "foo"
  # }
}