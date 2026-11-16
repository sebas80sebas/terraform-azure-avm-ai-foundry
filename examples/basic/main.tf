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
# Example basic
# Minimal deployment: AI Foundry account + one project. Public access, no
# external dependencies. Ideal for PoC, demos, and first-time exploration.
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "rg-${var.base_name}-aifoundry-basic"
}

module "ai_foundry" {
  source = "../.."

  base_name                  = var.base_name
  location                   = var.location
  resource_group_resource_id = azurerm_resource_group.this.id

  ai_projects = {
    main = {
      name         = "proj-${var.base_name}-main"
      display_name = "Main Project"
      description  = "Main AI Foundry project"
    }
  }

  tags = var.tags
}
