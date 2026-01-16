variable "cloudflare_api_token" {
  description = "The API Token for Cloudflare"
  type        = string
  sensitive   = true # This hides the value from console logs
}

variable "zone_id" {
  description = "Zone ID"
  type        = string
  sensitive   = true # This hides the value from console logs
}


variable "account_id" {
    description = "Account ID"
}