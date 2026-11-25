resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  name                 = each.value.name
  resource_group_name  = var.rgs
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.address_prefixes


dynamic "delegation" {
  for_each = each.value.name == "Database_subnet" ? [1] : []

  content {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

}