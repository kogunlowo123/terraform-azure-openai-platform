# -------------------------------------------------------
# Azure OpenAI Cognitive Services Account
# -------------------------------------------------------
resource "azurerm_cognitive_account" "this" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = var.sku_name
  custom_subdomain_name = var.custom_subdomain_name

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.this[0].id]
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action = network_acls.value.default_action

      dynamic "ip_rules" {
        for_each = network_acls.value.ip_rules
        content {
          ip_address = ip_rules.value
        }
      }

      dynamic "virtual_network_rules" {
        for_each = network_acls.value.virtual_network_rules
        content {
          subnet_id = virtual_network_rules.value
        }
      }
    }
  }

  public_network_access_enabled = var.enable_private_endpoint ? false : true

  tags = local.tags
}

# -------------------------------------------------------
# Model Deployments
# -------------------------------------------------------
resource "azurerm_cognitive_deployment" "this" {
  for_each = var.model_deployments

  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.sku_capacity
  }

  dynamic "content_filter" {
    for_each = var.content_filter_name != null ? [1] : []
    content {
      name = var.content_filter_name
    }
  }
}

# -------------------------------------------------------
# User-Assigned Managed Identity
# -------------------------------------------------------
resource "azurerm_user_assigned_identity" "this" {
  count = var.enable_managed_identity ? 1 : 0

  name                = local.managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.tags
}

# -------------------------------------------------------
# Private Endpoint
# -------------------------------------------------------
resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = local.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.this.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = local.tags
}

# -------------------------------------------------------
# Azure API Management (Conditional)
# -------------------------------------------------------
resource "azurerm_api_management" "this" {
  count = var.enable_apim ? 1 : 0

  name                = var.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email

  sku_name = var.apim_sku

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_api_management_api" "openai" {
  count = var.enable_apim ? 1 : 0

  name                = "${var.name}-openai-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this[0].name
  revision            = "1"
  display_name        = "Azure OpenAI API"
  path                = "openai"
  protocols           = ["https"]
  service_url         = local.openai_api_url

  subscription_required = true
}

# -------------------------------------------------------
# Diagnostic Settings
# -------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics && var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_cognitive_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  enabled_log {
    category = "RequestResponse"
  }

  enabled_log {
    category = "Trace"
  }

  metric {
    category = "AllMetrics"
  }
}
