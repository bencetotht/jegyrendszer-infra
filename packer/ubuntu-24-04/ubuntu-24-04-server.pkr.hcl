variable "proxmox_node_name" {
  type = string
  default = "pve"
}

variable "proxmox_storage_pool" {
  type = string
  default = "local-lvm"
}

source "proxmox-iso" "ubuntu-24-04-server" {
  proxmox_url = var.proxmox_api_url
  username = var.proxmox_api_token_id
  token = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  node = var.proxmox_node_name
  vm_id = 9050
  vm_name = "ubuntu-24-04-server"
  template_description = "Ubuntu 24.04 Server Template"

  boot_iso {
    type = "scsi"
    iso_file = "local:iso/ubuntu-24.04-server-amd64.iso"
    unmount = true
  }

  qemu_agent = true
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size = "32G"
    format = "qcow2"
    storage_pool = var.proxmox_storage_pool
    type = "scsi"
  }

  cores = 2
  sockets = 2
  cpu_type = "host"
  memory = 8192
  balloon = 8192

  boot = "order=virtio0;ide2;net0"

  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    firewall = "false"
  }

  cloud_init = true
  cloud_init_storage = var.proxmox_storage_pool
  cloud_init_disk_type = "ide"

  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz quiet autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

  boot_wait       = "5s"
  http_directory  = "http"
  ssh_username    = "ubuntu"
  ssh_password    = "ubuntu"
  ssh_timeout     = "20m"
  ssh_handshake_attempts = "20"
  ipconfig0 = "ip=dhcp"
  nameserver = "1.1.1.1"
  searchdomain = "1.1.1.1"
}

build {
  name = "ubuntu-24-04-server"
  sources = [
    "source.proxmox-iso.ubuntu-24-04-server"
  ]
  provisioner "shell-local" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y install qemu-guest-agent cloud-init",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl enable cloud-init"
    ]
  }
}
