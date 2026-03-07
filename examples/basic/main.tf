provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-openai-basic"
  location = "East US"
}

module "openai" {
  source = "../../"

  name                  = "openai-basic-example"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  custom_subdomain_name = "openai-basic-example"

  model_deployments = {
    "gpt-4" = {
      model_name    = "gpt-4"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = 10
    }
  }

  enable_private_endpoint = false
  enable_managed_identity = false
  enable_diagnostics      = false

  network_acls = {
    default_action = "Allow"
    ip_rules       = []
  }

  tags = {
    Environment = "dev"
    Example     = "basic"
  }
}

output "endpoint" {
  value = module.openai.endpoint
}
