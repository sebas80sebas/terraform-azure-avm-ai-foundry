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
# Example standard-public
# Full public-access deployment with resources created by the module (CYOR).
# WARNING: The CYOR pattern (create_byor = true) is for PoC/demos only.
# For production use standard-public-byor with pre-existing resources.
#
# IMPORTANT NOTE ON AI SEARCH:
# This example uses the dedicated module terraform-azure-avm-search-service to create
# AI Search (recommended pattern for this stack). The resource ID is passed to
# the AI Foundry module via ai_search_definition. AI Search is NEVER created
# directly from this module.
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "rg-${var.base_name}-aifoundry-public"
}

# NOTE: In a real deployment, AI Search would be created in a separate call
# to the terraform-azure-avm-search-service module before this module.
# This example shows the reference pattern for how to connect it.

module "ai_foundry" {
  source = "../.."

  base_name                  = var.base_name
  location                   = var.location
  resource_group_resource_id = azurerm_resource_group.this.id

  # CYOR enabled: the module will create Cosmos DB, Key Vault and Storage Account
  create_byor = true

  # ---------------------------------------------------------------------------
  # AI Foundry account configuration
  # ---------------------------------------------------------------------------
  ai_foundry = {
    disable_local_auth       = true
    allow_project_management = true
    create_ai_agent_service  = true
  }

  # ---------------------------------------------------------------------------
  # Projects with connections to resources created by the module (CYOR) and AI Search BYOR
  # ---------------------------------------------------------------------------
  ai_projects = {
    main = {
      name                       = "proj-${var.base_name}-main"
      display_name               = "Main Project"
      description                = "Proyecto principal con Standard Agents"
      create_project_connections = true

      # AI Search: reference to existing resource (BYOR via dedicated module)
      ai_search_connection = {
        existing_resource_id = var.ai_search_resource_id
      }
      # Cosmos DB, Key Vault and Storage created by this module (CYOR)
      cosmos_db_connection = {
        new_resource_map_key = "main"
      }
      key_vault_connection = {
        new_resource_map_key = "main"
      }
      storage_account_connection = {
        new_resource_map_key = "main"
      }
    }
  }

  # ---------------------------------------------------------------------------
  # AI Search: BYOR - resource created by the dedicated module terraform-azure-avm-search-service
  # ---------------------------------------------------------------------------
  ai_search_definition = {
    main = {
      existing_resource_id = var.ai_search_resource_id
    }
  }

  # ---------------------------------------------------------------------------
  # Cosmos DB (CYOR)
  # ---------------------------------------------------------------------------
  cosmosdb_definition = {
    main = {
      tags = var.tags
    }
  }

  # ---------------------------------------------------------------------------
  # Key Vault (CYOR)
  # ---------------------------------------------------------------------------
  key_vault_definition = {
    main = {
      tags = var.tags
    }
  }

  # ---------------------------------------------------------------------------
  # Storage Account (CYOR)
  # ---------------------------------------------------------------------------
  storage_account_definition = {
    main = {
      tags = var.tags
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
  # Diagnostics
  # ---------------------------------------------------------------------------
  diagnostic_settings = {
    main = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  tags = var.tags
}
