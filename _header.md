# terraform-azure-avm-utl-interfaces

This module helps module authors using AzAPI.
It transforms the AVM interface data into AzAPI resource data.

## Usage

Pass in the values form your interface variables into this module, then use the output values to create the AzAPI resources.

```hcl
# Pass your AVM interface values into this module
module "avm_interfaces" {
  source  = "azure/avm-utl-interfaces/azure"
  version = "" # your version here

  diagnostic_settings = var.diagnostic_settings
  # ... add more interface values here
}

# Easily create the AzAPI resources
resource "azapi_resource" "diagnostic_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  name      = each.value.name
  type      = each.value.type
  body      = each.value.body
  parent_id = azapi_resource.my_module_resource.id
}
```

### Role Assignments

In order to create the role assignments resource in an idempotent manner, you must supply the `var.role_assignment_definition_scope` value.
For most resources this should be the subscription resource id, e.g. `/subscriptions/00000000-0000-0000-0000-000000000000`.
However, for resources deployed at management group scope then the management group resource id should be used, e.g. `/providers/Microsoft.Management/managementGroups/myMg`.
