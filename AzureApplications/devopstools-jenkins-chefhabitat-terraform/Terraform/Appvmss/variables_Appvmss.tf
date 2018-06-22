variable "subscription_id" {
description = "existing subscription id"  
default = ""
}
variable "client_id" {
description = "existing subscription client_id"  
default = ""
}
variable "client_secret" {
description = "existing subscription client_secret"  
default = ""
}
variable "tenant_id" {
description = "existing subscription tenant_id "  
default = ""
}
variable "vnetName" {
description = "Exisiting virtual network name"
default = ""
}
variable "subnetName" {
description = "Exisiting subnet name"
default = ""
}
variable "ResourceGroup" {
description = "name of the resource group which we created the vnet"
default = ""
}
variable "Location" {
 description = "where the vnet is create"
 default = ""
}
variable "DynamicIP" {
description =  "public_ip_address_allocation dynamic type"
default = ""
}
variable "vmSize" {
description = "virtual machine size"
default = "Standard_DS1_v2"
}
variable "userName" {
 description = "virtual machine admin user name"
 default = ""
}
variable "password" {
description = "virtual machine admin password"
default = ""
}
variable "imageUri" {
 description = "Full URIs of custom images (VHDs) to spin up new VMs"
 default = ""
}
