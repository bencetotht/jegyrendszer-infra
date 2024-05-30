resource "tailscale_device_key" "agora-proxmox-pve1" {
  device_id           = data.tailscale_device.agora-proxmox-pve1.id
  key_expiry_disabled = true
}
resource "tailscale_device_key" "agora-proxmox-pve2" {
  device_id           = data.tailscale_device.agora-proxmox-pve2.id
  key_expiry_disabled = true
}
resource "tailscale_device_key" "agora-router-pve1" {
  device_id           = data.tailscale_device.agora-router-pve1.id
  key_expiry_disabled = true
}
resource "tailscale_device_key" "agora-router-pve2" {
  device_id           = data.tailscale_device.agora-router-pve2.id
  key_expiry_disabled = true
}