
resource "azurerm_virtual_network" "Webapp_VNET" {
  name                = "webapp-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.RGlocation
  resource_group_name = local.RGname

  depends_on = [ azurerm_resource_group.PolisApp_Resource_Group ]
}

resource "azurerm_subnet" "WebApp_Subnet" {
  name                 = "webapp-subnet"
  resource_group_name  = local.RGname
  virtual_network_name = azurerm_virtual_network.Webapp_VNET.name
  address_prefixes     = ["10.0.1.0/24"]

   delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

    depends_on = [ azurerm_virtual_network.Webapp_VNET ]
}

resource "azurerm_subnet" "FA_Subnet" {
  name                 = "fa-subnet"
  resource_group_name  = local.RGname
  virtual_network_name = azurerm_virtual_network.Webapp_VNET.name
  address_prefixes     = ["10.0.2.0/24"]

   delegation {
    name = "fa-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

    depends_on = [ azurerm_virtual_network.Webapp_VNET ]
}


