# Couchbase

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/couchbase/couchbase/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/couchbase/couchbase/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/couchbase/couchbase/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/couchbase/couchbase/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/couchbase/couchbase/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/couchbase/couchbase/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcouchbase%2Fcouchbase%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcouchbase%2Fcouchbase%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcouchbase%2Fcouchbase%2Fazuredeploy.json) 

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

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcouchbase%2Fcouchbase%2Fazuredeploy.json" target="_blank">
<a href="http://armviz.io/#/?load=https:%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcouchbase%2Fcouchbase%2Fazuredeploy.json" target="_blank">

Deployment typically takes six to eight minutes.  When complete the template will out URLs you can use to access Couchbase Server and Couchbase Sync Gateway.

The username and password entered for the deployment will be used for both the VM administrator credentials as well as the Couchbase administrator.


