locals {
  # role_assignments_definitions_substring = lower("providers/Microsoft.Authorization/roleDefinitions")
  # role_assignments_role_names_to_lookup = toset([
  #   for _, v in var.role_assignments : v.role_definition_id_or_name if !strcontains(lower(v.role_definition_id_or_name), local.role_assignments_definitions_substring)
  # ])
  role_assignments_role_name_to_resource_id = {
    for res in data.azapi_resource_list.role_definitions.output.results : res.role_name => res.id
  }
  role_assignments_role_definition_resource_ids = {
    for k, v in var.role_assignments : k => lookup(local.role_assignments_role_name_to_resource_id, v.role_definition_id_or_name, v.role_definition_id_or_name)
  }
  role_assignments_type = "Microsoft.Authorization/roleAssignments@2022-04-01"
  role_assignments_azapi = {
    for k, v in var.role_assignments : k => {
      type = local.role_assignments_type
      name = uuidv5("url", format("%s%s", v.principal_id, local.role_assignments_role_definition_resource_ids[k]))
      body = {
        properties = {
          principalId                        = v.principal_id
          roleDefinitionId                   = local.role_assignments_role_definition_resource_ids[k]
          conditionVersion                   = lookup(v, "condition_version", null)
          condition                          = lookup(v, "condition", null)
          description                        = lookup(v, "description", null)
          principalType                      = lookup(v, "principal_type", null)
          delegatedManagedIdentityResourceId = lookup(v, "delegated_managed_identity_resource_id", null)
        }
      }
    }
  }
}
