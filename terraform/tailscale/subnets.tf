resource "tailscale_device_subnet_routes" "router-01" {
  device_id = data.tailscale_device.agora-router-pve1.id
  routes = [
    "10.10.10.0/24",
  ]
}

resource "tailscale_device_subnet_routes" "router-02" {
    device_id = data.tailscale_device.agora-router-pve2
    routes = [
        "10.10.20.0/24"
    ]
} 

resource "tailscale_device_subnet_routes" "pve-2-internal" {
  device_id = data.tailscale_device.agora-proxmox-pve2
  routes = [ 
      "192.168.88.0/24"
   ]
}