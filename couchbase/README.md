# Couchbase

This is an Azure Resource Manager (ARM) template that installs Couchbase Enterprise.  You can run it from the  CLI or using the [Azure Portal](https://portal.azure.com).  

The template provisions a virtual network, VM Scale Sets (VMSS), Managed Disks with Premium Storage and public IPs with a DNS record per node.  It also sets up a network security group.

# Important Note 1

For the most up to date version of this template, please do not use this repo. Instead go [here](https://github.com/couchbase-partners/azure-resource-manager-couchbase).  We strongly encourage use of the latest version as it incorporates bug fixes and is more flexible.

## Important Note 2

This template uses two Azure Marketplace VMs.  To deploy in your Azure subscription you must first deploy the template once from the Azure Portal [here](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/couchbase.couchbase-enterprise).

If you don't follow this step, you'll likely see an error like this:

    error:   MarketplacePurchaseEligibilityFailed : Marketplace purchase eligibilty check returned errors. See inner errors for details.


# Deploying this Couchbase ARM Template

You can deploy or inspect the template by clicking the buttons below or using a command line tool like the Azure CLI or Azure PowerShell:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https:%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

Deployment typically takes six to eight minutes.  When complete the template will out URLs you can use to access Couchbase Server and Couchbase Sync Gateway.

The username and password entered for the deployment will be used for both the VM administrator credentials as well as the Couchbase administrator.
