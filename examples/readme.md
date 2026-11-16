# Examples

This directory contains usage examples for the `terraform-azure-avm-ai-foundry` module.

## Structure

| Example | Description | Pattern |
|---------|-------------|--------|
| [basic](./basic/) | Minimal deployment: AI Foundry account + project. Public access, no external dependencies. | — |
| [standard-public](./standard-public/) | Full public-access deployment. Creates Cosmos DB, Key Vault, and Storage Account inline (CYOR). AI Search is always BYOR. | CYOR |
| [standard-public-byor](./standard-public-byor/) | Full public-access deployment using existing resources (BYOR). Includes model deployments and diagnostics. | BYOR |
| [standard-private-byor](./standard-private-byor/) | Enterprise deployment with private endpoints and public access disabled. AI Agent service enabled. DNS managed by Azure Policy. | BYOR + Private |

## BYOR vs CYOR Pattern

| | BYOR | CYOR |
|---|---|---|
| **AI Search** | ✅ Always (dedicated module) | ❌ Not supported |
| **Cosmos DB** | ✅ `existing_resource_id` | ✅ `create_byor = true` |
| **Key Vault** | ✅ `existing_resource_id` | ✅ `create_byor = true` |
| **Storage Account** | ✅ `existing_resource_id` | ✅ `create_byor = true` |
| **Recommended for** | Production / Landing Zone | PoC / Demo |

## Important Note About AI Search

This module **DOES NOT create** AI Search resources. The reason is that this stack already includes
a dedicated module, `terraform-azure-avm-ai-search`, with its own naming, networking,
and RBAC conventions. Always:

1. Create AI Search with the `terraform-azure-avm-ai-search` module
2. Pass the resource ID via `ai_search_definition["key"].existing_resource_id`