resource "azurerm_windows_function_app" "PolisApi_Function" {
  name                = "PolisApi"
  resource_group_name = local.RGname
  location            = local.RGlocation

  storage_account_name       = azurerm_storage_account.PolisAPI_FA_SA.name
  storage_account_access_key = azurerm_storage_account.PolisAPI_FA_SA.primary_access_key
  service_plan_id            = azurerm_service_plan.PolisAPI_ASP.id

  site_config {}

  depends_on = [ azurerm_service_plan.PolisAPI_ASP,
                 azurerm_storage_account.PolisAPI_FA_SA]

}

resource "azurerm_service_plan" "PolisAPI_ASP" {
  name                = "polisapi-asp"
  location            = local.RGlocation
  resource_group_name = local.RGname
  os_type             = "Windows"
  sku_name            = "Y1"
  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group ]
}

resource "azurerm_storage_account" "PolisAPI_FA_SA" {
  name                     = "polisapifunctionmikael"
  resource_group_name      = local.RGname
  location                 = local.RGlocation
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"

  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group ]
}

resource "azurerm_app_service_source_control" "Source_Code" {
  app_id   = azurerm_windows_function_app.PolisApi_Function.id
  repo_url = "https://github.com/IamFrampt/Labb2PolisFunctionApp.git"
  branch   = "master"
  depends_on = [ azurerm_windows_function_app.PolisApi_Function,
                 azurerm_app_service_source_control_token.token ]
}

resource "azurerm_app_service_source_control_token" "token" {
  type  = "GitHub"
  token = "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"
  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group ]
}

# Function key¨

data "azurerm_function_app_host_keys" "FA_KEY" {
  name                = "PolisApi"
  resource_group_name = local.RGname

  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group,
                 azurerm_windows_function_app.PolisApi_Function]
}
