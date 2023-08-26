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
    key                  = "devacr.tfstate"
  }
}

resource "azurerm_resource_group" "acr_resource_group" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.name}acr"
  resource_group_name = azurerm_resource_group.acr_resource_group.name
  location            = azurerm_resource_group.acr_resource_group.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_app_service_plan" "appplan" {
  name                = "${var.name}-appserviceplan"
  resource_group_name = azurerm_resource_group.acr_resource_group.name
  location            = azurerm_resource_group.acr_resource_group.location
  kind                = "Linux"
  reserved            = true # required for Linux plans, might need to be in a properties thing
  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_app_service" "webapp" {
  name                = "${var.name}appservice001"
  resource_group_name = azurerm_resource_group.acr_resource_group.name
  location            = azurerm_resource_group.acr_resource_group.location
  app_service_plan_id = azurerm_app_service_plan.appplan.id
  
    app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = azurerm_container_registry.acr.login_server
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
  }
}