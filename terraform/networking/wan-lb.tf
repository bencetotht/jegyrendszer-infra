resource "routeros_ip_firewall_mangle" "wan-1-conn" {
  chain = "prerouting"
  in_interface = "wan"
  connection_mark = "no-mark"
  per_connection_classifier = "both-addresses:2/0"
  action = "mark-connection"
  new_connection_mark = "wan1_conn"
}

resource "routeros_ip_firewall_mangle" "wan-2-conn" {
  chain = "prerouting"
  in_interface = "bridge-lan"
  connection_mark = "no-mark"
  per_connection_classifier = "both-addresses:2/1"
  action = "mark-connection"
  new_connection_mark = "wan2_conn"
}

resource "routeros_ip_firewall_mangle" "wan-1-routing" {
  chain = "prerouting"
  connection_mark = "wan1_conn"
  action = "mark-routing"
  new_routing_mark = "to_wan1"
}

resource "routeros_ip_firewall_mangle" "wan-2-routing" {
  chain = "prerouting"
  connection_mark = "wan2_conn"
  action = "mark-routing"
  new_routing_mark = "to_wan2"
}

resource "routeros_ip_route" "wan-1-route" {
  dst_address = "0.0.0.0/0"
  gateway = "192.168.88.1"
  distance = 1
  check_gateway = "ping"
}

resource "routeros_ip_route" "wan-2-route" {
  dst_address = "0.0.0.0/0"
  gateway = "192.168.88.1"
  distance = 2
  check_gateway = "ping"
}

resource "routeros_script" "policy_routes" {
  name   = "policy_routing_setup"
  policy = ["ftp", "read", "write", "policy", "test"]

  source = <<-EOT
    :log info "Applying PCC policy routing..."
    /ip/route/remove [find where routing-mark=to_wan1]
    /ip/route/add dst-address=0.0.0.0/0 gateway=192.168.0.1 routing-mark=to_wan1 check-gateway=ping
    /ip/route/remove [find where routing-mark=to_wan2]
    /ip/route/add dst-address=0.0.0.0/0 gateway=192.168.0.1 routing-mark=to_wan2 check-gateway=ping
  EOT
}