resource "azurerm_network_security_group" "algo" {
  name                = var.algo_name
  location            = var.region
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    iterator = rule
    for_each = [
      "0:*:ICMP",
      "22:Tcp:SSH",
      "500,4500:Udp:IPsec",
      "${var.wireguard_network["port"]}:Udp:WireGuard"
    ]

    content {
      name                       = "Allow-${split(":", rule.value)[2]}"
      priority                   = "10${rule.key}"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = split(":", rule.value)[1]
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      destination_port_ranges = [
        for i in split(",", split(":", rule.value)[0]) :
        i
      ]
    }
  }

  tags = {
    Environment = "Algo"
  }
}

resource "azurerm_virtual_network" "algo" {
  name                = var.algo_name
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = ["10.10.0.0/16"]

  tags = {
    Environment = "Algo"
  }
}

resource "azurerm_subnet" "algo" {
  name                 = var.algo_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.algo.name
  address_prefix       = "10.10.0.0/24"
}

resource "azurerm_network_interface" "algo" {
  name                      = var.algo_name
  location                  = var.region
  resource_group_name       = var.resource_group_name
  network_security_group_id = azurerm_network_security_group.algo.id

  ip_configuration {
    name                          = var.algo_name
    subnet_id                     = azurerm_subnet.algo.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = var.algo_ip
  }
}

resource "azurerm_virtual_machine" "algo" {
  name                             = var.algo_name
  location                         = var.region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.algo.id]
  vm_size                          = var.size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.image
    version   = "latest"
  }

  storage_os_disk {
    name              = var.algo_name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.algo_name
    admin_username = "ubuntu"
    custom_data    = var.user_data
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  tags = {
    Environment = "Algo"
  }

  lifecycle {
    create_before_destroy = true
  }
}
