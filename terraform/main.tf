terraform {
  required_providers {
    konnect = { source = "kong/konnect" }
    azurerm = { source = "hashicorp/azurerm" }
  }
}

provider "konnect" {
  server_url = "https://us.api.konghq.com" # token from env KONNECT_TOKEN
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# ---------- Azure AI Foundry ----------
resource "azurerm_cognitive_account" "foundry" {
  name                  = var.azure_resource_name
  location              = var.location
  resource_group_name   = var.resource_group
  kind                  = "AIServices"
  sku_name              = "S0"
  custom_subdomain_name = var.azure_resource_name
}

resource "azurerm_cognitive_deployment" "gpt" {
  name                 = var.deployment_name
  cognitive_account_id = azurerm_cognitive_account.foundry.id
  model {
    format  = "OpenAI"
    name    = "gpt-5.4-mini"
    version = "2026-03-17"
  }
  sku {
    name     = "GlobalStandard"
    capacity = 150
  }
}

# ---------- Kong Konnect ----------
resource "konnect_gateway_service" "azure" {
  control_plane_id = var.control_plane_id
  name             = "azure-foundry"
  protocol         = "https"
  host             = "${var.azure_resource_name}.openai.azure.com"
  port             = 443
}

resource "konnect_gateway_route" "chat" {
  control_plane_id = var.control_plane_id
  name             = "azure-chat"
  paths            = ["/chat/completions"]
  methods          = ["POST"]
  strip_path       = true
  service          = { id = konnect_gateway_service.azure.id }
}

resource "konnect_gateway_plugin_ai_proxy" "azure" {
  control_plane_id = var.control_plane_id
  enabled          = true
  route            = { id = konnect_gateway_route.chat.id }
  config = {
    route_type = "llm/v1/chat"
    auth = {
      header_name  = "api-key"
      header_value = azurerm_cognitive_account.foundry.primary_access_key
    }
    model = {
      provider = "azure"
      name     = azurerm_cognitive_deployment.gpt.name
      options = {
        azure_instance      = azurerm_cognitive_account.foundry.custom_subdomain_name
        azure_deployment_id = azurerm_cognitive_deployment.gpt.name
        azure_api_version   = var.azure_api_version
      }
    }
  }
}

# ---------- Lock it down ----------
resource "konnect_gateway_plugin_key_auth" "chat" {
  control_plane_id = var.control_plane_id
  route            = { id = konnect_gateway_route.chat.id }
  config           = { key_names = ["apikey"] }
}

resource "konnect_gateway_consumer" "app" {
  control_plane_id = var.control_plane_id
  username         = "my-app"
}

resource "konnect_gateway_key_auth" "app" {
  control_plane_id = var.control_plane_id
  consumer_id      = konnect_gateway_consumer.app.id
}
