terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.41.0"
    }
  }
}
provider "azurerm" {
    features {
      
    }
}
terraform {
  backend "azurerm"{
      resource_group_name = "msrgiac"
      storage_account_name = "mahakstorageaccsharma"
      container_name = "mshtfstate"
      key = "terraform.tfstate"

     }
  }


resource "azurerm_resource_group" "resourcegroup" {
  name     = "msaspiac"
  location = "uksouth"
}

# Create an Azure Container Registry
resource "azurerm_container_registry" "azurecontainerregistry" {
  name                     = "mahaksazurecg"
  resource_group_name      = azurerm_resource_group.resourcegroup.name
  location                 = azurerm_resource_group.resourcegroup.location
  sku                      = "Standard"
  admin_enabled            = true
}

# Create an App Service Plan
resource "azurerm_app_service_plan" "msappserviceplan" {
  name                = "msaspiac"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "msappservice" {
  name                = "mssharmaasiac"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  app_service_plan_id = azurerm_app_service_plan.msappserviceplan.id

  site_config {
    dotnet_framework_version = "v5.0"
    always_on                = true
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"         = azurerm_container_registry.azurecontainerregistry.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME"    = azurerm_container_registry.azurecontainerregistry.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"    = azurerm_container_registry.azurecontainerregistry.admin_password
    "WEBSITES_PORT"                      = "80"
  }
}