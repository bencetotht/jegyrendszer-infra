variable "kubernetes_domains" {
  type = list(string)
  description = "The domains to create DNS records for that are pointed to the same Kubernetes cluster"
  default = ["docs.bnbdevelopment.hu", "s3.bnbdevelopment.hu", "api.bnbdevelopment.hu", "bnbdevelopment.hu"]
}

resource "cloudflare_dns_record" "kubernetes_domains" {
  for_each = toset(var.kubernetes_domains)
  zone_id = var.cloudflare_zone_id
  name    = each.value
  content = "${cloudflare_zero_trust_tunnel_cloudflared.frontend.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "kubernetes_domains_tunnel_config" {
  for_each   = toset(var.kubernetes_domains)
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.frontend.id
  account_id = var.cloudflare_account_id
  config     = {
    ingress   = [
      {
        hostname = each.value
        service  = "https://192.168.88.105"
        origin_request = {
          no_tls_verify = true
        }
      },
      {
        service  = "http_status:404"
      }
    ]
  }
}