variable "ai_foundry" {
  type = object({
    name                     = optional(string, null)
    disable_local_auth       = optional(bool, false)
    allow_project_management = optional(bool, true)
    create_ai_agent_service  = optional(bool, false)
    network_injections = optional(list(object({
      scenario                   = optional(string, "agent")
      subnetArmId                = string
      useMicrosoftManagedNetwork = optional(bool, false)
    })), null)
    private_dns_zone_resource_ids = optional(list(string), [])
    sku                           = optional(string, "S0")
    public_network_access_enabled = optional(bool, null)
    network_acls = optional(object({
      default_action = optional(string, "Allow")
      bypass         = optional(string, null)
      ip_rules       = optional(list(string), [])
      virtual_network_rules = optional(list(object({
        subnet_resource_id                   = string
        ignore_missing_vnet_service_endpoint = optional(bool, false)
      })), [])
    }), null)
    managed_identities = optional(object({
      system_assigned            = optional(bool, true)
      user_assigned_resource_ids = optional(set(string), [])
    }), { system_assigned = true, user_assigned_resource_ids = [] })
    customer_managed_key = optional(object({
      key_vault_resource_id              = string
      key_name                           = string
      key_version                        = optional(string, null)
      user_assigned_identity_resource_id = string
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
  })
  default     = {}
  description = <<DESCRIPTION
Configuration object for the Azure AI Foundry account.

- `name` - (Optional) Account name. If not specified, one is generated.
- `disable_local_auth` - (Optional) Disable local authentication. Default false.
- `allow_project_management` - (Optional) Allow project management capabilities. Default true.
- `create_ai_agent_service` - (Optional) Create an AI Agent service. Default false.
- `network_injections` - (Optional) Network injection configurations for Standard Agents.
  - `scenario` - (Optional) Scenario. Default "agent".
  - `subnetArmId` - Subnet ARM ID for the AI Agent service.
  - `useMicrosoftManagedNetwork` - (Optional) Default false.
- `private_dns_zone_resource_ids` - (Optional) Resource IDs of private DNS zones for AI Foundry.
  Required when create_private_endpoints is true and private_endpoint.unmanaged_dns_zone_group_enabled is false.
- `sku` - (Optional) Account SKU. Default "S0".
- `public_network_access_enabled` - (Optional) Override the public network access setting.
  When null (default), derived from create_private_endpoints.
- `network_acls` - (Optional) Network ACLs applied to the Foundry account.
  - `default_action` - (Optional) `Allow` or `Deny`. Default `Allow`.
  - `bypass` - (Optional) Bypass rule. Use `AzureServices` to allow Microsoft services.
  - `ip_rules` - (Optional) List of allowed CIDR ranges or IP addresses.
  - `virtual_network_rules` - (Optional) List of allowed subnets.
- `managed_identities` - (Optional) Identity configuration.
  - `system_assigned` - (Optional) Enable system-assigned identity. Default true.
  - `user_assigned_resource_ids` - (Optional) Set of user-assigned managed identity resource IDs.
- `customer_managed_key` - (Optional) CMK encryption configuration.
  - `key_vault_resource_id` - Resource ID of the Key Vault.
  - `key_name` - Name of the key in Key Vault.
  - `key_version` - (Optional) Key version.
  - `user_assigned_identity_resource_id` - Resource ID of the UAMI with Key Vault access.
- `role_assignments` - (Optional) Map of role assignments on the AI Foundry account.
DESCRIPTION
}

variable "ai_model_deployments" {
  type = map(object({
    name                   = string
    rai_policy_name        = optional(string, "Microsoft.DefaultV2")
    version_upgrade_option = optional(string, "OnceNewDefaultVersionAvailable")
    model = object({
      format  = string
      name    = string
      version = string
    })
    scale = object({
      capacity = optional(number)
      family   = optional(string)
      size     = optional(string)
      tier     = optional(string)
      type     = string
    })
  }))
  default     = {}
  description = <<DESCRIPTION
Configuration for AI model deployments (including OpenAI).

- `name` - Deployment name.
- `rai_policy_name` - (Optional) RAI policy name. Default "Microsoft.DefaultV2".
- `version_upgrade_option` - (Optional) How to handle version upgrades. Default "OnceNewDefaultVersionAvailable".
- `model` - Model configuration:
  - `format` - Model format (e.g. "OpenAI").
  - `name` - Model name (e.g. "gpt-4o").
  - `version` - Model version (e.g. "2024-11-20").
- `scale` - Scaling configuration:
  - `type` - Scale type (e.g. "Standard", "GlobalStandard").
  - `capacity` - (Optional) Capacity in thousands of tokens per minute (TPM).
  - `family` - (Optional) Deployment family.
  - `size` - (Optional) Deployment size.
  - `tier` - (Optional) Pricing tier.
DESCRIPTION
}
