provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-openai-advanced"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-openai-advanced"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "endpoints" {
  name                 = "snet-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai" {
  name                  = "openai-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-openai-advanced"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "openai" {
  source = "../../"

  name                  = "openai-advanced-example"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  custom_subdomain_name = "openai-advanced-example"

  model_deployments = {
    "gpt-4" = {
      model_name    = "gpt-4"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = 20
    }
    "gpt-35-turbo" = {
      model_name    = "gpt-35-turbo"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = 30
    }
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.endpoints.id
  private_dns_zone_id        = azurerm_private_dns_zone.openai.id

  enable_managed_identity = true

  network_acls = {
    default_action = "Deny"
    ip_rules       = []
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    Environment = "staging"
    Example     = "advanced"
  }
}

output "endpoint" {
  value = module.openai.endpoint
}

output "private_endpoint_ip" {
  value = module.openai.private_endpoint_ip
}
