output "private_endpoints_azapi" {
  value       = local.private_endpoints
  description = "Private endpoints for the azapi_resource."
}

output "private_dns_zone_groups_azapi" {
  value       = local.private_dns_zone_groups
  description = "Private DNS zone groups for the azapi_resource."
}
