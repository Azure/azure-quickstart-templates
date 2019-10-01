# Load test rig in a specific VNet for testing private apps

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vsts-cloudloadtest-rig-existing-vnet/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vsts-cloudloadtest-rig-existing-vnet/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vsts-cloudloadtest-rig-existing-vnet/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vsts-cloudloadtest-rig-existing-vnet/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vsts-cloudloadtest-rig-existing-vnet/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vsts-cloudloadtest-rig-existing-vnet/CredScanResult.svg" />&nbsp;


[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f201-vsts-cloudloadtest-rig-existing-vnet%2fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f201-vsts-cloudloadtest-rig-existing-vnet%2fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>
          
Using this template, you can create your own load test rig on Azure IaaS virtual machines in order to test applications that do not have a public end-point. The load generating agent machines will be created in the specified VNet. This VNet should have line of sight to the application you want to test. The test rig will be configured for your Azure DevOps Services account and can be used to run cloud-based load tests using Visual Studio.

To learn more about the scenarios in which you may want to provision your own rig,<a href="https://blogs.msdn.microsoft.com/visualstudioalm/2016/09/27/run-cloud-based-load-tests-using-your-own-machines-a-k-a-bring-your-own-subscription/" target="_blank"> click here</a>.

To learn about how to view and manage registered load agents for your Azure DevOps Services account,<a href="https://blogs.msdn.microsoft.com/visualstudioalm/2016/08/22/use-cloud-load-agents-on-your-infrastructure/" target="_blank"> click here</a>.

<img src="images/CLTAgentsOnVnet.png"/>
<b> Load generators inside a user's virtual network </b>

```json
{
    "AzureDevOpsServicesAccount": "<Azure DevOps Services account name using for CLT>",
    "PersonalAccessToken": "<Get PAT token for Azure DevOps Services account>",
    "AgentCount": "<number of desired VMs>",
    "AdminUsername":"<Admin user name>",
    "AdminPassword":"<password>" 
	"ExistingVNetResourceGroupName": "<Resource group name where the Vnet exists"
	"ExistingVNetName":"<VNet name>"
	"SubnetName":"<Subnet under VNet where you want to deployment load agents>"
}
```

If you wish to deploy a simple rig without an existing VNet, please use the following ARM template.

<a href="https://github.com/Azure/azure-quickstart-templates/tree/master/101-vsts-cloudloadtest-rig"> Create VM rig for load testing using VSTS CLT service </a>

