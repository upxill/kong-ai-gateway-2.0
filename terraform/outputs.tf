output "proxy_url" {
  value = "https://4b1ed59e0a.us.serverless.gateways.konggateway.com/chat/completions"
}

output "app_api_key" {
  description = "Key clients send in the apikey header"
  value       = konnect_gateway_key_auth.app.key
  sensitive   = true
}
