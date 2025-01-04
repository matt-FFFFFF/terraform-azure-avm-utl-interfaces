locals {
  managed_identities = {
    type         = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.managed_identities.user_assigned_resource_ids
  }
}
