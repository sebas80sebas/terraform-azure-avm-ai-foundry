variable "ai_agent_host_name" {
  type        = string
  description = "Name of the AI agent capability host."
}

variable "ai_foundry_id" {
  type        = string
  description = "Resource ID of the parent AI Foundry account."
}

variable "description" {
  type        = string
  description = "Description of the AI Foundry project."
}

variable "display_name" {
  type        = string
  description = "Display name of the AI Foundry project."
}

variable "location" {
  type        = string
  description = "Azure region for the deployment."
  nullable    = false
}

variable "name" {
  type        = string
  description = "Name of the AI Foundry project."
}

variable "account_capability_host_id" {
  type        = string
  default     = null
  description = "Resource ID of the account-level capability host (if any). Ensures it completes before the project capability host is created."
}

variable "account_user_assigned_identity_principal_ids" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Principal IDs of any user-assigned managed identities attached to the parent AI Foundry account. These are granted the same Cosmos DB and Storage data-plane roles as the project's system-assigned identity."
}

variable "ai_search_id" {
  type        = string
  default     = null
  description = "Resource ID of the AI Search service (created by the dedicated module terraform-azure-avm-search-service)."
}

variable "create_ai_search_connection" {
  type        = bool
  default     = false
  description = "Whether to create the AI Search project connection and related RBAC."
}

variable "cosmos_db_id" {
  type        = string
  default     = null
  description = "Resource ID de la cuenta Cosmos DB."
}

variable "create_cosmos_db_connection" {
  type        = bool
  default     = false
  description = "Whether to create the Cosmos DB project connection and related RBAC."
}

variable "create_ai_agent_service" {
  type        = bool
  default     = true
  description = "Si crear el AI agent service en el proyecto."
}

variable "create_project_connections" {
  type        = bool
  default     = false
  description = "Si crear conexiones del proyecto a los recursos dependientes (Cosmos DB, Key Vault, AI Search, Storage Account)."
}

variable "sku" {
  type        = string
  default     = "S0"
  description = "SKU del proyecto AI Foundry."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Resource ID de la Storage Account."
}

variable "create_storage_account_connection" {
  type        = bool
  default     = false
  description = "Whether to create the Storage Account project connection and related RBAC."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Etiquetas a aplicar a los recursos."
}
