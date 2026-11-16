locals {
  #################################################################
  # General local variables
  #################################################################
  paired_region       = [for region in module.avm_utl_regions.regions : region if(lower(region.name) == lower(var.location) || (lower(region.display_name) == lower(var.location)))][0].paired_region_name
  resource_group_name = basename(var.resource_group_resource_id)

  #################################################################
  # Storage Account specific local variables
  #################################################################
  storage_account_default_role_assignments = {}

  storage_account_role_assignments = { for k, v in var.storage_account_definition : k => merge(
    local.storage_account_default_role_assignments,
    var.storage_account_definition[k].role_assignments
  ) }

  #################################################################
  # Key Vault specific local variables
  #################################################################
  key_vault_default_role_assignments = {}

  key_vault_role_assignments = { for k, v in var.key_vault_definition : k => merge(
    local.key_vault_default_role_assignments,
    var.key_vault_definition[k].role_assignments
  ) }
}

locals {
  cosmosdb_secondary_regions = { for k, v in var.cosmosdb_definition :
    k => (var.cosmosdb_definition[k].secondary_regions == null ? [] : (
      try(length(var.cosmosdb_definition[k].secondary_regions) == 0, false) ? [
        {
          location          = local.paired_region
          zone_redundant    = false
          failover_priority = 1
        },
        {
          location          = var.location
          zone_redundant    = false
          failover_priority = 0
        }
      ] : var.cosmosdb_definition[k].secondary_regions)
  ) }
}
