provider "azurerm" {
  features {}
  version = "~> 2.0"
}

locals {
    nic_name = "nic-${var.hostname}"
}


resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
}


resource "azurerm_network_interface" "main" {
  name                = local.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.snet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.hostname
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2"
  admin_username      = "localadmin"
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
