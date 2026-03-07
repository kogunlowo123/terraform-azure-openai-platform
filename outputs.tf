output "endpoint" {
  description = "The endpoint URL of the Azure OpenAI Cognitive Services account."
  value       = azurerm_cognitive_account.this.endpoint
}

output "primary_key" {
  description = "The primary access key for the Azure OpenAI Cognitive Services account."
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}

output "deployment_ids" {
  description = "Map of deployment names to their resource IDs."
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.id }
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint, if created."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management instance, if created."
  value       = var.enable_apim ? azurerm_api_management.this[0].gateway_url : null
}
