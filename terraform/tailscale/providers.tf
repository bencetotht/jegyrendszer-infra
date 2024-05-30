terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.16.1"
    }
  }
}

provider "tailscale" {
    api_key = var.TS_API_KEY
    tailnet = var.TS_TAILNET
}

variable "TS_API_KEY" {
    type = string
    description = "Tailscale API key"
    sensitive = true
}

variable "TS_TAILNET" {
  type = string
  description = "Tailscale tailnet value"
  sensitive = true
}