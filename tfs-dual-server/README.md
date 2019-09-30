# TFS - 3 VM domain deployment

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tfs-dual-server/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-dual-server%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> 
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-dual-server%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-dual-server%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/> 
</a>

This template creates a TFS deployment with three VMs. One VM serves as a domain controller for the other two. One of the domain-joined VMs will run SQL Server Standard edition. The second will run TFS, configured to use SQL on the first. All three will support RDP through NAT rules on a load balancer. This template is meant to be used to evaluate TFS in Azure, not as a production deployment.

## After Deployment

All three VMs are behind a public-facing load balancer with NAT rules enabling RDP. To access TFS you can RDP into any of the VMs using the IP address on the load balancer, and the username & password provided during the deployment. TFS will be available on port 8080 (e.g. http://vmName:8080/tfs)

