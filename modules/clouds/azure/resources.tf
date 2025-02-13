locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.deploy_id
  }

  cloud_config = var.algo_config.clouds.azure
  name         = "algo-vpn-${var.deploy_id}"

  wireguard_ports = [{
    "port" : var.algo_config.wireguard.port,
    "protocol" = "Udp"
  }]

  ipsec_ports = [{
    "port" : 500,
    "protocol" = "Udp"
    },
    {
      "port" : 4500,
      "protocol" = "Udp"
  }]

  vpn_ports = concat(
    var.algo_config.wireguard.enabled ? local.wireguard_ports : [],
    var.algo_config.ipsec.enabled ? local.ipsec_ports : [],
  )
}

resource "azurerm_resource_group" "algo" {
  name     = local.name
  location = local.cloud_config.location
  tags     = local.tags
}

resource "azurerm_network_security_group" "algo" {
  name                = local.name
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  tags                = local.tags

  dynamic "security_rule" {
    iterator = rule
    for_each = concat([
      {
        "port" : 22
        "protocol" = "Tcp"
      },
      {
        "port" : 0
        "protocol" = "Icmp"
    }], local.vpn_ports)

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
  name                = local.name
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  address_space       = concat(["172.16.0.0/16"], local.cloud_config.ipv6 ? ["fc00:a160::/64"] : [])
  tags                = local.tags
}

resource "azurerm_subnet" "algo" {
  name                 = local.name
  resource_group_name  = azurerm_resource_group.algo.name
  virtual_network_name = azurerm_virtual_network.algo.name
  address_prefixes     = concat(["172.16.254.0/23"], local.cloud_config.ipv6 ? ["fc00:a160::/64"] : [])
}

resource "azurerm_public_ip" "algo4" {
  name                = local.name
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  allocation_method   = "Static"
  sku                 = local.cloud_config.ipv6 ? "Standard" : "Basic"
  ip_version          = "IPv4"
  tags                = local.tags
}

resource "azurerm_public_ip" "algo6" {
  count               = local.cloud_config.ipv6 ? 1 : 0
  name                = "${local.name}-ip6"
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv6"
  tags                = local.tags
}

resource "azurerm_network_interface" "algo" {
  name                = local.name
  location            = azurerm_resource_group.algo.location
  resource_group_name = azurerm_resource_group.algo.name
  tags                = local.tags

  ip_configuration {
    name                          = azurerm_public_ip.algo4.name
    subnet_id                     = azurerm_subnet.algo.id
    private_ip_address_allocation = "Dynamic"
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
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = ip.value.id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "algo" {
  network_interface_id      = azurerm_network_interface.algo.id
  network_security_group_id = azurerm_network_security_group.algo.id
}

resource "azurerm_virtual_machine" "algo" {
  name                             = local.name
  location                         = azurerm_resource_group.algo.location
  resource_group_name              = azurerm_resource_group.algo.name
  network_interface_ids            = [azurerm_network_interface.algo.id]
  vm_size                          = local.cloud_config.size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  tags                             = local.tags

  storage_image_reference {
    publisher = "Canonical"
    offer     = local.cloud_config.offer
    sku       = local.cloud_config.image
    version   = "latest"
  }

  storage_os_disk {
    name              = local.name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.name
    admin_username = "ubuntu"
    custom_data    = var.user_data.cloudinit
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_key.public
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
