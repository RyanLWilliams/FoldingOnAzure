// Provider
provider "azurerm" {
  version         = "~> 2.2"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}

// Azure Resources

// Resource Group
resource "azurerm_resource_group" "rg-folding" {
  name     = "FoldingAtHome"
  location = var.location
}

// Networking
resource "azurerm_virtual_network" "vnet-folding" {
  name                = "vnet-folding"
  resource_group_name = azurerm_resource_group.rg-folding.name
  location            = var.location
  address_space       = ["192.168.100.0/24"]
}

resource "azurerm_subnet" "snet-folding" {
  name                 = "snet-folding"
  resource_group_name  = azurerm_resource_group.rg-folding.name
  virtual_network_name = azurerm_virtual_network.vnet-folding.name
  address_prefix       = azurerm_virtual_network.vnet-folding.address_space[0]
}

resource "azurerm_network_security_group" "nsg-snet-folding" {
  name                = "nsg-${azurerm_subnet.snet-folding.name}"
  resource_group_name = azurerm_resource_group.rg-folding.name
  location            = var.location
}

resource "azurerm_network_security_rule" "nsg-snet-folding-allowedips" {
  name                        = "allowed-ips"
  resource_group_name         = azurerm_resource_group.rg-folding.name
  network_security_group_name = azurerm_network_security_group.nsg-snet-folding.name
  priority                    = "110"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_address_prefix       = var.clientip
  source_port_range           = "*"
  destination_address_prefix  = azurerm_subnet.snet-folding.address_prefix
  destination_port_ranges     = ["22", "7396", "36330"]
}

resource "azurerm_subnet_network_security_group_association" "snet-nsg-folding" {
  subnet_id                 = azurerm_subnet.snet-folding.id
  network_security_group_id = azurerm_network_security_group.nsg-snet-folding.id
}

// Virtual Machines
resource "azurerm_availability_set" "avail-folding" {
  name                         = "avail-folding"
  resource_group_name          = azurerm_resource_group.rg-folding.name
  location                     = var.location
  managed                      = true
  platform_fault_domain_count  = 3
  platform_update_domain_count = 5
}

resource "azurerm_public_ip" "pip-vm-folding" {
  count               = var.fahvmcount
  name                = "${var.fahvmname}${count.index + 1}-pip"
  resource_group_name = azurerm_resource_group.rg-folding.name
  location            = var.location
  allocation_method   = "Dynamic"
  domain_name_label   = lower("${var.fahvmname}${count.index + 1}")
}

resource "azurerm_network_interface" "nic-vm-folding" {
  count               = var.fahvmcount
  name                = "${var.fahvmname}${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.rg-folding.name
  location            = var.location
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.snet-folding.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-vm-folding.*.id[count.index]
  }
}

resource "azurerm_linux_virtual_machine" "vm-folding" {
  count               = var.fahvmcount
  name                = "${var.fahvmname}${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg-folding.name
  location            = var.location
  size                = var.fahvmsize
  network_interface_ids = [
    azurerm_network_interface.nic-vm-folding.*.id[count.index]
  ]
  admin_username                  = var.fahvmusername
  admin_password                  = var.fahvmpassword
  disable_password_authentication = false
  availability_set_id             = azurerm_availability_set.avail-folding.id
  custom_data                     = filebase64("cloud-init.yaml")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.fahvmname}${count.index + 1}-osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm-folding-extension" {
  count                      = var.fahvmgpuenabled ? var.fahvmcount : 0
  name                       = "NvidiaGpuDriverLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm-folding.*.id[count.index]
  publisher                  = "Microsoft.HpcCompute"
  type                       = "NvidiaGpuDriverLinux"
  type_handler_version       = "1.2"
  auto_upgrade_minor_version = true
}

output "web-access" {
    value = [azurerm_public_ip.pip-vm-folding.*.fqdn]
    description = "Website to see your on Folding on Azure"
}
