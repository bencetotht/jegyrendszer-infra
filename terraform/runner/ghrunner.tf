resource "proxmox_vm_qemu" "ghrunner" {
    name = "ghrunner"
    vmid = 1001
    target_node = "runner"

    agent = 1

    memory = 8192
    cpu {
      type = "host"
      cores = 4
      sockets = 4
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
        id = 0
    }

    disk {
        storage = "local-lvm"
        type = "disk"
        size = "32G"
        slot = "scsi0"
    }

    clone = "ubuntu-2404-cloudimg"
    full_clone = true

    os_type = "cloud-init"
    # ipconfig0 = "ip=192.168.88.100/24,gw=192.168.88.1"
    ipconfig0 = "ip=dhcp"
    nameserver = "1.1.1.1"
    searchdomain = "1.1.1.1"
}