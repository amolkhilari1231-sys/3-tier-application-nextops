
# Existing Application Gateway subnet
data "azurerm_subnet" "appgw_subnet" {
  for_each             = var.App_Gateway
  name                 = each.value.Subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = var.rgs
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw_pip" {
  for_each            = var.App_Gateway
  name                = each.value.pip_name
  location            = var.location
  resource_group_name = var.rgs

  allocation_method = "Static"
  sku               = "Standard"


}

# Application Gateway
resource "azurerm_application_gateway" "appgw" {
  for_each            = var.App_Gateway
  name                = each.value.appgw_name
  resource_group_name = var.rgs
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  # Dedicated Application Gateway subnet
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = data.azurerm_subnet.appgw_subnet[each.key].id
  }

  # Frontend Public IP
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip[each.key].id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  # VM Backend Pool
  backend_address_pool {
    name         = "vm-backend-pool"
    ip_addresses = ["10.20.10.4"]
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "vm-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "vm-health-probe"
  }

  # Health Probe
  probe {
    name                = "vm-health-probe"
    protocol            = "Http"
    path                = "/health"
    host                = "10.20.10.4"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  # HTTP Listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # Routing Rule
  request_routing_rule {
    name                       = "vm-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "vm-backend-pool"
    backend_http_settings_name = "vm-http-settings"
    priority                   = 100
  }

}
