locals {

  private_endpoints_type = "Microsoft.Network/privateEndpoints@2024-05-01"

  # these computed names are used if the user does not provide their own for either the private endpoint, nic, or private service connection
  private_endpoint_computed_name = {
    for k, v in var.private_endpoints : k => "pe-${v.subresource_name}-${uuidv5("url", format("%s", var.private_endpoints_scope))}"
  }

  # if the private endpoint name is provided (var.private_endpoints.name), we use this as the suffix for the other resources
  custom_nic_computed_name = {
    for k, v in var.private_endpoints : k => v.name != null ? "nic-${v.subresource_name}-${v.name}" : "nic-${local.private_endpoint_computed_name[k]}"
  }

  psc_computed_name = {
    for k, v in var.private_endpoints : k => v.name != null ? "psc-${v.subresource_name}-${v.name}" : "psc-${local.private_endpoint_computed_name[k]}"
  }

  private_endpoints = {
    for k, v in var.private_endpoints : k => {
      type = local.private_endpoints_type
      name = v.name != null ? v.name : local.private_endpoint_computed_name[k]
      tags = v.tags
      body = {
        properties = {
          applicationSecurityGroups = v.application_security_group_associations != null ? [
            for application_security_group_resource_id in v.application_security_group_associations : {
              id = application_security_group_resource_id
            }
          ] : []
          customNetworkInterfaceName = v.network_interface_name != null ? v.network_interface_name : local.custom_nic_computed_name[k]
          ipConfigurations = v.ip_configurations != null ? [
            for ip_configuration in v.ip_configurations : {
              name             = try(ip_configuration.name, null)
              privateIPAddress = try(ip_configuration.private_ip_address, null)
            }
          ] : []
          privateLinkServiceConnections = [
            {
              name = v.private_service_connection_name != null ? v.private_service_connection_name : local.psc_computed_name[k]
              properties = {
                privateLinkServiceId = var.private_endpoints_scope
                groupIds             = [v.subresource_name]
              }
            }
          ]
          subnet = {
            id = v.subnet_resource_id
          }
        }
      }
    }
  }

  private_dns_zone_group_type = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01"

  private_dns_zone_groups = {
    for k, v in var.private_endpoints : k => {
      type = local.private_dns_zone_group_type
      name = v.private_dns_zone_group_name
      body = {
        properties = {
          privateDnsZoneConfigs = [
            for private_dns_zone_resource_id in v.private_dns_zone_resource_ids : {
              name = try(v.private_dns_zone_group_name, "default")
              properties = {
                privateDnsZoneId = private_dns_zone_resource_id
              }
            }
          ]
        }
      }
    }
    if var.private_endpoints_manage_dns_zone_group
  }
}
