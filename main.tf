terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" { 
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = __rg2__
    storage_account_name = __saname__
    container_name       = __conname__
    key                  = __key__
    access_key = __acskey__
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = "${var.prefix}-RG"
  location = "${var.rgloc}" 
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = "${var.vnet-cidr}"
}

resource "azurerm_subnet" "appsub1" {
  name                 = "${var.prefix}-appsub"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = "${var.appsub-cidr}"
}

resource "azurerm_subnet" "dbsub2" {
  name                 = "${var.prefix}-dbsub"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = "${var.dbsub-cidr}"
}

resource "azurerm_network_security_group" "appnsg" {
  name                = "${var.prefix}-appnsg"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "dbnsg" {
  name                = "${var.prefix}-dbnsg"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "appsub-nsg-assoc" {
  subnet_id                 = azurerm_subnet.appsub1.id
  network_security_group_id = azurerm_network_security_group.appnsg.id
}

resource "azurerm_subnet_network_security_group_association" "dbsub-nsg-assoc" {
  subnet_id                 = azurerm_subnet.dbsub2.id
  network_security_group_id = azurerm_network_security_group.dbnsg.id
}

resource "azurerm_public_ip" "pubip" {
  name                = "${var.prefix}-publicIP"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Dynamic"
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "myNICConfig"
    subnet_id                     = azurerm_subnet.appsub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.pubip.id
  }
}

resource "azurerm_virtual_machine" "appvm" {
  name                  = "${var.prefix}-webserver"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-mydisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-webserver"
    admin_username = "azureuser"
    admin_password = "Password1234!"  # Replace with your own strong password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}



