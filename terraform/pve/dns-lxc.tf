variable "dns_ips" {
    type = list(string)
    default = ["192.168.88.61", "192.168.88.62", "192.168.88.63"]
}

variable "dns_pass" {
    type = string
    default = "dnspass"
    sensitive = true
}

resource "proxmox_lxc" "dns" {
    count = length(var.pve_nodes)
    target_node  = var.pve_nodes[count.index].name
    hostname = "dns-${count.index + 1}"
    ostemplate = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
    password = var.dns_pass

    vmid = 260 + count.index + 1

    rootfs {
        storage = "fast3"
        size = "8GB"
    }

    cores = 1
    memory = 1024
    swap = 1024

    network {
        name = "eth0"
        bridge = "vmbr0"
        ip = var.dns_ips[count.index]
        gw = "192.168.88.1"
    }

    nameserver = "1.1.1.1"
    searchdomain = "1.1.1.1"

    tags = "dns"
}

output "vmid" {
  value = proxmox_lxc.dns[*].vmid
}