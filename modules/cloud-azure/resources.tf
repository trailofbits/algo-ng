resource "azurerm_resource_group" "algo" {
  name     = "Algo-${var.algo_name}-${var.region}"
  location = "${var.region}"
  tags {
    Environment = "Algo"
  }
}

resource "azurerm_network_security_group" "algo" {
  name                = "Algo-security-group-${var.algo_name}-${var.region}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.algo.name}"

  security_rule {
    name                       = "Algo-rule-AllowSSH-${var.algo_name}-${var.region}"
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
    name                       = "Algo-rule-AllowIPSEC500-${var.algo_name}-${var.region}"
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
    name                       = "Algo-rule-AllowIPSEC4500-${var.algo_name}-${var.region}"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    Environment = "Algo"
  }
}

resource "azurerm_virtual_network" "algo" {
  name                = "Algo-network-${var.algo_name}-${var.region}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.algo.name}"
  address_space       = [ "10.10.0.0/16" ]

  tags {
    Environment = "Algo"
  }
}

resource "azurerm_subnet" "algo" {
  name                 = "Algo-subnet-${var.algo_name}-${var.region}"
  resource_group_name  = "${azurerm_resource_group.algo.name}"
  virtual_network_name = "${azurerm_virtual_network.algo.name}"
  address_prefix       = "10.10.0.0/24"
}

resource "azurerm_public_ip" "algo" {
  name                          = "Algo-ip-${var.algo_name}-${var.region}"
  location                      = "${var.region}"
  resource_group_name           = "${azurerm_resource_group.algo.name}"
  public_ip_address_allocation  = "static"

  tags {
    Environment = "Algo"
  }
}

resource "azurerm_network_interface" "algo" {
  name                = "Algo-network-interface-${var.algo_name}-${var.region}"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.algo.name}"
  network_security_group_id = "${azurerm_network_security_group.algo.id}"

  ip_configuration {
    name                          = "Algo-public-ip-${var.algo_name}-${var.region}"
    subnet_id                     = "${azurerm_subnet.algo.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.algo.id}"
  }
}

resource "azurerm_virtual_machine" "algo" {
  name                  = "Algo-vm-${var.algo_name}-${var.region}"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.algo.name}"
  network_interface_ids = [ "${azurerm_network_interface.algo.id}" ]
  vm_size               = "${var.size}"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "Algo-disk-${var.algo_name}-${var.region}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.algo_name}"
    admin_username = "ubuntu"
    admin_password = ""
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${var.public_key_openssh}"
    }
  }

  tags {
    Environment = "Algo"
  }
}
