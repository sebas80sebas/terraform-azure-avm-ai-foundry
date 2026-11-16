# locals.ai_search.tf
# Contains locals for managing RBAC on existing AI Search services (BYOR pattern).
# This module does NOT create AI Search resources. Use the dedicated module terraform-azure-avm-search-service.

locals {
  # Flatten the AI Search role assignments map for for_each iteration
  ai_search_rbac = { for role in flatten([
    for ak, av in var.ai_search_definition : [
      for rk, rv in av.role_assignments : {
        ai_key          = ak
        rbac_key        = rk
        role_assignment = rv
      }
    ]
  ]) : "${role.ai_key}-${role.rbac_key}" => role }
}
