provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id = var.account_id
  name       = "budget-tunnel"
  tunnel_secret = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "budget_tunnel_config" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
  config = {
    ingress = [ {
      hostname = "budget.sretech.org"
      service = "http://budget-service"
    },
    {
      service = "http_status:404"
    } ]
  }
}

output "tunnel_token" {
  value = base64encode(jsonencode({
    "a" = var.account_id,
    "t" = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id,
    "s" = random_id.tunnel_secret.b64_std
  }))
  sensitive = true
}

resource "cloudflare_zero_trust_access_policy" "home_policy" {
  account_id = var.account_id
  name = "Allow Home People Access"
  decision = "allow"
    include = [{
        type = "email"
        email = {
            email = "yanick76@live.com"
        }
    },
    {
        type = "email"
        email = {
            email = "sharonlks17@gmail.com"
        }
    }]

}

resource "cloudflare_zero_trust_access_application" "budget_app" {
    account_id = var.account_id
    name       = "Budget App"
    domain     = "budget.sretech.org"
    type       = "self_hosted"
    session_duration = "1h"
    policies = [ {
      id = cloudflare_zero_trust_access_policy.home_policy.id
    } ]
  
}

resource "cloudflare_dns_record" "budget" {
    zone_id = var.zone_id
    name    = "budget"
    content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel.id}.cfargotunnel.com"
    type    = "CNAME"
    proxied = true
    ttl = 1
}