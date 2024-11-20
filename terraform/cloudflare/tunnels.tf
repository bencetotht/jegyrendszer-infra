resource "cloudflare_zero_trust_tunnel_cloudflared" "frontend-tunnel" {
  account_id = var.cloudflare_account_id
  name       = "frontend-tunnel"
}