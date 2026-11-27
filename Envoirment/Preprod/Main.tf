module "resource_group" {
  source   = "../../Modules/resource_Groups"
  rgs      = var.rgs
  location = var.location
}
module "storage_account" {
  depends_on       = [module.resource_group]
  source           = "../../Modules/Storage_Accounts"
  rgs              = var.rgs
  location         = var.location
  storage_accounts = var.storage_accounts
}
module "virtual_network" {
  depends_on = [module.resource_group]
  source     = "../../Modules/Virtual_Network"
  rgs        = var.rgs
  location   = var.location
  vnets      = var.vnets

}
module "subnet" {
  depends_on = [module.virtual_network]
  source     = "../../Modules/Subnets"
  rgs        = var.rgs
  location   = var.location
  subnets    = var.subnets
}
module "virtual_machine" {
  depends_on = [module.subnet]
  source     = "../../Modules/Virtual_machine"
  rgs        = var.rgs
  location   = var.location
  vms        = var.vms
}

module "PostgreSQL_Flexible_Servers" {
  depends_on = [module.subnet]
  source     = "../../Modules/PostgreSQL Flexible_Servers"
  rgs        = var.rgs
  location   = var.location
  PostgreSQL = var.PostgreSQL
}

module "App_Service_Plan" {
  depends_on       = [module.resource_group]
  source           = "../../Modules/App_Service_Plan"
  rgs              = var.rgs
  location         = var.location
  app_service_plan = var.app_service_plan
}

module "application_gateway" {
  depends_on  = [module.subnet]
  source      = "../../Modules/Applicaation_gataway"
  rgs         = var.rgs
  location    = var.location
  App_Gateway = var.App_Gateway
}