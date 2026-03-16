variable "name" {
  description = "The name of the Azure OpenAI Cognitive Services account."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group for all resources."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Cognitive Services account."
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "The custom subdomain name for the Cognitive Services account."
  type        = string
}

variable "model_deployments" {
  description = "Map of model deployments to create."
  type = map(object({
    model_name    = string
    model_version = string
    sku_name      = string
    sku_capacity  = number
  }))
  default = {}
}

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for the Cognitive Services account."
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone for the private endpoint."
  type        = string
  default     = null
}

variable "enable_managed_identity" {
  description = "Whether to create a user-assigned managed identity."
  type        = bool
  default     = true
}

variable "network_acls" {
  description = "Network ACL configuration for the Cognitive Services account."
  type = object({
    default_action        = string
    ip_rules              = optional(list(string), [])
    virtual_network_rules = optional(list(string), [])
  })
  default = {
    default_action        = "Deny"
    ip_rules              = []
    virtual_network_rules = []
  }
}

variable "enable_apim" {
  description = "Whether to create an API Management instance for the OpenAI service."
  type        = bool
  default     = false
}

variable "apim_name" {
  description = "The name of the API Management instance."
  type        = string
  default     = null
}

variable "apim_sku" {
  description = "The SKU of the API Management instance (e.g., Developer_1, Standard_1)."
  type        = string
  default     = "Developer_1"
}

variable "apim_publisher_name" {
  description = "The publisher name for the API Management instance."
  type        = string
  default     = null
}

variable "apim_publisher_email" {
  description = "The publisher email for the API Management instance."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Whether to enable diagnostic settings for the OpenAI service."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostic settings."
  type        = string
  default     = null
}

variable "content_filter_name" {
  description = "The name of the content filter policy to apply to deployments."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
