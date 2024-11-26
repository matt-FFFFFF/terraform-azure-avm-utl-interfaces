
# These locals create the data for the azapi_resources from the var.diagnostic_settings variable
locals {
  diagnostic_settings_type = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"

  diagnostic_settings_azapi = {
    for k, v in var.diagnostic_settings : k => {
      type = local.diagnostic_settings_type
      name = v.name
      body = {
        properties = {
          eventHubAuthorizationRuleId = lookup(v, "event_hub_authorization_rule_resource_id", null)
          eventHubName                = lookup(v, "event_hub_name", null)
          logAnalyticsDestinationType = lookup(v, "log_analytics_destination_type", null)
          logs = setunion(
            [
              for log_group in v.log_groups : {
                category      = null
                categoryGroup = log_group
                enabled       = true
              }
            ],
            [
              for log_category in v.log_categories : {
                category      = log_category
                categoryGroup = null
                enabled       = true
              }
            ]
          )
          marketplacePartnerId = lookup(v, "marketplace_partner_resource_id", null)
          metrics = length(v.metric_categories) > 0 ? [
            for category in v.metric_categories :
            {
              category = category
              enabled  = true
            }
          ] : null
          storageAccountId = lookup(v, "storage_account_resource_id", null)
          workspaceId      = lookup(v, "workspace_resource_id", null)
        }
      }
    }
  }

  diagnostic_settings_azurerm = {
    for k, v in var.diagnostic_settings : k => {
      name                           = v.name
      eventhub_authorization_rule_id = lookup(v, "event_hub_authorization_rule_resource_id", null)
      eventhub_name                  = lookup(v, "event_hub_name", null)
      log_analytics_workspace_id     = lookup(v, "workspace_resource_id", null)
      partner_solution_id            = lookup(v, "marketplace_partner_resource_id", null)
      storage_account_id             = lookup(v, "storage_account_resource_id", null)
      enabled_log = setunion(
        [
          for log_group in v.log_groups : {
            category       = null
            category_group = log_group
          }
        ],
        [
          for log_category in v.log_categories : {
            category       = log_category
            category_group = null
          }
        ]
      )
      enabled_metric = toset([
        for metric in v.metric_categories : {
          category = metric
        }
      ])
    }
  }
}
