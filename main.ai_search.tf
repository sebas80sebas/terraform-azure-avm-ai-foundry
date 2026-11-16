# main.ai_search.tf
# AI Search management in BYOR (Bring Your Own Resource) mode.
#
# This module does NOT create AI Search resources. The reason is that a dedicated
# module already exists in this stack: terraform-azure-avm-search-service, which
# carries its own naming, networking, and RBAC conventions.
#
# What this file DOES handle:
#   1. Role assignments on existing AI Search services (Search Index Data Contributor, etc.)
#   2. Diagnostic settings on existing AI Search services
#
# Project → AI Search connections are managed in the ai-foundry-project submodule.
# Pass the resource ID via: ai_search_definition["key"].existing_resource_id

# -----------------------------------------------------------------------
# Role assignments on existing AI Search services (BYOR)
# -----------------------------------------------------------------------
resource "azurerm_role_assignment" "this_aisearch" {
  for_each = local.ai_search_rbac

  principal_id                           = each.value.role_assignment.principal_id
  scope                                  = var.ai_search_definition[each.value.ai_key].existing_resource_id
  condition                              = each.value.role_assignment.condition
  condition_version                      = each.value.role_assignment.condition_version
  delegated_managed_identity_resource_id = each.value.role_assignment.delegated_managed_identity_resource_id
  principal_type                         = each.value.role_assignment.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_assignment.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_assignment.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.role_assignment.skip_service_principal_aad_check
}

# -----------------------------------------------------------------------
# Diagnostic settings on existing AI Search services (BYOR)
# -----------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "this_aisearch" {
  for_each = merge([
    for search_key, search_value in var.ai_search_definition : {
      for diag_key, diag_value in search_value.diagnostic_settings :
      "${search_key}-${diag_key}" => merge(diag_value, {
        target_resource_id = search_value.existing_resource_id
      })
    }
  ]...)

  name                           = each.value.name != null ? each.value.name : "diag-${split("/", each.value.target_resource_id)[8]}"
  target_resource_id             = each.value.target_resource_id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories

    content {
      category = enabled_metric.value
    }
  }
}
