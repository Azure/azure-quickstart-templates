resource "azurerm_resource_group" "resourceGroup" {
  name     =  "${var.ResourceGroup}"
  location = "${var.Location}"
}
resource "azurerm_network_security_group" "MongodbNsg" {
  name                = "mongodbnsg"
  location            = "${var.Location}"
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
}
resource "azurerm_network_security_rule" "SSH" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.MongodbNsg.name}"
}
resource "azurerm_network_security_rule" "mongodb" {
  name                        = "mongodb"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "27017"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.MongodbNsg.name}"
}
resource "azurerm_network_security_rule" "habsup1" {
  name                        = "habsup1nsg"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9631"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.MongodbNsg.name}"
}
resource "azurerm_network_security_rule" "habsup2" {
  name                        = "habsup1nsg"
  priority                    = 700
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9638"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.MongodbNsg.name}"
}
resource "azurerm_network_security_rule" "sshOut" {
  name                        = "SSHOut"
  priority                    =  200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.MongodbNsg.name}"
}
resource "azurerm_network_security_rule" "elastic" {
  name                        = "Elastic"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9200"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.MongodbNsg.name}"
}
resource "azurerm_network_security_rule" "logStash" {
  name                        = "Logstash"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5044"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.MongodbNsg.name}"
}
resource "random_id" "uniqueString" {
  keepers = {
    uniqueid = "mongodb"
  }
  byte_length = 6
} 
resource "azurerm_network_interface" "networkInterfaceMongoDB" {
  name                = "NetworkinterfaceMongoDB"
  location            = "${var.Location}"
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
   depends_on         = ["azurerm_network_security_group.MongodbNsg"]
  network_security_group_id = "${azurerm_network_security_group.MongodbNsg.id}"
  
  ip_configuration {
    name                          = "configuration1"
    subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.ResourceGroup}/providers/Microsoft.Network/virtualNetworks/${var.vnetName}/subnets/${var.subnetName}"
    private_ip_address_allocation = "${var.StaticIP}"
    private_ip_address = "${var.PriavteIP}"
  }
}
resource "azurerm_storage_account" "storageAccount" {
 name                = "${var.sharedStorage}"
 resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
 location     = "${var.Location}"
 account_type = "${var.storageAccType}"
 }
resource "azurerm_storage_container" "storageContainer" {
 name                  = "mongodb${random_id.uniqueString.hex}"
 resource_group_name   = "${azurerm_resource_group.resourceGroup.name}"
 storage_account_name  = "${azurerm_storage_account.storageAccount.name}"
 container_access_type = "private"
 }
resource "azurerm_virtual_machine" "mastervm" {
  name                  = "mongodbvm${random_id.uniqueString.hex}"
  location              = "${var.Location}"
  resource_group_name   = "${azurerm_resource_group.resourceGroup.name}"
  network_interface_ids = ["${azurerm_network_interface.networkInterfaceMongoDB.id}"]
  vm_size               = "${var.vmSize}"

storage_os_disk {
name          = "osdisk${random_id.uniqueString.hex}"
image_uri 	  = "${var.imageUri}"
vhd_uri       = "${azurerm_storage_account.storageAccount.primary_blob_endpoint}${azurerm_storage_container.storageContainer.name}/osdisk1.vhd"
os_type       = "linux"
caching       = "ReadWrite"
create_option = "FromImage"
}
os_profile {
    computer_name  = "mongodbvm${random_id.uniqueString.hex}"
    admin_username = "${var.userName}"
    admin_password = "${var.password}"
  }
   os_profile_linux_config {
    disable_password_authentication = false
  }
  tags {
    environment = "prod"
  }
}
output "VMName" {
   value = "${azurerm_virtual_machine.mastervm.name}"
}
output "UserName" {
    value = "${var.userName}"
}
output "Password" {
    value = "${var.password}"
}
output "PrivateIP" {
 value = "${var.PriavteIP}"
}
