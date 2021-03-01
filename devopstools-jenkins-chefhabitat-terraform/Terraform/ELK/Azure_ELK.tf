resource "azurerm_resource_group" "resourceGroup" {
  name     =  "${var.ResourceGroup}"
  location = "${var.Location}"
}
resource "azurerm_network_security_group" "Nsg" {
  name                = "elknsg"
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
  network_security_group_name = "${azurerm_network_security_group.Nsg.name}"
}
resource "azurerm_network_security_rule" "kibana" {
  name                        = "kibana"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_name = "${azurerm_network_security_group.Nsg.name}"
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
  network_security_group_name = "${azurerm_network_security_group.Nsg.name}"
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
  network_security_group_name = "${azurerm_network_security_group.Nsg.name}"
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
  network_security_group_name = "${azurerm_network_security_group.Nsg.name}"
}
resource "random_id" "uniqueString" {
  keepers = {
    uniqueid = "kibana"
  }
  byte_length = 6
}
 resource "azurerm_public_ip" "publicIP" {
  name                         = "publicip"
  location                     = "${var.Location}"
  resource_group_name          = "${azurerm_resource_group.resourceGroup.name}"
  public_ip_address_allocation = "${var.DynamicIP}"
  domain_name_label = "elk${random_id.uniqueString.hex}"
} 
resource "azurerm_storage_account" "storageAccount" {
  name                = "elk${random_id.uniqueString.hex}"
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
  location     = "${var.Location}"
  account_type = "${var.storageAccType}"
}
resource "azurerm_storage_container" "storageContainer" {
  name                  = "container1"
  resource_group_name   = "${azurerm_resource_group.resourceGroup.name}"
  storage_account_name  = "${azurerm_storage_account.storageAccount.name}"
  container_access_type = "private"
}
resource "azurerm_network_interface" "networkInterfaceElk" {
  name                = "NetworkinterfaceELK"
  location            = "${var.Location}"
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.Nsg.id}"
  ip_configuration {
    name                          = "configuration1"
    subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.ResourceGroup}/providers/Microsoft.Network/virtualNetworks/${var.vnetName}/subnets/${var.subnetName}"
    private_ip_address_allocation = "${var.DynamicIP}"
     public_ip_address_id = "${azurerm_public_ip.publicIP.id}"
  }
}
resource "azurerm_virtual_machine" "mastervm" {
  name                  = "ELK_KibanaVM${random_id.uniqueString.hex}"
  location              = "${var.Location}"
  resource_group_name   = "${azurerm_resource_group.resourceGroup.name}"
   network_interface_ids = ["${azurerm_network_interface.networkInterfaceElk.id}"]
  vm_size               = "${var.vmSize}"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name          = "osdisk${random_id.uniqueString.hex}"
    vhd_uri       = "${azurerm_storage_account.storageAccount.primary_blob_endpoint}${azurerm_storage_container.storageContainer.name}/osdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }
  storage_data_disk {
    name          = "datadisk${random_id.uniqueString.hex}"
    vhd_uri       = "${azurerm_storage_account.storageAccount.primary_blob_endpoint}${azurerm_storage_container.storageContainer.name}/datadisk0.vhd"
    disk_size_gb  = "50"
    create_option = "Empty"
    lun           = 0
  }

 os_profile {
    computer_name  = "elk-kibana"
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
resource "azurerm_virtual_machine_extension" "elasticSearch" {
    name = "elastic"
    location = "${var.Location}"
    resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
    virtual_machine_name = "${azurerm_virtual_machine.mastervm.name}"
     depends_on            = ["azurerm_virtual_machine.mastervm"]
    publisher = "Microsoft.OSTCExtensions"
    type = "CustomScriptForLinux"
    type_handler_version = "1.2"
     settings = <<EOF
    {
        "fileUris": ["${var._artifactsLocation}/scripts/elkstack_deploy.sh${var._artifactsLocationSasToken}"],
        "commandToExecute":"sh elkstack_deploy.sh ${var.client_id} ${var.client_secret} ${var.tenant_id} ${var.storage_account} ${var.subscription_id} ${var._artifactsLocation} ${var.kibanaUsername} ${var.kibanaPassword}"
    }
EOF
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
output "fqdn" {
    value = "${azurerm_public_ip.publicIP.domain_name_label}.${var.Location}.cloudapp.azure.com"
}
