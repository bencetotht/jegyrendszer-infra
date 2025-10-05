terraform {
  required_providers {
    routeros = {
      source = "terraform-routeros/routeros"
    }
  }
}

provider "routeros" {
  hosturl = var.routeros_hosturl
  username = var.routeros_username
  password = var.routeros_password
  insecure = true
}

variable "routeros_hosturl" {
  type = string
  description = "The host of the RouterOS"
  default = "http://192.168.88.1"
}

variable "routeros_username" {
  type = string
  description = "The username of the RouterOS"
  default = "admin"
}

variable "routeros_password" {
  type = string
  description = "The password of the RouterOS"
  sensitive = true
}