output "diagnostic_settings_azapi" {
  description = "A map of the diagnostic settings resource data for use with azapi."
  value       = local.diagnostic_settings_azapi
}

output "diagnostic_settings_azurerm" {
  description = "A map of the diagnostic settings resource data for use with azurerm."
  value       = local.diagnostic_settings_azurerm
}
