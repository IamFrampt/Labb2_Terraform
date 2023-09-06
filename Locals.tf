locals {
  RGname = azurerm_resource_group.PolisApp_Resource_Group.name
  RGlocation = azurerm_resource_group.PolisApp_Resource_Group.location
  FA_DEFAULT_KEY = data.azurerm_function_app_host_keys.FA_KEY.default_function_key
}