locals {
  # Common resource naming
  resource_prefix = var.name

  # Merge default tags with user-provided tags
  default_tags = {
    ManagedBy = "Terraform"
    Module    = "terraform-azure-openai-platform"
  }
  tags = merge(local.default_tags, var.tags)

  # APIM SKU parsing (format: "Name_Capacity" e.g. "Developer_1")
  apim_sku_parts    = var.enable_apim ? split("_", var.apim_sku) : ["Developer", "1"]
  apim_sku_name     = local.apim_sku_parts[0]
  apim_sku_capacity = tonumber(local.apim_sku_parts[1])

  # OpenAI API base path for APIM
  openai_api_url = "${azurerm_cognitive_account.this.endpoint}openai/"

  # Private endpoint name
  private_endpoint_name = "${var.name}-pe"

  # Managed identity name
  managed_identity_name = "${var.name}-identity"
}
