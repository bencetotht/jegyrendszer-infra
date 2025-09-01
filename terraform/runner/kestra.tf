resource "proxmox_vm_qemu" "kestravm" {
    name = "kestravm"
    vmid = 1003
    target_node = "runner"

    agent = 1

    memory = 8192
    
    cpu {
      type = "host"
      cores = 1
      sockets = 2
    }

    boot = "order=ide0;net0"

    network {
        model = "virtio"
        bridge = "vmbr0"
        id = 0
    }

    disks {
      ide {
        ide0 {
          disk {
            storage = "local-lvm"
            size = "32G"
          }
        }
        ide2 {
          cloudinit {
            storage = "local-lvm"
          }
        }
      }
    }

    serial {
      id = 0
      type = "socket"
    }

    clone = "ubuntu-2404-cloudimg"
    full_clone = true

    os_type = "cloud-init"
    # ipconfig0 = "ip=192.168.88.100/24,gw=192.168.88.1"
    ciuser = "bence"
    ipconfig0 = "ip=dhcp"
    nameserver = "1.1.1.1"
    searchdomain = "1.1.1.1"
}