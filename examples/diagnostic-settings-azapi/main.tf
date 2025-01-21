resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "azapi_resource" "rg" {
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  location = "swedencentral"
  name     = "rg-${random_pet.name.id}"
}

resource "azapi_resource" "law" {
  type = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      sku = {
        name = "PerGB2018"
      }
      retentionInDays = 30
      workspaceCapping = {
        dailyQuotaGb = 1
      }
    }
  }
  location  = azapi_resource.rg.location
  name      = "law-${random_pet.name.id}"
  parent_id = azapi_resource.rg.id
}

resource "azapi_resource" "stg" {
  type = "Microsoft.Storage/storageAccounts@2023-05-01"
  body = {
    kind = "StorageV2"
    properties = {
      accessTier                   = "Hot"
      allowBlobPublicAccess        = true
      allowCrossTenantReplication  = true
      allowSharedKeyAccess         = true
      defaultToOAuthAuthentication = false
      encryption = {
        keySource = "Microsoft.Storage"
        services = {
          queue = {
            keyType = "Service"
          }
          table = {
            keyType = "Service"
          }
        }
      }
      isHnsEnabled      = false
      isNfsV3Enabled    = false
      isSftpEnabled     = false
      minimumTlsVersion = "TLS1_2"
      networkAcls = {
        defaultAction = "Allow"
      }
      publicNetworkAccess      = "Enabled"
      supportsHttpsTrafficOnly = true
    }
    sku = {
      name = "Standard_LRS"
    }
  }
  location  = azapi_resource.rg.location
  name      = "stg${replace(random_pet.name.id, "-", "")}"
  parent_id = azapi_resource.rg.id
}

# In ordinary usage, the diagnostic_settings attribute value would be set to var.diagnostic_settings.
# However, because we are creating the log analytics workspace in this example, we need to set the workspace_resource_id attribute value to the ID of the log analytics workspace.
module "avm_interfaces" {
  source = "../../"
  diagnostic_settings = {
    example = {
      name                           = "tolaw"
      log_groups                     = ["allLogs"]
      metric_categories              = ["AllMetrics"]
      log_analytics_destination_type = "Dedicated"
      workspace_resource_id          = azapi_resource.law.id
    }
  }
}

resource "azapi_resource" "diag_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  type      = each.value.type
  body      = each.value.body
  name      = each.value.name
  parent_id = "${azapi_resource.stg.id}/blobServices/default"
}
