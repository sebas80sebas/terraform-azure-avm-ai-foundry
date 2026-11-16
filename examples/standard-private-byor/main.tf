terraform {
  required_version = ">= 1.12, < 2.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.38"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}

# ---------------------------------------------------------------------------
# Example standard-private-byor
# Enterprise deployment with private endpoints using existing resources (BYOR):
#   - AI Search created by the dedicated module terraform-azure-avm-search-service
#   - Storage Account, Cosmos DB and Key Vault with existing private endpoints
#   - VNet and DNS zones managed externally (landing zone)
#   - Public access disabled
#   - AI Agent service enabled with Standard Agents
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "rg-${var.base_name}-aifoundry-private-byor"
}

module "ai_foundry" {
  source = "../.."

  base_name                  = var.base_name
  location                   = var.location
  resource_group_resource_id = azurerm_resource_group.this.id

  # ---------------------------------------------------------------------------
  # AI Foundry account configuration
  # ---------------------------------------------------------------------------
  ai_foundry = {
    disable_local_auth       = true
    allow_project_management = true
    create_ai_agent_service  = true

    # Private DNS zones for the AI Foundry account
    private_dns_zone_resource_ids = [var.ai_foundry_private_dns_zone_resource_id]

    # Public access is automatically disabled when create_private_endpoints = true
    # public_network_access_enabled = false

    # Network ACLs for additional restriction in landing zone
    network_acls = {
      default_action = "Deny"
      bypass         = "AzureServices"
    }

    # System-assigned managed identity (default) for the agent
    managed_identities = {
      system_assigned = true
    }
  }

  # ---------------------------------------------------------------------------
  # Private endpoints
  # ---------------------------------------------------------------------------
  create_private_endpoints                 = true
  private_endpoint_subnet_resource_id      = var.private_endpoint_subnet_resource_id
  private_endpoint_resource_group_name     = var.private_endpoint_resource_group_name
  private_endpoint_resource_group_location = var.location
  # DNS managed by Azure Policy DINE in the landing zone
  private_endpoints_manage_dns_zone_groups = false

  # ---------------------------------------------------------------------------
  # Projects with connections to existing resources (BYOR)
  # ---------------------------------------------------------------------------
  ai_projects = {
    main = {
      name                       = "proj-${var.base_name}-main"
      display_name               = "Main Project"
      description                = "Main project with private endpoints and Standard Agents"
      create_project_connections = true

      ai_search_connection = {
        existing_resource_id = var.ai_search_resource_id
      }
      cosmos_db_connection = {
        existing_resource_id = var.cosmos_db_resource_id
      }
      key_vault_connection = {
        existing_resource_id = var.key_vault_resource_id
      }
      storage_account_connection = {
        existing_resource_id = var.storage_account_resource_id
      }
    }
  }

  # ---------------------------------------------------------------------------
  # AI Search (BYOR - resource created by dedicated module, DNS zone group managed externally)
  # ---------------------------------------------------------------------------
  ai_search_definition = {
    main = {
      existing_resource_id         = var.ai_search_resource_id
      private_dns_zone_resource_id = var.ai_search_private_dns_zone_resource_id
      diagnostic_settings = {
        main_diag = {
          workspace_resource_id = var.log_analytics_workspace_id
        }
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Deployments de modelos
  # ---------------------------------------------------------------------------
  ai_model_deployments = {
    gpt4o = {
      name = "gpt-4o"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o"
        version = "2024-11-20"
      }
      scale = {
        type     = "GlobalStandard"
        capacity = 10
      }
    }
  }

  # ---------------------------------------------------------------------------
  # AI Foundry account diagnostics
  # ---------------------------------------------------------------------------
  diagnostic_settings = {
    main = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  tags = var.tags
}
