# -----------------------------------------------------------------------
# Required variables
# -----------------------------------------------------------------------

variable "base_name" {
  type        = string
  description = "Name prefix used for all module resources when custom names are not provided."

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,7}[a-z0-9]$", var.base_name))
    error_message = "base_name must be between 3 and 9 characters long, start and end with an alphanumeric character, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed."
  nullable    = false
}

variable "resource_group_resource_id" {
  type        = string
  description = "Resource ID of the resource group where module resources will be deployed."
}

# -----------------------------------------------------------------------
# Optional common variables
# -----------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to be applied to all resources."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  nullable    = false
  description = <<DESCRIPTION
Controls whether or not telemetry is sent to Microsoft.
For more information see https://aka.ms/avm/telemetryinfo.
If set to false, no telemetry will be collected.
DESCRIPTION
}

variable "cognitive_services_api_version" {
  type        = string
  default     = "2025-10-01-preview"
  description = "API version used for Microsoft.CognitiveServices resources. Use '2025-07-01-preview' for compatibility with AzAPI provider versions that do not include '2025-10-01-preview'."

  validation {
    condition     = contains(["2025-07-01-preview", "2025-10-01-preview"], var.cognitive_services_api_version)
    error_message = "Allowed values for cognitive_services_api_version are 2025-07-01-preview and 2025-10-01-preview."
  }
}

variable "resource_names" {
  type = object({
    ai_agent_host                   = optional(string)
    ai_foundry                      = optional(string)
    ai_foundry_project              = optional(string)
    ai_foundry_project_display_name = optional(string)
  })
  default     = {}
  description = "Custom names for each resource. If not provided, names are generated using base_name."
}

# -----------------------------------------------------------------------
# Networking variables
# -----------------------------------------------------------------------

variable "create_private_endpoints" {
  type        = bool
  default     = false
  description = "Whether to create private endpoints for AI Foundry, Cosmos DB, Key Vault and AI Search. If false, no private endpoints are created."
}

variable "private_endpoint_subnet_resource_id" {
  type        = string
  default     = null
  description = "(Optional) Subnet resource ID for the private endpoints."
}

variable "private_endpoint_resource_group_name" {
  type        = string
  default     = null
  description = "(Optional) Resource group name where private endpoints will be created."
}

variable "private_endpoint_resource_group_location" {
  type        = string
  default     = null
  description = "(Optional) Location of the resource group for private endpoints."
}

variable "private_endpoints_manage_dns_zone_groups" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups for the module's private endpoints. If false, DNS zone groups are not defined or managed (useful when Azure Policy/DINE manages DNS records)."
}

# -----------------------------------------------------------------------
# Diagnostics variable
# -----------------------------------------------------------------------

variable "diagnostic_settings" {
  type = map(object({
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
  }))
  default  = {}
  nullable = false
  description = <<DESCRIPTION
Map of diagnostic settings to create on the AI Foundry account (Cognitive Services account).
The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

- `name` - (Optional) Name of the diagnostic setting.
- `log_categories` - (Optional) Set of log categories to send. Default `[]`.
- `log_groups` - (Optional) Set of log groups to send. Default `["allLogs"]`.
- `metric_categories` - (Optional) Set of metric categories to send. Default `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) Destination type: `Dedicated` or `AzureDiagnostics`. Default `Dedicated`.
- `workspace_resource_id` - (Optional) Resource ID of the Log Analytics workspace.
- `storage_account_resource_id` - (Optional) Resource ID of the destination Storage Account.
- `event_hub_authorization_rule_resource_id` - (Optional) Resource ID of the Event Hub authorization rule.
- `event_hub_name` - (Optional) Name of the Event Hub.
- `marketplace_partner_resource_id` - (Optional) Full ARM resource ID of the Marketplace resource.
DESCRIPTION

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "log_analytics_destination_type must be 'Dedicated' or 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      v.workspace_resource_id != null || v.storage_account_resource_id != null ||
      v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
    ])
    error_message = "At least one of workspace_resource_id, storage_account_resource_id, marketplace_partner_resource_id or event_hub_authorization_rule_resource_id must be set."
  }
}
