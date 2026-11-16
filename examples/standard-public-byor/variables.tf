variable "base_name" {
  type        = string
  description = "Name prefix for all resources in the example."
  default     = "aifbyor"
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

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace for diagnostics."
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to apply to all resources."
  default = {
    environment = "prod"
    example     = "standard-public-byor"
  }
}
