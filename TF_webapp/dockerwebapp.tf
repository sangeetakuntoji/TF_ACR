terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.69.0"
    }
  }
}
provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "dev-rg"
    storage_account_name = "devxyzstorageac01"
    container_name       = "devconatiner"
    key                  = "devwebapp.tfstate"
  }
}


resource "azurerm_app_service_plan" "appplan" {
  name                = "${var.name}-appserviceplan"
  location            = var.location
  resource_group_name = "${var.name}-rg"
  kind                = "Linux"
  reserved            = true # required for Linux plans, might need to be in a properties thing
  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_app_service" "webapp" {
  name                = "${var.name}appservice001"
  location            = var.location
  resource_group_name = "${var.name}-rg"
  app_service_plan_id = azurerm_app_service_plan.appplan.id
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = azurerm_container_registry.registry.0.login_server
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.registry.0.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.registry.0.admin_password
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }