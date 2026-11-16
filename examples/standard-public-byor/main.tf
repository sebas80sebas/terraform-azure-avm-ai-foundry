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
# Example standard-public-byor
# Full public-access deployment using existing resources (BYOR):
#   - AI Search created by the dedicated module terraform-azure-avm-search-service
#   - Storage Account, Cosmos DB and Key Vault provisioned externally
# Ideal for environments where data resources already exist or are managed
# by other teams/modules.
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "rg-${var.base_name}-aifoundry-byor"
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
  }

  # ---------------------------------------------------------------------------
  # Proyectos con conexiones a recursos existentes (BYOR)
  # ---------------------------------------------------------------------------
  ai_projects = {
    main = {
      name                       = "proj-${var.base_name}-main"
      display_name               = "Main Project"
      description                = "Proyecto principal con conexiones BYOR"
      create_project_connections = true

      # Reference to the AI Search created by the dedicated module
      ai_search_connection = {
        existing_resource_id = var.ai_search_resource_id
      }

      # Referencia a Cosmos DB existente
      cosmos_db_connection = {
        existing_resource_id = var.cosmos_db_resource_id
      }

      # Referencia a Key Vault existente
      key_vault_connection = {
        existing_resource_id = var.key_vault_resource_id
      }

      # Referencia a Storage Account existente
      storage_account_connection = {
        existing_resource_id = var.storage_account_resource_id
      }
    }
  }

  # ---------------------------------------------------------------------------
  # AI Search definition (BYOR - reference only, resource is not created here)
  # The AI Search resource was created by the terraform-azure-avm-search-service module
  # ---------------------------------------------------------------------------
  ai_search_definition = {
    main = {
      existing_resource_id = var.ai_search_resource_id
      diagnostic_settings = {
        main_diag = {
          workspace_resource_id = var.log_analytics_workspace_id
        }
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Deployments de modelos (OpenAI)
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
    text_embedding = {
      name = "text-embedding-3-large"
      model = {
        format  = "OpenAI"
        name    = "text-embedding-3-large"
        version = "1"
      }
      scale = {
        type     = "Standard"
        capacity = 120
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
