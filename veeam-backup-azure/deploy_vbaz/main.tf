# local  variables - storage account unique name, tags used in the environment
locals {
  stg_acc_name = "${var.stg_account_prefix}${var.user_id}"
  computer_name = "vbaz-${var.user_id}"
  tags = {
    owner = "${var.tag_owner}"
    environment = "${var.tag_environment}"
  }
}

##################################
# Create resource group for VBAZ
##################################
resource "azurerm_resource_group" "backup" {
  name     = "rg-backup-${var.user_id}"
  location = var.az_location
  tags = local.tags
}


####################################
# Create networking for VBAZ
# vnet, subnet, nsg, public ip, nic
####################################
resource "azurerm_virtual_network" "backup" {
  name                = "vnet-backup-${var.user_id}"
  address_space       = var.backup_address_space
  location            = azurerm_resource_group.backup.location
  resource_group_name = azurerm_resource_group.backup.name
  tags = local.tags
}

resource "azurerm_subnet" "backup" {
  name                 = "subnet-backup-${var.user_id}"
  resource_group_name  = azurerm_resource_group.backup.name
  virtual_network_name = azurerm_virtual_network.backup.name 
  address_prefixes     = var.backup_subnet
  service_endpoints = ["Microsoft.Storage"]
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_network_security_group" "allow_https_ssh" {
  name                = "nsg-backup-${var.user_id}"
  location            = azurerm_resource_group.backup.location
  resource_group_name  = azurerm_resource_group.backup.name
  tags = local.tags

  security_rule {
    name                       = "Allow_SSH_in"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes      = var.nsg_source_addresses
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_HTTPS_in"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes      = var.nsg_source_addresses
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "vbaz" {
  name                = "public-ip-vbaz-${var.user_id}"
  location            = azurerm_resource_group.backup.location
  resource_group_name  = azurerm_resource_group.backup.name
  allocation_method   = "Static"
  tags = local.tags
}

resource "azurerm_network_interface" "vbaz" {
  name                = "vnic-vbaz-${var.user_id}"
  location            = azurerm_resource_group.backup.location
  resource_group_name  = azurerm_resource_group.backup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backup.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.internal_ip
    public_ip_address_id          = azurerm_public_ip.vbaz.id
  }
  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "vbaz" {
    network_interface_id      = azurerm_network_interface.vbaz.id
    network_security_group_id = azurerm_network_security_group.allow_https_ssh.id
}


##############
# Deploy VBAZ 
##############
resource "azurerm_virtual_machine" "vbaz" {
  name                = local.computer_name
  location            = azurerm_resource_group.backup.location
  resource_group_name  = azurerm_resource_group.backup.name

  storage_image_reference {
    publisher = "veeam"
    offer     = var.vbaz_offer
    sku       = var.vbaz_sku
    version   = var.vbaz_version
  }

  vm_size              = var.vm_size

  storage_os_disk {
    name = "vbaz-osdisk"
    caching = "None"
    create_option     = "FromImage"
    managed_disk_type  = var.vbaz_disk_type
  }

  os_profile {
    computer_name       = local.computer_name
    admin_username      = var.admin_username
    admin_password      = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_interface_ids = [
    azurerm_network_interface.vbaz.id
  ]

  plan {
    publisher = "veeam"
    name     = var.vbaz_sku
    product       = var.vbaz_offer
  }

  tags = local.tags

}


##############################################
# Create Storage Account for VBAZ Repository
# with private endpoint
##############################################

# Public IP of from where TF is executed, needs to be added to network rules 
# once the account is created, remove public access to it

resource "azurerm_storage_account" "vbaz" {
  name                = lower(local.stg_acc_name)
  resource_group_name = azurerm_resource_group.backup.name
  location                 = azurerm_resource_group.backup.location

  account_tier             = var.stg_account_tier
  account_replication_type = var.stg_account_replication_type

  network_rules {
    default_action             = "Deny"
    ip_rules = var.stg_public_ip_list
    virtual_network_subnet_ids = [azurerm_subnet.backup.id]
  }

  tags = local.tags
}

resource "azurerm_storage_container" "vbaz" {
  name                  = lower("repo-vbaz-${var.user_id}")
  storage_account_name  = azurerm_storage_account.vbaz.name
  container_access_type = "private"
}

# Private DNS zone for Private Endpoint
resource "azurerm_private_dns_zone" "dns_zone_backup" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.backup.name
  tags = local.tags
}

# Private DNS zone virtual network link 
resource "azurerm_private_dns_zone_virtual_network_link" "stg_network_link" {
  name                  = "vnet-link-backup-${var.user_id}"
  resource_group_name   = azurerm_resource_group.backup.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_backup.name
  virtual_network_id    = azurerm_virtual_network.backup.id

  depends_on = [
    azurerm_resource_group.backup,
    azurerm_private_dns_zone.dns_zone_backup,
    azurerm_virtual_network.backup
  ]
  
  tags = local.tags
}

# Private Endpoint for Storage Account 
resource "azurerm_private_endpoint" "endpoint_stg_account" {
  name                = "pe-stg-${var.user_id}"
  resource_group_name = azurerm_resource_group.backup.name
  location            = azurerm_resource_group.backup.location
  subnet_id           = azurerm_subnet.backup.id

  private_service_connection {
    name                           = "psc-stg-${var.user_id}"
    private_connection_resource_id = azurerm_storage_account.vbaz.id
    is_manual_connection           = false
    subresource_names = ["blob"]
  }
  tags = local.tags
}

#  A record in private DNS record for Storage Account
resource "azurerm_private_dns_a_record" "dns_stg_acc" {
  name                = lower(local.stg_acc_name)
  zone_name           = azurerm_private_dns_zone.dns_zone_backup.name
  resource_group_name = azurerm_resource_group.backup.name
  ttl                 = 10
  records             = [azurerm_private_endpoint.endpoint_stg_account.private_service_connection.0.private_ip_address]

  depends_on = [
    azurerm_private_dns_zone.dns_zone_backup,
    azurerm_private_endpoint.endpoint_stg_account
  ]

  tags = local.tags

}
