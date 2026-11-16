variable "ai_projects" {
  type = map(object({
    name                       = string
    sku                        = optional(string, "S0")
    display_name               = string
    description                = string
    create_project_connections = optional(bool, false)
    enable_ai_search_connection       = optional(bool, false)
    enable_cosmos_db_connection       = optional(bool, false)
    enable_storage_account_connection = optional(bool, false)
    cosmos_db_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
    ai_search_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
    key_vault_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
    storage_account_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
  }))
  default     = {}
  description = <<DESCRIPTION
Map of AI Foundry projects to create.
Each project can have its own configuration and connections to dependent resources.

- `map key` - Map key. Must match the dependent resource keys when creating connections.
  - `name` - Name of the AI Foundry project.
  - `sku` - (Optional) Project SKU. Default "S0".
  - `display_name` - Display name of the project.
  - `description` - Project description.
  - `create_project_connections` - (Optional) Global switch to create project connections. Default false.
  - `enable_ai_search_connection` - (Optional) Create AI Search connection when create_project_connections is true. Default false.
  - `enable_cosmos_db_connection` - (Optional) Create Cosmos DB connection when create_project_connections is true. Default false.
  - `enable_storage_account_connection` - (Optional) Create Storage Account connection when create_project_connections is true. Default false.
  - `cosmos_db_connection` - (Optional) Cosmos DB connection configuration.
    - `existing_resource_id` - (Optional) Resource ID of an existing Cosmos DB account.
    - `new_resource_map_key` - (Optional) Map key of a new Cosmos DB account to create.
  - `ai_search_connection` - (Optional) AI Search connection configuration.
    - `existing_resource_id` - (Optional) Resource ID of an existing AI Search service (BYOR recommended).
    - `new_resource_map_key` - (Optional) Map key from ai_search_definition.
  - `key_vault_connection` - (Optional) Key Vault connection configuration.
    - `existing_resource_id` - (Optional) Resource ID of an existing Key Vault.
    - `new_resource_map_key` - (Optional) Map key of a new Key Vault to create.
  - `storage_account_connection` - (Optional) Storage Account connection configuration.
    - `existing_resource_id` - (Optional) Resource ID of an existing Storage Account.
    - `new_resource_map_key` - (Optional) Map key of a new Storage Account to create.
DESCRIPTION
}
