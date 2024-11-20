variable "cloudflare_zone" {
    description = "The Cloudflare Zone"
    type = string
}

variable "cloudflare_zone_id" {
    description = "The Cloudflare Zone ID"
    type = string
}

variable "cloudflare_account_id" {
    description = "The Cloudflare Account ID"
    type = string
    sensitive = true
}

variable "cloudflare_email" {
    description = "The Cloudflare Email"
    type = string
    sensitive = true
}

variable "cloudflare_api_token" {
    description = "The Cloudflare API Token"
    type = string
    sensitive = true
}
