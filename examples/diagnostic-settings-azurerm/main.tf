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

resource "azurerm_monitor_diagnostic_setting" "example" {
  for_each                       = module.avm_interfaces.diagnostic_settings_azurerm
  name                           = each.value.name
  target_resource_id             = "${azapi_resource.stg.id}/blobServices/default"
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  partner_solution_id            = each.value.partner_solution_id
  storage_account_id             = each.value.storage_account_id

  dynamic "enabled_log" {
    for_each = each.value.enabled_log
    content {
      category       = enabled_log.value.category
      category_group = enabled_log.value.category_group
    }
  }

  dynamic "metric" {
    for_each = each.value.enabled_metric
    content {
      category = metric.value.category
    }
  }
}
