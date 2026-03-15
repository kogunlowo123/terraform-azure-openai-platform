module "test" {
  source = "../"

  name                  = "openai-platform-test"
  resource_group_name   = "rg-openai-test"
  location              = "eastus2"
  sku_name              = "S0"
  custom_subdomain_name = "openai-test-subdomain"

  model_deployments = {
    gpt-4 = {
      model_name    = "gpt-4"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = 10
    }
  }

  enable_private_endpoint = false
  enable_managed_identity = true
  enable_diagnostics      = false
  enable_apim             = false

  network_acls = {
    default_action = "Deny"
    ip_rules       = []
  }

  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}
