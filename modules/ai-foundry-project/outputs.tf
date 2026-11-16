output "ai_agent_capability_host_id" {
  description = "Resource ID of the project AI agent capability host."
  value       = var.create_ai_agent_service && var.create_project_connections ? azapi_resource.ai_agent_capability_host[0].id : null
}

output "ai_foundry_project_id" {
  description = "Resource ID of the AI Foundry project."
  value       = azapi_resource.ai_foundry_project.id
}

output "ai_foundry_project_internal_id" {
  description = "Internal ID of the AI Foundry project (used for container naming)."
  value       = azapi_resource.ai_foundry_project.output.properties.internalId
}

output "ai_foundry_project_name" {
  description = "Name of the AI Foundry project."
  value       = azapi_resource.ai_foundry_project.name
}

output "ai_foundry_project_system_identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity of the AI Foundry project."
  value       = azapi_resource.ai_foundry_project.output.identity.principalId
}

output "project_id_guid" {
  description = "Project ID formatted as a GUID for container naming (only available when AI agent service is enabled)."
  value       = var.create_ai_agent_service ? local.project_id_guid : null
}

output "resource_id" {
  description = "Resource ID of the AI Foundry project."
  value       = azapi_resource.ai_foundry_project.id
}
