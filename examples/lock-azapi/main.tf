resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "azapi_resource" "rg" {
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  location = "swedencentral"
  name     = "rg-${random_pet.name.id}"
}

# In ordinary usage, the lock attribute value would be set to var.lock.
module "avm_interfaces" {
  source = "../../"
  lock = {
    kind = "CanNotDelete"
  }
}

resource "azapi_resource" "lock" {
  type      = module.avm_interfaces.lock_azapi.type
  body      = module.avm_interfaces.lock_azapi.body
  name      = module.avm_interfaces.lock_azapi.name != null ? module.avm_interfaces.lock_azapi.name : "lock-${azapi_resource.rg.name}"
  parent_id = azapi_resource.rg.id
}
