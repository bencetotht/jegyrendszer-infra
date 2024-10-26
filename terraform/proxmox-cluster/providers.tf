terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://100.93.205.85:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = "password"
  pm_tls_insecure = true
}
