resource "azurerm_service_plan" "App_Service_Plan" {
    for_each = var.app_service_plan
  name                = each.value.name
  resource_group_name = var.rgs
  location            = var.location
  os_type             = "Linux"
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_web_app" "webapp" {
  depends_on = [azurerm_service_plan.App_Service_Plan]
  for_each = var.app_service_plan
  name                = each.value.webapp_name
  location            = var.location
  resource_group_name = var.rgs

  service_plan_id = azurerm_service_plan.App_Service_Plan[each.key].id

  https_only = true

  site_config {
    always_on = true

    application_stack {
      python_version = "3.12"
    }

    app_command_line = "python -m uvicorn main:app --host 0.0.0.0 --port 8000"
  }

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    WEBSITES_PORT                  = "8000"
  }

  tags = {
    Environment = "Preprod"
    ManagedBy   = "Terraform"
  }
}