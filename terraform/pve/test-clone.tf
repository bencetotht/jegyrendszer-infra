resource "proxmox_vm_qemu" "test-clone" {
    name = "test-clone"
    desc = "Test clone"
    vmid = 1001
    target_node = "pve3"

    agent = 1 # Enable QEMU guest agent

    cores = 4
    sockets = 4
    memory = 16384
    cpu = "host"

    network {
        model = "virtio"
        bridge = "vmbr1"
    }

    disk {
        storage = "fast3"
        type = "scsi"
        size = "32G"
    }

    clone = "talos-template"
    full_clone = true

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.88.211/24,gw=192.168.88.1"
    nameserver = "1.1.1.1"
    searchdomain = "1.1.1.1"

}