data "azapi_resource_list" "role_definitions" {
  count     = var.role_assignment_definition_lookup_enabled ? 1 : 0
  type      = "Microsoft.Authorization/roleDefinitions@2022-04-01"
  parent_id = var.role_assignment_definition_scope == null ? "/" : var.role_assignment_definition_scope
  response_export_values = {
    results = "value[].{id: id, role_name: properties.roleName}"
  }
}
