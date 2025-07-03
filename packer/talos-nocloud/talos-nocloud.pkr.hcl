packer {
    required_plugins {
        proxmox = {
            version = ">= 1.1.0"
            source = "github.com/hashicorp/proxmox"
        }
    }
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "iso_file" {
  type    = string
  description = "Path to the Talos ISO file on the Proxmox storage"
  default     = "local:iso/talos-amd64.iso"
}

variable "iso_storage" {
  type    = string
  default = "local-lvm"
}

variable "cloud_init_storage" {
  type    = string
  default = "local-lvm"
}

variable "target_node" {
  type    = string
  default = "proxmox-node1"
}

source "proxmox" "talos-template" {
    # Proxmox configuration
    proxmox_url = var.proxmox_api_url
    username = var.proxmox_api_token_id
    token = var.proxmox_api_token_secret

    # Node configuration
    node = var.target_node
    insecure_skip_tls_verify = true
    storage = var.iso_storage
    
    iso_file = var.iso_file

    # VM configuration
    vm_id = 9000
    vm_name = "talos-template"

    # Hardware configuration
    cores = 2
    memory = 2048
    disks {
        type = "scsi"
        storage_pool = var.iso_storage
        storage_pool_type = "lvm"
        format = "raw"
        disk_size = "10G"
        cache_mode = "writethrough"
    }
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Cloud-init configuration
    cloud_init = true
    cloud_init_storage = var.cloud_init_storage

    ssh_username = "root"
    ssh_password = "talos"
    ssh_timeout = "10s"
    ipconfig0 = "ip=192.168.88.210/24,gw=192.168.88.1"
    user_data = templatefile("cloud-init/user-data.yaml", {
        talosconfig = base64encode(file("cloud-init/talosconfig"))
    })
    meta_data = templatefile("cloud-init/meta-data.yaml", {
        hostname = "talos-template"
    })

    # QEMU configuration
    os = "l26"
    bios = "ovmf"
    qemu_agent = true
    boot = "order=c;scsi0"

    # Template configuration
    template = true
    template_name = "talos-template"
    template_description = "Talos template"
    unmount_iso = false
}

build {
    name = "talos-template"
    sources = [
        "source.proxmox.talos-template"
    ]
    provisioner "shell-local" {
        inline = [
            "echo 'Talos template built'"
        ]   
    }
}