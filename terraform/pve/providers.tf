terraform {
    required_version = ">= 1.0.0"
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "3.0.2-rc04"
        }
    }
}

variable "proxmox_api_url" {
    type = string
    description = "The URL of the Proxmox API"
    default = "https://192.168.1.100:8006/api2/json"
}

variable "proxmox_api_token_id" {
    type = string
    description = "The ID of the Proxmox API token"
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type = string
    description = "The secret of the Proxmox API token"
    sensitive = true
}

provider "proxmox" {
    pm_api_url = var.proxmox_api_url
    pm_api_token_id = var.proxmox_api_token_id
    pm_api_token_secret = var.proxmox_api_token_secret

    pm_tls_insecure = true // only set for self-signed certificates
}

variable "pve_nodes" {
    type = list(object({
        name = string
        template_id = string
        storage_pool = string
        iso_storage_pool = string
        network_interface = string
    }))
    default = [
        {
            name = "proxmox"
            template_id = "talos-template"
            storage_pool = "fast2"
            iso_storage_pool = "local"
            network_interface = "vmbr0"
        },
        {
            name = "pve2"
            template_id = "talos-template" 
            storage_pool = "tb2"
            iso_storage_pool = "local"
            network_interface = "vmbr0"
        },
        {
            name = "pve3"
            template_id = "talos-template"
            storage_pool = "fast3"
            iso_storage_pool = "local"
            network_interface = "vmbr1"
        }
    ]
}