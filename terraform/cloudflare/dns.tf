resource "cloudflare_record" "jegyrendszer" {
  zone_id = join("", ["jegy", ".", var.cloudflare_zone])
  name    = "jegyrendszer"
  value   = cloudflare_zero_trust_tunnel_cloudflared.frontend-tunnel.address
  type    = "CNAME"
}