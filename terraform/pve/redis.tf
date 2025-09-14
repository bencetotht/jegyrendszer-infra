variable "redis_ips" {
    type = list(string)
    default = ["192.168.88.61", "192.168.88.62", "192.168.88.63"]
}

variable "redis_pass" {
    type = string
    default = "redispass"
    sensitive = true
}

resource "proxmox_lxc" "redis" {
    count = length(var.pve_nodes)
    target_node  = var.pve_nodes[count.index].name
    hostname = "redis-${count.index + 1}"
    ostemplate = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    password = var.redis_pass

    vmid = 270 + count.index + 1

    rootfs {
        storage = var.pve_nodes[count.index].storage_pool
        size = "16GB"
    }

    cores = 2
    memory = 4096
    swap = 4096

    network {
        name = "eth0"
        bridge = "vmbr0"
        ip = "${var.redis_ips[count.index]}/24"
        gw = "192.168.88.1"
    }

    nameserver = "1.1.1.1"
    searchdomain = "1.1.1.1"

    tags = "redis"

    ssh_public_keys = <<-EOT
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA92dK4JsOj34/tw91nufWv7ccIcR4j2HX8N7ZOW+fQgePhRcs2+cWqqTgN1yfmev5c6If5bPe8h2XsL1OzEBhDxesuRNua80smhYwkuA2Vo0KcFCXsQL6sJIGh4YchWtkBDhr4g3JrvzTxQrL4faPr3vhYyyh7IONVRbgY0glVrQ4FkDLu9p7MaFhl16EnbNsqkagxmRn06cvaP+bjImxeBqg7Af8tDcBlbCE7AskOMA4DxOQPIZ5ZrkKRPE6856T9P8oWPK4vwy3J2FCa1y7x27FLJD1Ep2QFssF9ifuQb9Q2uYWTVEEXu8MWwf+E3g8pwG1lyy5FVkSf3mUZsp9
    EOT

    start = "true"

    features {
      nesting = "true"
    }
    unprivileged = "true"
}

output "redis_vmid" {
  value = proxmox_lxc.redis[*].vmid
}