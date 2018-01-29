#
#
# Provider and credential snippet to add to configurations
# Assumes that there's a terraform.tfvars file with the var values
#
# Uncomment the creds variables if using service principal auth
# Leave them commented to use MSI auth
#
#variable subscription_id {}
#variable tenant_id {}
#variable client_id {}
#variable client_secret {}

provider "azurerm" {
#    subscription_id = "${var.subscription_id}"
#    tenant_id = "${var.tenant_id}"
#    client_id = "${var.client_id}"
#    client_secret = "${var.client_secret}"
}
