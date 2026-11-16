variable "base_name" {
  type        = string
  description = "Name prefix for all resources in the example."
  default     = "aifpvtbyor"
}

variable "location" {
  type        = string
  description = "Azure region for the deployment."
  default     = "eastus2"
}

variable "ai_search_resource_id" {
  type        = string
  description = "Resource ID of the existing AI Search service (created by the terraform-azure-avm-search-service module)."
}

variable "cosmos_db_resource_id" {
  type        = string
  description = "Resource ID of the existing Cosmos DB account."
}

variable "key_vault_resource_id" {
  type        = string
  description = "Resource ID of the existing Key Vault."
}

variable "storage_account_resource_id" {
  type        = string
  description = "Resource ID of the existing Storage Account."
}

variable "private_endpoint_subnet_resource_id" {
  type        = string
  description = "Subnet resource ID for the private endpoints."
}

variable "private_endpoint_resource_group_name" {
  type        = string
  description = "Name of the resource group where private endpoints will be created."
}

variable "ai_foundry_private_dns_zone_resource_id" {
  type        = string
  description = "Resource ID of the private DNS zone for AI Foundry (cognitiveservices.azure.com or openai.azure.com)."
}

variable "ai_search_private_dns_zone_resource_id" {
  type        = string
  description = "Resource ID of the private DNS zone for AI Search (search.windows.net)."
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace for diagnostics."
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to apply to all resources."
  default = {
    environment = "prod"
    example     = "standard-private-byor"
  }
}
