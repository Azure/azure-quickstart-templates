# Couchbase

This ARM template deploys a Couchbase Enterprise cluster to Azure.  The template provisions an availability set, vnet, and a variety of virtual machines each with their own managed disks and public IP addresses.  It also sets up a network security group.

# Important Note

For the most up to date version of this template, please do not use this repo. Instead go [here](https://github.com/couchbase-partners/azure-resource-manager-couchbase).  We strongly encourage use of the latest version as it incorporates bug fixes and is more flexible.

# Deploying this Couchbase ARM Template

You can deploy or inspect the template by clicking the buttons below or using a command line tool like the Azure CLI or Azure PowerShell:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https:%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

Deployment typically takes less than five minutes.  When complete Couchbase administrator will be available on port 8091 of any node.  The URL to access the admin on vm0 is output as the nodeAdminURL.  

The username and password entered for the deployment will be used for both the VM administrator credentials as well as the Couchbase administrator.
