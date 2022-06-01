# 1. Specify the version of the AzureRM Provider to use
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.1"
    }
  }
}

# 2. Configure the AzureRM Provider
provider "azurerm" {
  features {}
}

#Creating Three Resources
# 1. Create a resource group
resource "azurerm_resource_group" "myrg" {
  name     = "awspre-rg"
  location = "Korea Central"
}

# 2. Create a virtual network within the resource group
resource "azurerm_virtual_network" "myvnet" {
  name                = "aws-pre-vnet"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  address_space       = ["10.0.0.0/16"]
}

# 3. Create our Subnet to hold our VM - Virtual Machines
resource "azurerm_subnet" "mysubnet" {
  name                 = "aws-pre-subnet"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
