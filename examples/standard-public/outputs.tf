output "ai_foundry_id" {
  description = "Resource ID de la cuenta AI Foundry."
  value       = module.ai_foundry.ai_foundry_id
}

output "ai_foundry_name" {
  description = "Nombre de la cuenta AI Foundry."
  value       = module.ai_foundry.ai_foundry_name
}

output "ai_foundry_project_id" {
  description = "Resource IDs de los proyectos AI Foundry."
  value       = module.ai_foundry.ai_foundry_project_id
}

output "ai_agent_service_id" {
  description = "Resource IDs de los AI agent capability hosts."
  value       = module.ai_foundry.ai_agent_service_id
}

output "ai_model_deployment_ids" {
  description = "Resource IDs de los deployments de modelos."
  value       = module.ai_foundry.ai_model_deployment_ids
}

output "cosmos_db_id" {
  description = "Resource IDs de las cuentas Cosmos DB creadas."
  value       = module.ai_foundry.cosmos_db_id
}

output "key_vault_id" {
  description = "Resource IDs de los Key Vaults creados."
  value       = module.ai_foundry.key_vault_id
}

output "storage_account_id" {
  description = "Resource IDs de las Storage Accounts creadas."
  value       = module.ai_foundry.storage_account_id
}
