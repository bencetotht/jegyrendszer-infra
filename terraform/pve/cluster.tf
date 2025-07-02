variable "pve_nodes" {
    type = list(object({
        name = string
        template_id = string
        storage_pool = string
        network_interface = string
    }))
    default = [
        {
            name = "proxmox"
            template_id = "talos-template"
            storage_pool = "fast2"
            network_interface = "vmbr0"
        },
        {
            name = "pve2"
            template_id = "talos-template" 
            storage_pool = "hdd-zfs"
            network_interface = "vmbr0"
        },
        {
            name = "pve3"
            template_id = "talos-template"
            storage_pool = "fast3"
            network_interface = "vmbr1"
        }
    ]
}
variable "num_master" {
    type = number
    default = 3
}
variable "num_worker" {
    type = number
    default = 3
}
variable "master_ips" {
    type = list(string)
    default = ["192.168.88.11", "192.168.88.12", "192.168.88.13"]
}
variable "worker_ips" {
    type = list(string)
    default = ["192.168.88.21", "192.168.88.22", "192.168.88.23"]
}

resource "proxmox_vm_qemu" "master" {
    count = var.num_master
    name = "master-${count.index + 1}"
    desc = "Master ${count.index + 1}"
    vmid = 1001 + count.index
    target_node = var.pve_nodes[count.index].name

    agent = 1

    cores = 4
    sockets = 4
    memory = 16384
    cpu = "host"

    network {
        model = "virtio"
        bridge = var.pve_nodes[count.index].network_interface
    }

    disk {
        storage = var.pve_nodes[count.index].storage_pool
        type = "scsi"
        size = "32G"
    }

    clone = var.pve_nodes[count.index].template_id
    full_clone = true

    os_type = "cloud-init"
    ipconfig0 = "ip=${var.master_ips[count.index]}/24,gw=192.168.88.1"
    nameserver = "1.1.1.1"
    searchdomain = "1.1.1.1"

}

resource "proxmox_vm_qemu" "worker" {
    count = var.num_worker
    name = "worker-${count.index + 1}"
    desc = "Worker ${count.index + 1}"
    vmid = 1001 + var.num_master + count.index
    target_node = var.pve_nodes[count.index].name

    agent = 1

    cores = 4
    sockets = 4
    memory = 16384
    cpu = "host"

    network {
        model = "virtio"
        bridge = var.pve_nodes[count.index].network_interface
    }

    disk {
        storage = var.pve_nodes[count.index].storage_pool
        type = "scsi"
        size = "32G"
    }

    clone = var.pve_nodes[count.index].template_id
    full_clone = true

    os_type = "cloud-init"
    ipconfig0 = "ip=${var.worker_ips[count.index]}/24,gw=192.168.88.1"
    nameserver = "1.1.1.1"
    searchdomain = "1.1.1.1"
}

output "master_vms" {
    value = proxmox_vm_qemu.master[*].vmid
}

output "worker_vms" {
    value = proxmox_vm_qemu.worker[*].vmid
}