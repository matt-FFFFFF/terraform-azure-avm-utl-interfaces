data "azapi_resource_list" "role_definitions" {
  type      = "Microsoft.Authorization/roleDefinitions@2022-04-01"
  parent_id = "/"
  response_export_values = {
    results = "value[].{id: id, role_name: properties.roleName}"
  }
}
