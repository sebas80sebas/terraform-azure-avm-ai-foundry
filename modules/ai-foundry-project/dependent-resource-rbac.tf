# dependent-resource-rbac.tf
# Role assignments on dependent resources (Cosmos DB, Storage, AI Search)
# required for the AI Foundry project to operate correctly.
#
# Split into two resources per type because for_each cannot accept values that
# are only known after apply (the project SMI principal_id).
# Account UMI principal IDs come from data sources and are known at plan time.

locals {
  # Account-level UMI principal IDs (known at plan time)
  account_umi_principal_ids = toset(var.account_user_assigned_identity_principal_ids)

  ai_search_default_role_assignments = {
    search_index_data_contributor = {
      name                       = "${var.name}-search-index-data-contributor"
      role_definition_id_or_name = "Search Index Data Contributor"
    }
    search_service_contributor = {
      name                       = "${var.name}-search-service-contributor"
      role_definition_id_or_name = "Search Service Contributor"
    }
  }

  cosmosdb_default_role_assignments = {
    cosmosdb_operator = {
      name                       = "${var.name}-cosmosdb-operator"
      role_definition_id_or_name = "Cosmos DB Operator"
    }
  }

  storage_account_default_role_assignments = {
    storage_blob_data_contributor = {
      name                       = "${var.name}-storage-blob-data-contributor"
      role_definition_id_or_name = "Storage Blob Data Contributor"
    }
  }
}

resource "azurerm_role_assignment" "ai_search_role_assignments" {
  for_each = var.create_ai_search_connection ? local.ai_search_default_role_assignments : {}

  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
  scope                = var.ai_search_id
  principal_type       = "ServicePrincipal"
  role_definition_name = each.value.role_definition_id_or_name

  depends_on = [time_sleep.wait_project_identities]
}

resource "azurerm_role_assignment" "cosmosdb_role_assignments" {
  for_each = var.create_cosmos_db_connection ? local.cosmosdb_default_role_assignments : {}

  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
  scope                = var.cosmos_db_id
  principal_type       = "ServicePrincipal"
  role_definition_name = each.value.role_definition_id_or_name

  depends_on = [time_sleep.wait_project_identities]
}

resource "azurerm_role_assignment" "storage_role_assignments" {
  for_each = var.create_storage_account_connection ? local.storage_account_default_role_assignments : {}

  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
  scope                = var.storage_account_id
  principal_type       = "ServicePrincipal"
  role_definition_name = each.value.role_definition_id_or_name

  depends_on = [time_sleep.wait_project_identities]
}

# -----------------------------------------------------------------------
# Cosmos DB data-plane role assignment (scope a nivel de database)
# Cubre todos los contenedores incluyendo <project-guid>-agent-definitions-v1
# -----------------------------------------------------------------------

# SMI del proyecto (solo conocida post-apply → count)
resource "azurerm_cosmosdb_sql_role_assignment" "enterprise_memory_db_project_smi" {
  count = var.create_ai_agent_service && var.create_cosmos_db_connection ? 1 : 0

  account_name        = basename(var.cosmos_db_id)
  principal_id        = azapi_resource.ai_foundry_project.output.identity.principalId
  resource_group_name = split("/", var.cosmos_db_id)[4]
  role_definition_id  = "${var.cosmos_db_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  scope               = "${var.cosmos_db_id}/dbs/enterprise_memory"
  name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}-projectsmi-enterprisememory_dbsqlrole")

  depends_on = [azapi_resource.ai_agent_capability_host]
}

# UMIs de la cuenta (conocidas en plan time → for_each)
resource "azurerm_cosmosdb_sql_role_assignment" "enterprise_memory_db_account_umi" {
  for_each = var.create_ai_agent_service && var.create_cosmos_db_connection ? local.account_umi_principal_ids : toset([])

  account_name        = basename(var.cosmos_db_id)
  principal_id        = each.value
  resource_group_name = split("/", var.cosmos_db_id)[4]
  role_definition_id  = "${var.cosmos_db_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  scope               = "${var.cosmos_db_id}/dbs/enterprise_memory"
  name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}-accountumi-${each.value}-enterprisememory_dbsqlrole")

  depends_on = [azapi_resource.ai_agent_capability_host]
}

# -----------------------------------------------------------------------
# Storage Blob Data Owner con condiciones ABAC
# Solo permite acceso a contenedores con prefijo del GUID del proyecto
# -----------------------------------------------------------------------

# SMI del proyecto (count)
resource "azurerm_role_assignment" "storage_blob_data_owner_project_smi" {
  count = var.create_ai_agent_service && var.create_storage_account_connection ? 1 : 0

  principal_id  = azapi_resource.ai_foundry_project.output.identity.principalId
  scope         = var.storage_account_id
  condition     = <<-EOT
  (
    (
      !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/read'})
      AND !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/filter/action'})
      AND !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/write'})
    )
    OR
    (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringStartsWithIgnoreCase '${local.project_id_guid}'
    AND @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLikeIgnoreCase '*-azureml-agent')
  )
  EOT
  condition_version    = "2.0"
  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}-projectsmi-${basename(var.storage_account_id)}storageblobdataowner")
  principal_type       = "ServicePrincipal"
  role_definition_name = "Storage Blob Data Owner"

  depends_on = [azapi_resource.ai_agent_capability_host]
}

# UMIs de la cuenta (for_each)
resource "azurerm_role_assignment" "storage_blob_data_owner_account_umi" {
  for_each = var.create_ai_agent_service && var.create_storage_account_connection ? local.account_umi_principal_ids : toset([])

  principal_id  = each.value
  scope         = var.storage_account_id
  condition     = <<-EOT
  (
    (
      !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/read'})
      AND !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/filter/action'})
      AND !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/write'})
    )
    OR
    (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringStartsWithIgnoreCase '${local.project_id_guid}'
    AND @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLikeIgnoreCase '*-azureml-agent')
  )
  EOT
  condition_version    = "2.0"
  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}-accountumi-${each.value}-${basename(var.storage_account_id)}storageblobdataowner")
  principal_type       = "ServicePrincipal"
  role_definition_name = "Storage Blob Data Owner"

  depends_on = [azapi_resource.ai_agent_capability_host]
}
