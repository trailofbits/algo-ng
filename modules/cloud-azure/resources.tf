resource "random_id" "resource_group_name" {
  byte_length = 8
}

resource "azurerm_resource_group" "main" {
  name     = "AlgoVPN-${var.algo_name}-${random_id.resource_group_name.hex}"
  location = "${var.region}"

  tags {
    Environment = "Algo"
  }
}

resource "azurerm_network_security_group" "algo" {
  name                = "${var.algo_name}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowIPSec500"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowIPSec4500"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowWireGuard"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "${var.wireguard_network["port"]}"
    destination_port_range     = "${var.wireguard_network["port"]}"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowICMP"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "0"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    Environment = "Algo"
  }
}

resource "azurerm_virtual_network" "algo" {
  name                = "${var.algo_name}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  address_space       = ["10.10.0.0/16"]

  tags {
    Environment = "Algo"
  }
}

resource "azurerm_subnet" "algo" {
  name                 = "${var.algo_name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.algo.name}"
  address_prefix       = "10.10.0.0/24"
}

resource "azurerm_public_ip" "algo" {
  name                = "${var.algo_name}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Static"

  tags {
    Environment = "Algo"
  }
}

resource "azurerm_network_interface" "algo" {
  name                      = "${var.algo_name}"
  location                  = "${var.region}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.algo.id}"

  ip_configuration {
    name                          = "Algo-public-ip-${var.algo_name}-${var.region}"
    subnet_id                     = "${azurerm_subnet.algo.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.algo.id}"
  }
}

resource "azurerm_virtual_machine" "algo" {
  name                             = "${var.algo_name}"
  location                         = "${var.region}"
  resource_group_name              = "${azurerm_resource_group.main.name}"
  network_interface_ids            = ["${azurerm_network_interface.algo.id}"]
  vm_size                          = "${var.size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "${var.image}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.algo_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.algo_name}"
    admin_username = "ubuntu"
    custom_data    = "${var.user_data}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${var.ssh_public_key}"
    }
  }

  tags {
    Environment = "Algo"
  }

  lifecycle {
    create_before_destroy = true
  }
}
