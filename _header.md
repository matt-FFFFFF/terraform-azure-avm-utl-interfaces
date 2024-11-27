# terraform-azure-avm-utl-interfaces

This module helps module authors using AzAPI.
It transforms the AVM interface data into AzAPI resource data.

## Usage

Pass in the values form your interface variables into this module, then use the output values to create the AzAPI resources.

```hcl
# Pass you AVM interface values into this module
module "avm_interfaecs" {
  source = "azure/avm-utl-interfaces/azure"

  diagnostic_settings = var.diagnostic_settings
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
