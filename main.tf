# 1. Specify the version of the AzureRM Provider to use
#


terraform {

  backend "azurerm" {
    resource_group_name  = "awspre-infra"
    storage_account_name = "awspresto"
    container_name       = "awsprestate"
    key                  = "terraform.state"
  }


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.1"
    }
  }
}

# Configure the AzureRM Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# 1. Create a resource group
data "azurerm_client_config" "current" {}
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

# 4. Create our Azure Storage Account - awspresto
resource "azurerm_storage_account" "awsprestoloc" {
  name                     = "awsprestoloc"
  resource_group_name      = azurerm_resource_group.myrg.name
  location                 = azurerm_resource_group.myrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "awspre"
  }
}
# 5. Create our vNIC for our VM and assign it to our Virtual Machines Subnet
resource "azurerm_network_interface" "vmnic" {
  name                = "awsprevm01nic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# 6. Create our Virtual Machine - AwsPre-VM01
resource "azurerm_virtual_machine" "aws-pre-vm01" {
  name                  = "aws-pre-vm01"
  location              = azurerm_resource_group.myrg.location
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }
  storage_os_disk {
    name              = "awsprestovm01os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "awsprevm01"
    admin_username = "imtiaza"
    admin_password = "Netsolpk123!@#"
  }
  os_profile_windows_config {
  }
}
