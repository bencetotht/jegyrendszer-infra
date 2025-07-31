resource "cloudflare_zero_trust_tunnel_cloudflared" "frontend" {
  account_id = var.cloudflare_account_id
  name       = "frontend-tunnel-2-test"
}

output "frontend_tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.frontend.id
}