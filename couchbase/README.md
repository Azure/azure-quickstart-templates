# Couchbase

# Important Note

For the most up to date version of this template, please do not use this repo. Instead go [here](https://github.com/couchbase-partners/azure-resource-manager-couchbase).  We strongly encourage use of the latest version as it incorporates bug fixes and is more flexible.

You can deploy or inspect the template by clicking the buttons below:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcouchbase-partners%2Fazure-resource-manager-couchbase%2Fmaster%2Fsimple%2FmainTemplate.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fcouchbase-partners%2Fazure-resource-manager-couchbase%2Fmaster%2Fsimple%2FmainTemplate.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# Deploying this Couchbase ARM Template

This ARM template deploys a Couchbase Enterprise cluster to Azure.  The template provisions an availability set, vnet, and a variety of virtual machines each with their own managed disks and public IP addresses.  It also sets up a network security group.

Deployment typically takes less than five minutes.  When complete Couchbase administrator will be available on port 8091 of any node.  The URL to access the admin on vm0 is output as the nodeAdminURL.  

The username and password entered for the deployment will be used for both the VM administrator credentials as well as the Couchbase administrator.
