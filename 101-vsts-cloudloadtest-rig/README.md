# Create VM rig for load testing using Azure DevOps CLT service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vsts-cloudloadtest-rig/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vsts-cloudloadtest-rig/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vsts-cloudloadtest-rig/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vsts-cloudloadtest-rig/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vsts-cloudloadtest-rig/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vsts-cloudloadtest-rig/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f101-vsts-cloudloadtest-rig%2fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f101-vsts-cloudloadtest-rig%2fazuredeploy.json)

Using this template, you can create your own load test rig on Azure IaaS virtual machines. The test rig will be configured for your Azure DevOps Services account and can be used to run cloud-based load tests using Visual Studio. The cloud-load testing service will use this registered rig instead of provisioning one dynamically. 

To learn more about the scenarios in which you may want to provision your own rig,<a href="https://blogs.msdn.microsoft.com/visualstudioalm/2016/09/27/run-cloud-based-load-tests-using-your-own-machines-a-k-a-bring-your-own-subscription/" target="_blank"> click here.

To learn about how to view and manage registered load agents for your Azure DevOps Services account,<a href="https://blogs.msdn.microsoft.com/visualstudioalm/2016/08/22/use-cloud-load-agents-on-your-infrastructure/" target="_blank"> click here.

Sample parameter values are as follows:

```json
{
    "AzureDevOpsServicesAccount": "<Azure DevOps Services account name with which the rig will be configured>",
    "PersonalAccessToken": "<get pat token for Azure DevOps Services account>",
    "AgentCount": "<number of VMs you want to provision>",
    "AdminUsername": "<admin user name>",
    "AdminPassword": "<admin user password>",
    "AgentGroupName": "<agent group name defaults to resource groupname>"   
}
```

If you wish to deploy a rig of load test agents in a private VNet (to directly generate load on a private application) please use the following ARM template.

<a href="https://github.com/Azure/azure-quickstart-templates/tree/master/201-vsts-cloudloadtest-rig-existing-vnet"> Load test rig in a specific VNet for testing private apps 


