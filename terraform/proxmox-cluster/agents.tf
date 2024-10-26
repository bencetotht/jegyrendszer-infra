resource "proxmox_vm_qemu" "rke-agent-1" {
  name = "rke-agent-1"
  clone = "ubuntu-2204-minimal-template"
  target_node = "proxmox"
  full_clone = true
  vmid = 114

  storage = "fast1"

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  cores = 2
  cpu = "host"
  memory = 8192
}