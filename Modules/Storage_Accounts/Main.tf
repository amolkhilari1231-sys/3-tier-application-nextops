resource "azurerm_storage_account" "Storage_Account" {
    for_each = var.storage_accounts
  name                     = each.value.name
  resource_group_name      = var.rgs
  location                 = var.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  
}