# Create an Internet-facing Standard Load Balancer with three VMs

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-load-balancer-standard-create/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-load-balancer-standard-create/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-load-balancer-standard-create/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-load-balancer-standard-create/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-load-balancer-standard-create/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-load-balancer-standard-create/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-load-balancer-standard-create%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-load-balancer-standard-create%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

**This template provides an example for how to deploy a Standard Load Balancer.**

The template creates and configures the following Azure resources:

- A standard Load Balancer
- A Network Security Group
- A Virtual Network
- Three NICs associated with the backend pool of the load balancer
- Three virtual machines with each vm in a different zone

For a more information about this template, see [Quickstart: Create a Standard Load Balancer to load balance VMs using the Azure portal](https://docs.microsoft.com/azure/load-balancer/quickstart-load-balancer-standard-public-portal)

