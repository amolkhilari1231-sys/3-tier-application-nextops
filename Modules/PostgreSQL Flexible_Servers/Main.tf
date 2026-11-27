data "azurerm_virtual_network" "vnet" {
  for_each            = var.PostgreSQL
  name                = each.value.vnet_name
  resource_group_name = var.rgs
}

data "azurerm_subnet" "subnet" {
  for_each             = var.PostgreSQL
  name                 = each.value.posrgresql_subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = var.rgs
}
resource "azurerm_private_dns_zone" "dns_zone" {
  for_each            = var.PostgreSQL
  name                = each.value.dns_zone_name
  resource_group_name = var.rgs
}

resource "azurerm_private_dns_zone_virtual_network_link" "Private_DNS_link" {
  for_each            = var.PostgreSQL
  name                = each.value.private_DNS_link_name
  private_dns_zone_id = azurerm_private_dns_zone.dns_zone[each.key].id
  virtual_network_id  = data.azurerm_virtual_network.vnet[each.key].id
  depends_on          = [azurerm_private_dns_zone.dns_zone]
}

resource "azurerm_postgresql_flexible_server" "PostgreSQL" {
  for_each            = var.PostgreSQL
  name                = each.value.postgreSQL_server_name
  resource_group_name = var.rgs
  location            = var.location
  version             = "12"
  #   delegated_subnet_id           = data.azurerm_subnet.subnet[each.key].id
  #   private_dns_zone_id           = azurerm_private_dns_zone.dns_zone[each.key].id
  public_network_access_enabled = true
  administrator_login           = each.value.administrator_login
  administrator_password        = each.value.administrator_password
  zone                          = each.value.zone

  storage_mb   = each.value.storage_mb
  storage_tier = each.value.storage_tier

  sku_name = each.value.sku_name
  #   depends_on = [azurerm_private_dns_zone_virtual_network_link.Private_DNS_link]
}

# PostgreSQL Database Creation

resource "azurerm_postgresql_flexible_server_database" "database" {

  for_each = {
    for key, value in var.PostgreSQL :
    key => value
    if try(value.database_name, "") != ""
  }

  name = each.value.database_name

  server_id = azurerm_postgresql_flexible_server.PostgreSQL[each.key].id

  charset   = "UTF8"
  collation = "en_US.utf8"
}


resource "azurerm_postgresql_flexible_server_firewall_rule" "laptop" {
  for_each = var.PostgreSQL

  name      = "Allow-My-Laptop"
  server_id = azurerm_postgresql_flexible_server.PostgreSQL[each.key].id

  start_ip_address = "223.233.82.228"
  end_ip_address   = "223.233.82.228"
}
resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  for_each  = var.PostgreSQL
  name      = each.value.extensions_name
  server_id = azurerm_postgresql_flexible_server.PostgreSQL[each.key].id

  value = join(",", distinct(concat(
    try(each.value.existing_allowed_extensions, []),
    ["pgcrypto"]
  )))
}