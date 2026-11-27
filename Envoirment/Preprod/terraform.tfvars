rgs      = "my_Perprod_RG"
location = "centralindia"

storage_accounts = {
  stg1 = {
    name                     = "stg1nextopsapplication"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

vnets = {
  vnet1 = {
    name          = "Hub_vnet1"
    address_space = ["10.0.0.0/16"]
  }
  vnet2 = {
    name          = "Spoke_vnet2"
    address_space = ["10.20.0.0/16"]
  }
}

subnets = {
  subnet1 = {
    name             = "Frontend_subnet"
    vnet_name        = "Spoke_vnet2"
    address_prefixes = ["10.20.10.0/24"]
  }
  subnet2 = {
    name             = "Backend_subnet"
    vnet_name        = "Spoke_vnet2"
    address_prefixes = ["10.20.20.0/24"]
  }
  subnet3 = {
    name             = "Database_subnet"
    vnet_name        = "Hub_vnet1"
    address_prefixes = ["10.0.50.0/24"]
  }
  subnet4 = {
    name             = "Gateway_subnet"
    vnet_name        = "Hub_vnet1"
    address_prefixes = ["10.0.100.0/24"]
  }
}

vms = {
  vm1 = {
    nic_name       = "vm1-nic"
    subnet_name    = "Frontend_subnet"
    vnet_name      = "Spoke_vnet2"
    vm_name        = "nextopsvm1"
    size           = "Standard_B2s_v2"
    admin_username = "adminuser"
    admin_password = "Admin@1234"
    nsg_name       = "vm1-nsg"
  }
}
PostgreSQL = {
  psql1 = {
    dns_zone_name          = "Nestops.postgres.database.azure.com"
    vnet_name              = "Hub_vnet1"
    private_DNS_link_name  = "nextops.com"
    postgreSQL_server_name = "nextops-psqlflexibleserver"
    posrgresql_subnet_name = "Database_subnet"
    administrator_login    = "psqladmin"
    administrator_password = "Admin@1234"
    zone                   = "1"
    storage_mb             = 32768
    storage_tier           = "P4"
    sku_name               = "GP_Standard_D2s_v3"
    database_name          = "nextopsdb"
    extensions_name        = "azure.extensions"

    existing_allowed_extensions = []
  }
}

app_service_plan = {
  plan1 = {
    name        = "nextopsappserviceplan"
    sku_name    = "P1mv4"
    webapp_name = "nextopswebapp"
  }
}

App_Gateway = {
  appgw1 = {
    Subnet_name          = "Gateway_subnet"
    vnet_name            = "Hub_vnet1"
    pip_name              = "nextopsappgw-pip"
    appgw_name            = "nextopsappgw"

  }
}