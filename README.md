<!-- BEGIN_TF_DOCS -->
# terraform-azure-avm-utl-interfaces

This module helps module authors using AzAPI.
It transforms the AVM interface data into AzAPI resource data.

## Usage

Pass in the values form your interface variables into this module, then use the output values to create the AzAPI resources.

```hcl
# Pass your AVM interface values into this module
module "avm_interfaecs" {
  source  = "azure/avm-utl-interfaces/azure"
  version = # your version here

  diagnostic_settings = var.diagnostic_settings
  # ... add more interface values here
}

# Easily create the AzAPI resources
resource "azapi_resource" "diagnostic_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  name    = each.value.name
  type    = each.value.type
  body    = each.value.body
  parent_id = azapi_resource.my_module_resource.id
}
```

### Role Assignments

In order to create the role assignments resource in an idempotent manner, you must supply the `var.role_assignment_definition_scope` value.
For most resources this should be the subscription resource id, e.g. `/subscriptions/00000000-0000-0000-0000-000000000000`.
However, for resources deployed at management group scope then the management group resource id should be used, e.g. `/providers/Microsoft.Management/managementGroups/myMg`.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.9)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.0)

## Resources

The following resources are used by this module:

- [azapi_resource_list.role_definitions](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description:   A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
  - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
  - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
  - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
  - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
  - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
  - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
  - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
  - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_role_assignment_definition_lookup_enabled"></a> [role\_assignment\_definition\_lookup\_enabled](#input\_role\_assignment\_definition\_lookup\_enabled)

Description: A control to disable the lookup of role definitions when creating role assignments.  
If you disable this then all role assignments must be supplied with a `role_definition_id_or_name` that is a valid role definition ID.

Type: `bool`

Default: `true`

### <a name="input_role_assignment_definition_scope"></a> [role\_assignment\_definition\_scope](#input\_role\_assignment\_definition\_scope)

Description: The scope at which the role assignments should be created.  
This is typically the resource ID of the subscription of the reosurce, but could also be the management group for resources deployed there.

Must be specified when `role_assignments` are defined.

Type: `string`

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) No effect when using AzAPI.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_diagnostic_settings_azapi"></a> [diagnostic\_settings\_azapi](#output\_diagnostic\_settings\_azapi)

Description: A map of the diagnostic settings resource data for use with azapi.

### <a name="output_role_assignments_azapi"></a> [role\_assignments\_azapi](#output\_role\_assignments\_azapi)

Description: A map of the role assignments resource data for use with azapi.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->