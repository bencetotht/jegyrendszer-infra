variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type      = string
    sensitive = true
}

locals {
    disk_storage = "local-lvm"
}

source "proxmox-iso" "ubuntu-server-noble-min" {
    proxmox_url = var.proxmox_api_url
    username = var.proxmox_api_token_id
    token = var.proxmox_api_token_secret
    
    node = "pve"
    storage = local.disk_storage
    iso_file = "local:iso/ubuntu-22.04-server-amd64.iso"
}