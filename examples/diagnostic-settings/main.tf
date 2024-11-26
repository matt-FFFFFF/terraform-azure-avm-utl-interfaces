resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "azapi_resource" "rg" {
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  name     = "rg-${random_pet.name.id}"
  location = "swedencentral"
}

resource "azapi_resource" "law" {
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  name      = "law-${random_pet.name.id}"
  location  = azapi_resource.rg.location
  parent_id = azapi_resource.rg.id
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
}

resource "azapi_resource" "stg" {
  type      = "Microsoft.Storage/storageAccounts@2023-05-01"
  name      = "stg${replace(random_pet.name.id, "-", "")}"
  location  = azapi_resource.rg.location
  parent_id = azapi_resource.rg.id
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
}

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
  for_each  = module.avm_interfaces.diagnostic_settings_azapi
  name      = each.value.name
  type      = each.value.type
  location  = azapi_resource.rg.location
  body      = each.value.body
  parent_id = "${azapi_resource.stg.id}/blobServices/default"
}