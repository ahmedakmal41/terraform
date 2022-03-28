
resource "azurerm_resource_group" "cmp" {
  name     = var.rgname
  location = "East US"
  tags = {
    Name         = var.vmname,
    Owner        = var.owner,
    Environment  = var.Environment,
    BuisnessUnit = var.Buisness_unit,
    Application  = var.Application,
    Platform     = var.Platform,
    Type         = var.Type,
  }
}
resource "azurerm_public_ip" "cmp" {
  name                = "${var.vmname}-ip"
  resource_group_name = azurerm_resource_group.cmp.name
  location            = azurerm_resource_group.cmp.location
  allocation_method   = "Static"

  tags = {
    Name         = var.vmname,
    Owner        = var.owner,
    Environment  = var.Environment,
    BuisnessUnit = var.Buisness_unit,
    Application  = var.Application,
    Platform     = var.Platform,
    Type         = var.Type,
  }
}
resource "azurerm_virtual_network" "cmp" {
  name                = "${var.vmname}-network"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.cmp.location
  resource_group_name = azurerm_resource_group.cmp.name
  tags = {
    Name         = var.vmname,
    Owner        = var.owner,
    Environment  = var.Environment,
    BuisnessUnit = var.Buisness_unit,
    Application  = var.Application,
    Platform     = var.Platform,
    Type         = var.Type,
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.cmp.name
  virtual_network_name = azurerm_virtual_network.cmp.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_network_interface" "cmp" {
  name                = "${var.vmname}-nic"
  location            = azurerm_resource_group.cmp.location
  resource_group_name = azurerm_resource_group.cmp.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "/subscriptions/8e485c9b-6527-441b-a8c3-51058f8daf6e/resourceGroups/EUS-CMP-RG-VMS/providers/Microsoft.Network/virtualNetworks/EUS-CMP-RG-VMS-vnet/subnets/default"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cmp.id
  }

  tags = {
    Name         = var.vmname,
    Owner        = var.owner,
    Environment  = var.Environment,
    BuisnessUnit = var.Buisness_unit,
    Application  = var.Application,
    Platform     = var.Platform,
    Type         = var.Type,
  }
}
resource "azurerm_managed_disk" "cmp" {
  name                 = "${var.vmname}-disk1"
  location             = azurerm_resource_group.cmp.location
  resource_group_name  = azurerm_resource_group.cmp.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
  tags = {
    Name         = var.vmname,
    Owner        = var.owner,
    Environment  = var.Environment,
    BuisnessUnit = var.Buisness_unit,
    Application  = var.Application,
    Platform     = var.Platform,
    Type         = var.Type,
  }
}
resource "azurerm_network_security_group" "cmp" {
  name                = "${var.vmname}-nsg"
  location            = azurerm_resource_group.cmp.location
  resource_group_name = azurerm_resource_group.cmp.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name         = var.vmname,
    Owner        = var.owner,
    Environment  = var.Environment,
    BuisnessUnit = var.Buisness_unit,
    Application  = var.Application,
    Platform     = var.Platform,
    Type         = var.Type,
  }
}
resource "azurerm_virtual_machine" "cmp" {
  name                  = var.vmname
  location              = azurerm_resource_group.cmp.location
  resource_group_name   = azurerm_resource_group.cmp.name
  network_interface_ids = [azurerm_network_interface.cmp.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.sku
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.vmname}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = var.adminuser
    admin_password = var.adminpassword
    custom_data    = file("wmi-agent-install-pshell.ps1")
  }
  os_profile_windows_config {
    provision_vm_agent = true

  }
  tags = {
    Name         = var.vmname,
    Owner        = var.owner,
    Environment  = var.Environment,
    BuisnessUnit = var.Buisness_unit,
    Application  = var.Application,
    Platform     = var.Platform,
    Type         = var.Type,
  }
}
resource "azurerm_network_interface_security_group_association" "cmp" {
  network_interface_id      = azurerm_network_interface.cmp.id
  network_security_group_id = azurerm_network_security_group.cmp.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "cmp" {
  managed_disk_id    = azurerm_managed_disk.cmp.id
  virtual_machine_id = azurerm_virtual_machine.cmp.id
  lun                = "10"
  caching            = "ReadWrite"
}


//------------------------Log Analytics -----------------------//

resource "azurerm_virtual_machine_extension" "cmp" {
  name                       = "OmsAgentForWindows"
  virtual_machine_id         = azurerm_virtual_machine.cmp.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "workspaceId": "${var.workspaceid}"
    }
SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "workspaceKey": "${var.workspacekey}"
    }
PROTECTEDSETTINGS
}
/*
resource "azurerm_virtual_network_peering" "peering1" {
  name                         = "peering-to-prometheus-${var.vmname}"
  resource_group_name          = azurerm_resource_group.cmp.name
  virtual_network_name         = azurerm_virtual_network.cmp.name
  remote_virtual_network_id    = "/subscriptions/8e485c9b-6527-441b-a8c3-51058f8daf6e/resourceGroups/EUS-CMP-RG-VMS/providers/Microsoft.Network/virtualNetworks/EUS-CMP-RG-VMS-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}
resource "azurerm_virtual_network_peering" "peering2" {
  name                         = "peering-from-prometheus-vnet-${var.vmname}"
  resource_group_name          = "EUS-CMP-RG-VMS"
  virtual_network_name         = "EUS-CMP-RG-VMS-vnet"
  remote_virtual_network_id    = azurerm_virtual_network.cmp.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}
*/
resource "azurerm_virtual_machine_extension" "software" {
  name                 = "install-software"
  virtual_machine_id   = azurerm_virtual_machine.cmp.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(file("wmi-agent-install-pshell.ps1"))}')) | Out-File -filepath wmi-agent-install-pshell.ps1\" && powershell -ExecutionPolicy Unrestricted -File wmi-agent-install-pshell.ps1"
  }
  SETTINGS
}




