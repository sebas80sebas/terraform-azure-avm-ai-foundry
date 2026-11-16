# -----------------------------------------------------------------------
# variables.byor.tf
# Variables for dependent resources:
#   - Storage Account (BYOR or CYOR)
#   - Cosmos DB (BYOR or CYOR)
#   - Key Vault (BYOR or CYOR)
#   - AI Search (BYOR ONLY - use the dedicated module terraform-azure-avm-search-service)
#
# NOTE on AI Search:
#   This module does NOT create AI Search resources (no CYOR path). The reason is that
#   a dedicated module already exists in this stack: terraform-azure-avm-search-service.
#   The recommended pattern is:
#     1. Create AI Search with the dedicated module terraform-azure-avm-search-service
#     2. Pass the resource ID via ai_search_definition[*].existing_resource_id (BYOR)
#   This ensures lifecycle separation, consistent governance, and avoids duplicating
#   resource management logic.
# -----------------------------------------------------------------------

variable "create_byor" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
Whether to create dependent resources (Cosmos DB, Key Vault, Storage Account) in this deployment.
If false, those resources are not created or linked, and the module only deploys the AI Foundry account and its projects.

NOTE: AI Search always uses the BYOR pattern in this module.
Create AI Search with the dedicated module terraform-azure-avm-search-service and pass the resource ID via ai_search_definition.
DESCRIPTION
}

variable "ai_search_definition" {
  type = map(object({
    existing_resource_id         = optional(string, null)
    name                         = optional(string)
    private_dns_zone_resource_id = optional(string, null)
    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
Map of references to existing AI Search services (BYOR pattern).
This module does NOT create AI Search resources - use the dedicated module terraform-azure-avm-search-service for that.

- `map key` - Map key. Must match the ai_search_connection key of the project.
  - `existing_resource_id` - Resource ID of the existing AI Search service (created by the dedicated module).
  - `name` - (Optional) Descriptive name for internal references.
  - `private_dns_zone_resource_id` - (Optional) Resource ID of the private DNS zone for AI Search.
  - `diagnostic_settings` - (Optional) Diagnostic settings to apply to the existing AI Search service.
  - `role_assignments` - (Optional) Additional role assignments to create on the AI Search service.
DESCRIPTION

  validation {
    condition = alltrue([
      for k, v in var.ai_search_definition :
      v.existing_resource_id != null
    ])
    error_message = "This module only supports the BYOR pattern for AI Search. All entries in ai_search_definition must have existing_resource_id set. Create AI Search with the dedicated module terraform-azure-avm-search-service."
  }
}

variable "cosmosdb_definition" {
  type = map(object({
    existing_resource_id         = optional(string, null)
    private_dns_zone_resource_id = optional(string, null)
    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    name = optional(string)
    secondary_regions = optional(list(object({
      location          = string
      zone_redundant    = optional(bool, true)
      failover_priority = optional(number, 0)
    })), [])
    public_network_access_enabled    = optional(bool, false)
    analytical_storage_enabled       = optional(bool, false)
    automatic_failover_enabled       = optional(bool, true)
    local_authentication_disabled    = optional(bool, true)
    partition_merge_enabled          = optional(bool, false)
    multiple_write_locations_enabled = optional(bool, false)
    analytical_storage_config = optional(object({
      schema_type = string
    }), null)
    consistency_policy = optional(object({
      max_interval_in_seconds = optional(number, 300)
      max_staleness_prefix    = optional(number, 100001)
      consistency_level       = optional(string, "Session")
    }), {})
    backup = optional(object({
      retention_in_hours  = optional(number)
      interval_in_minutes = optional(number)
      storage_redundancy  = optional(string)
      type                = optional(string)
      tier                = optional(string)
    }), {})
    capabilities = optional(set(object({
      name = string
    })), [])
    capacity = optional(object({
      total_throughput_limit = optional(number, -1)
    }), {})
    cors_rule = optional(object({
      allowed_headers    = set(string)
      allowed_methods    = set(string)
      allowed_origins    = set(string)
      exposed_headers    = set(string)
      max_age_in_seconds = optional(number, null)
    }), null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    tags = optional(map(string), {})
  }))
  default     = {}
  description = <<DESCRIPTION
Configuration object for the Azure Cosmos DB account for GenAI services.
Supports both BYOR (existing_resource_id) and CYOR (create_byor = true).

- `map key` - Map key. Must match the AI project key when creating connections.
  - `existing_resource_id` - (Optional) Resource ID of an existing Cosmos DB account. If specified, no new account is created.
  - `private_dns_zone_resource_id` - (Optional) Resource ID of the private DNS zone for Cosmos DB.
  - `diagnostic_settings` - (Optional) Diagnostic settings.
  - `name` - (Optional) Account name. If not specified, one is generated.
  - `secondary_regions` - (Optional) Secondary regions for geo-replication.
  - `public_network_access_enabled` - (Optional) Default false.
  - `analytical_storage_enabled` - (Optional) Default false.
  - `automatic_failover_enabled` - (Optional) Default true.
  - `local_authentication_disabled` - (Optional) Default true.
  - `consistency_policy` - (Optional) Consistency policy. Default Session.
  - `backup` - (Optional) Backup configuration.
  - `capabilities` - (Optional) Capabilities to enable.
  - `role_assignments` - (Optional) Additional role assignments.
  - `tags` - (Optional) Tags.
DESCRIPTION
}

variable "key_vault_definition" {
  type = map(object({
    existing_resource_id         = optional(string, null)
    name                         = optional(string)
    private_dns_zone_resource_id = optional(string, null)
    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    sku       = optional(string, "standard")
    tenant_id = optional(string)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    tags = optional(map(string), {})
  }))
  default     = {}
  description = <<DESCRIPTION
Configuration object for Azure Key Vault for GenAI services.
Supports both BYOR (existing_resource_id) and CYOR (create_byor = true).
Short alphanumeric keys are recommended to avoid Key Vault naming length limits.

- `map key` - Map key. Must match the AI project key.
  - `existing_resource_id` - (Optional) Resource ID of an existing Key Vault.
  - `name` - (Optional) Key Vault name. If not specified, one is generated.
  - `private_dns_zone_resource_id` - (Optional) Resource ID of the private DNS zone.
  - `diagnostic_settings` - (Optional) Diagnostic settings.
  - `sku` - (Optional) Key Vault SKU. Default "standard".
  - `tenant_id` - (Optional) Tenant ID. If not specified, the current tenant is used.
  - `role_assignments` - (Optional) Additional role assignments.
  - `tags` - (Optional) Tags.
DESCRIPTION
}

variable "storage_account_definition" {
  type = map(object({
    existing_resource_id = optional(string, null)
    diagnostic_settings_storage_account = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    name                     = optional(string, null)
    account_kind             = optional(string, "StorageV2")
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "ZRS")
    endpoints = optional(map(object({
      type                         = string
      private_dns_zone_resource_id = optional(string, null)
      })), {
      blob = {
        type = "blob"
      }
    })
    access_tier               = optional(string, "Hot")
    shared_access_key_enabled = optional(bool, false)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    tags = optional(map(string), {})
  }))
  default     = {}
  description = <<DESCRIPTION
Configuration object for Azure Storage Account for GenAI services.
Supports both BYOR (existing_resource_id) and CYOR (create_byor = true).
Short alphanumeric keys are recommended to avoid Storage Account naming length limits.

- `map key` - Map key. Must match the AI project key.
  - `existing_resource_id` - (Optional) Resource ID of an existing Storage Account.
  - `diagnostic_settings_storage_account` - (Optional) Diagnostic settings.
  - `name` - (Optional) Account name. If not specified, one is generated.
  - `account_kind` - (Optional) Account kind. Default "StorageV2".
  - `account_tier` - (Optional) Performance tier. Default "Standard".
  - `account_replication_type` - (Optional) Replication type. Default "ZRS".
  - `endpoints` - (Optional) Endpoints to enable. Default: blob.
  - `access_tier` - (Optional) Access tier. Default "Hot".
  - `shared_access_key_enabled` - (Optional) Default false.
  - `role_assignments` - (Optional) Additional role assignments.
  - `tags` - (Optional) Tags.
DESCRIPTION
}
