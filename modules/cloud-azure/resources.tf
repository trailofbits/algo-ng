locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.config.deploy_id
  }
}

resource "azurerm_resource_group" "algo" {
  name     = "algo-${var.config.deploy_id}"
  location = var.config.cloud.location
  tags     = local.tags
}

resource "azurerm_network_security_group" "algo" {
  name                = "algo-sg-${var.config.deploy_id}"
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  tags                = local.tags

  dynamic "security_rule" {
    iterator = rule
    for_each = [
      {
        "port" : 22
        "protocol" = "Tcp"
      },
      {
        "port" : var.config.tfvars.wireguard.port,
        "protocol" = "Udp"
      },
      {
        "port" : 0
        "protocol" = "Icmp"
    }]

    content {
      name                       = "Allow-${rule.value.port}-${rule.value.protocol}"
      priority                   = "10${rule.key}"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = rule.value.protocol
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      destination_port_ranges    = [rule.value.port]
    }
  }
}

resource "azurerm_virtual_network" "algo" {
  name                = "algo-net-${var.config.deploy_id}"
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  address_space       = concat(["172.16.0.0/16"], var.config.cloud.ipv6 ? ["fc00:a160::/64"] : [])
  tags                = local.tags
}

resource "azurerm_subnet" "algo" {
  name                 = "algo-subnet-${var.config.deploy_id}"
  resource_group_name  = azurerm_resource_group.algo.name
  virtual_network_name = azurerm_virtual_network.algo.name
  address_prefixes     = concat(["172.16.254.0/23"], var.config.cloud.ipv6 ? ["fc00:a160::/64"] : [])
}

resource "azurerm_public_ip" "algo4" {
  name                = "algo-ip4-${var.config.deploy_id}"
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  allocation_method   = "Static"
  sku                 = var.config.cloud.ipv6 ? "Standard" : "Basic"
  ip_version          = "IPv4"
  tags                = local.tags
}

resource "azurerm_public_ip" "algo6" {
  count               = var.config.cloud.ipv6 ? 1 : 0
  name                = "algo-ip6-${var.config.deploy_id}"
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv6"
  tags                = local.tags
}

resource "azurerm_network_interface" "algo" {
  name                = "algo-int-${var.config.deploy_id}"
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  tags                = local.tags

  ip_configuration {
    name                          = azurerm_public_ip.algo4.name
    subnet_id                     = azurerm_subnet.algo.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.algo4.id
    primary                       = true
  }

  dynamic "ip_configuration" {
    iterator = ip
    for_each = azurerm_public_ip.algo6

    content {
      name                          = ip.value.name
      subnet_id                     = azurerm_subnet.algo.id
      private_ip_address_version    = "IPv6"
      private_ip_address_allocation = "dynamic"
      public_ip_address_id          = ip.value.id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "algo" {
  network_interface_id      = azurerm_network_interface.algo.id
  network_security_group_id = azurerm_network_security_group.algo.id
}

resource "azurerm_virtual_machine" "algo" {
  name                             = "algo-srv-${var.config.deploy_id}"
  location                         = azurerm_resource_group.algo.location
  resource_group_name              = azurerm_resource_group.algo.name
  network_interface_ids            = [azurerm_network_interface.algo.id]
  vm_size                          = var.config.cloud.size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  tags                             = local.tags

  storage_image_reference {
    publisher = "Canonical"
    offer     = var.config.cloud.offer
    sku       = var.config.cloud.image
    version   = "latest"
  }

  storage_os_disk {
    name              = "algo-srv-${var.config.deploy_id}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "algo-srv-${var.config.deploy_id}"
    admin_username = "ubuntu"
    custom_data    = var.config.user_data.cloudinit
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.config.ssh_public_key
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
