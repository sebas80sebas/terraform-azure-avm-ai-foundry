output "ai_foundry_id" {
  description = "Resource ID of the AI Foundry account."
  value       = module.ai_foundry.ai_foundry_id
}

output "ai_foundry_name" {
  description = "Name of the AI Foundry account."
  value       = module.ai_foundry.ai_foundry_name
}

output "ai_foundry_project_id" {
  description = "Resource IDs of the AI Foundry projects."
  value       = module.ai_foundry.ai_foundry_project_id
}

output "ai_agent_service_id" {
  description = "Resource IDs of the AI agent capability hosts."
  value       = module.ai_foundry.ai_agent_service_id
}

output "ai_model_deployment_ids" {
  description = "Resource IDs of the model deployments."
  value       = module.ai_foundry.ai_model_deployment_ids
}
