variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = string # NOTE: `subresource_name` can be excluded if the resource does not support multiple sub resource types (e.g. storage account supports blob, queue, etc)
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
  A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `name` - (Optional) The name of the private endpoint. One will be generated if not set.
  - `role_assignments` - (Optional) This module does not do anything with this, it is used by the parent module to create role assignments.
    - `role_definition_id_or_name` - The ID or name of the role definition to assign.
    - `principal_id` - The ID of the principal to assign the role to.
    - `description` - (Optional) A description of the role assignment.
    - `skip_service_principal_aad_check` - (Optional) Whether to skip the AAD check for service principals.
    - `condition` - (Optional) The condition under which the role assignment is active.
    - `condition_version` - (Optional) The version of the condition.
    - `delegated_managed_identity_resource_id` - (Optional) The resource ID of the delegated managed identity to assign the role to.
    - `principal_type` - (Optional) The type of principal to assign the role to. Possible values are `\"User\"`, `\"Group\"`, `\"ServicePrincipal\"`, and `\"MSI\"`.    
  - `lock` - (Optional) This module does not do anything with this, it is used by the parent module to create locks assignments.
    - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
    - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  - `tags` - (Optional) A mapping of tags to assign to the private endpoint.
  - `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
  - `subresource_name` - The name of the sub resource for the private endpoint.
  - `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
  - `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
  - `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
  - `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
  - `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
  - `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Key Vault.
  - `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `name` - The name of the IP configuration.
    - `private_ip_address` - The private IP address of the IP configuration.
  DESCRIPTION
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  nullable    = false
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
}

variable "private_endpoints_scope" {
  type        = string
  description = <<DESCRIPTION
This is typically the resource ID of the resource that the private endpoint is connected to.

Must be specified when `private_endpoints` are defined.
DESCRIPTION
  default     = null

  validation {
    condition     = length(var.private_endpoints) > 0 ? var.private_endpoints_scope != null : true
    error_message = "The private_endpoints_scope variable must be set when private_endpoints are defined."
  }
}
