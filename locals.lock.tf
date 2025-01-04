locals {
  lock_type = "Microsoft.Authorization/locks@2020-05-01"
  lock_azapi = var.lock != null ? {
    type = local.lock_type
    name = lookup(var.lock, "name", null)
    body = {
      properties = {
        level = var.lock.kind
      }
    }
  } : null
}
