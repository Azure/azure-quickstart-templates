resource "azurerm_resource_group" "resourceGroup" {
  name     =  "${var.ResourceGroup}"
  location = "${var.Location}"
}
resource "random_id" "app" {
  keepers = {
    dnsid = "app"
  }
  byte_length = 6
}
resource "azurerm_public_ip" "vmsspublicip" {
  name                         = "appscaleset-pip"
  location                     = "${var.Location}"
  resource_group_name          = "${azurerm_resource_group.resourceGroup.name}"
  public_ip_address_allocation = "${var.DynamicIP}"
  domain_name_label            = "app${random_id.app.hex}"
  tags {
    environment = "quickstart"
  }
}
resource "azurerm_lb" "applb" {
  name                = "scaleset-lb"
  location            = "${var.Location}"
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"

  frontend_ip_configuration {
    name                 = "ipconfig"
    public_ip_address_id = "${azurerm_public_ip.vmsspublicip.id}"
  }
}
resource "azurerm_lb_backend_address_pool" "backendpool" {
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
  loadbalancer_id     = "${azurerm_lb.applb.id}"
  name                = "BackEndPool"
}
resource "azurerm_lb_probe" "Appport" {
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
  loadbalancer_id     = "${azurerm_lb.applb.id}"
  name                = "Appport"
  port                = 8080
  interval_in_seconds = 30
  number_of_probes    = 3
}
resource "azurerm_lb_rule" "rule1" {
  resource_group_name            = "${azurerm_resource_group.resourceGroup.name}"
  loadbalancer_id                = "${azurerm_lb.applb.id}"
  name                           = "http-internal"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "ipconfig"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backendpool.id}"
 idle_timeout_in_minutes        = 5
 probe_id                       = "${azurerm_lb_probe.Appport.id}"
  depends_on                     = ["azurerm_lb_probe.Appport","azurerm_lb_backend_address_pool.backendpool"]
}
resource "azurerm_lb_nat_pool" "lbNat" {
  count                          = 2
  resource_group_name            = "${azurerm_resource_group.resourceGroup.name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.applb.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "ipconfig"
}
resource "azurerm_virtual_machine_scale_set" "appscalesetvm" {
  name                = "appvmss${random_id.app.hex}"
  location            = "${var.Location}"
  resource_group_name = "${azurerm_resource_group.resourceGroup.name}"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "${var.vmSize}"
    tier     = "Standard"
    capacity = 3
  }

  storage_profile_os_disk {
    name           = "osDiskProfile"
    caching        = "ReadWrite"
    os_type        = "linux"
    create_option  = "FromImage"
    image 	   = "${var.imageUri}"
  }

  os_profile {
    computer_name_prefix = "vmss${random_id.app.hex}"
    admin_username = "${var.userName}"
    admin_password = "${var.password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_profile {
    name    = "vmmssnetprofile"
    primary = true

    ip_configuration {
      name                                   = "ipconfig${random_id.app.hex}"
      subnet_id                              = "/subscriptions/${var.subscription_id}/resourceGroups/${var.ResourceGroup}/providers/Microsoft.Network/virtualNetworks/${var.vnetName}/subnets/${var.subnetName}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.backendpool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbNat.*.id, count.index)}"]
    }
  }

  tags {
    environment = "prod"
  }
}
output "UserName" {
    value = "${var.userName}"
}
output "Password" {
    value = "${var.password}"
}
output "Vm_Scale_Set_fqdn" {
    value = "${azurerm_public_ip.vmsspublicip.domain_name_label}.${var.Location}.cloudapp.azure.com"
}
output "Application_URL" {
    value = "${azurerm_public_ip.vmsspublicip.domain_name_label}.${var.Location}.cloudapp.azure.com:8080/national-parks"
}
output "SSH_access_to_instace1" {
    value = "${azurerm_public_ip.vmsspublicip.domain_name_label}.${var.Location}.cloudapp.azure.com:50000"
}
output "SSH_access_to_instace2" {
    value = "${azurerm_public_ip.vmsspublicip.domain_name_label}.${var.Location}.cloudapp.azure.com:50001"
}
output "SSH_access_to_instace3" {
    value = "${azurerm_public_ip.vmsspublicip.domain_name_label}.${var.Location}.cloudapp.azure.com:50002"
}
