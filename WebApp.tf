resource "azurerm_service_plan" "ASP_ME" {
  name                = "ASP_ME"
  resource_group_name = local.RGname
  location            = local.RGlocation
  os_type             = "Linux"
  sku_name            = "B1"

  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group ]
}

# resource "azurerm_windows_web_app" "webapp_me" {
#   name                = "Polisappmikael"
#   resource_group_name = local.RGname
#   location            = azurerm_service_plan.ASP_ME.location
#   service_plan_id     = azurerm_service_plan.ASP_ME.id

#   site_config {
#     application_stack {
#       current_stack = "dotnet"
#       dotnet_version = "v7.0"
#     }
#   }

#   app_settings = {
#     "ApiSecret" = local.FA_KEKE
#   }

#   depends_on = [
#     azurerm_service_plan.ASP_ME,
#     data.azurerm_function_app_host_keys.FA_KEY
#   ]
# }

resource "azurerm_linux_web_app" "webapp_me" {
  name                = "Polisappmikael"
  resource_group_name = local.RGname
  location            = azurerm_service_plan.ASP_ME.location
  service_plan_id     = azurerm_service_plan.ASP_ME.id

  site_config {
    application_stack {
      dotnet_version = "7.0"
    }
  }

  app_settings = {
    "ApiSecret" = local.FA_DEFAULT_KEY
  }

  depends_on = [
    azurerm_service_plan.ASP_ME,
    data.azurerm_function_app_host_keys.FA_KEY
  ]
}

# The code -----------------------------------------------------------------------------------

resource "azurerm_app_service_source_control" "Production_Code" {
  app_id   = azurerm_linux_web_app.webapp_me.id
  repo_url = "https://github.com/IamFrampt/PolisApp_Labb2.git"
  branch   = "master"
  depends_on = [ azurerm_linux_web_app.webapp_me,
   azurerm_app_service_source_control_token.token]
}

## Connect to log analytics 

resource "azurerm_storage_account" "SA_webapp_Logs" {
  name                     = "webapplogsmikael"
  resource_group_name      = local.RGname
  location                 = local.RGlocation
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group ]
}

resource "azurerm_monitor_diagnostic_setting" "Webapp_settings" {
  name               = "webapp-settings"
  target_resource_id = azurerm_linux_web_app.webapp_me.id
  storage_account_id = azurerm_storage_account.SA_webapp_Logs.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }

  depends_on = [ azurerm_linux_web_app.webapp_me,
                 azurerm_storage_account.SA_webapp_Logs]
}

## Connect to Application Insight - Optional

resource "azurerm_application_insights" "webapp_AppInsights" {
  name                = "webapp-appinsights"
  location            = local.RGlocation
  resource_group_name = local.RGname
  application_type    = "web"

  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group ]
}

resource "azurerm_application_insights_smart_detection_rule" "Mikael_WA_DS" {
  name                    = "Slow server response time"
  application_insights_id = azurerm_application_insights.webapp_AppInsights.id
  enabled                 = true

  depends_on = [ azurerm_application_insights.webapp_AppInsights ]
}

