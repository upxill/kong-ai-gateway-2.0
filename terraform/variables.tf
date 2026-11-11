variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group" {
  description = "Azure resource group that holds the Foundry resource"
  type        = string
}

variable "location" {
  description = "Azure region, e.g. northcentralus"
  type        = string
}

variable "azure_resource_name" {
  description = "Azure AI Foundry resource name (also the Azure instance / subdomain)"
  type        = string
  default     = "srinipolagani-8291-resource"
}

variable "deployment_name" {
  description = "Azure model deployment name"
  type        = string
  default     = "gpt-5.4-mini"
}

variable "azure_api_version" {
  type    = string
  default = "2025-04-01-preview"
}

variable "control_plane_id" {
  description = "Konnect control plane ID (serverless-api-gateway-demo)"
  type        = string
  default     = "5e42f6e0-73d1-4f2e-a9dc-bd210184514e"
}
