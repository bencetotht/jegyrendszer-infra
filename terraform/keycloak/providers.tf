terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
      version = "5.4.0"
    }
  }
}

variable "keycloak_url" {
  type = string
}

variable "keycloak_client_id" {
  type = string
  sensitive = true
}

variable "keycloak_client_secret" {
  type = string
  sensitive = true
}

provider "keycloak" {
  client_id = var.keycloak_client_id
  client_secret = var.keycloak_client_secret
  url = var.keycloak_url
}