# Create VM rig for load testing using VSTS CLT service

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f101-vsts-cloudloadtest-rig%2fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f101-vsts-cloudloadtest-rig%2fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Using this template, you can create your own load test rig on Azure IaaS virtual machines. The test rig will be configured for your Visual Studio Team Services (VSTS) account and can be used to run cloud-based load tests using Visual Studio. The cloud-load testing service will use this registered rig instead of provisioning one dynamically. 

To learn more about the scenarios in which you may want to provision your own rig,<a href="https://blogs.msdn.microsoft.com/visualstudioalm/2016/09/27/run-cloud-based-load-tests-using-your-own-machines-a-k-a-bring-your-own-subscription/" target="_blank"> click here</a>.

To learn about how to view and manage registered load agents for your VSTS account,<a href="https://blogs.msdn.microsoft.com/visualstudioalm/2016/08/22/use-cloud-load-agents-on-your-infrastructure/" target="_blank"> click here</a>.

Sample parameter values are as follows:

```json
{
    "VSTSAccountName": "<VSTS account name with which the rig will be configured>",
    "VSTSPersonalAccessToken": "<get pat token for VSTS account>",
    "AgentCount": "<number of VMs you want to provision>",
    "AdminUsername": "<admin user name>",
    "AdminPassword": "<admin user password>",
    "AgentGroupName": "<agent group name defaults to resource groupname>"   
}
```

If you wish to deploy a rig of load test agents in a private VNet (to directly generate load on a private application) please use the following ARM template.

<a href="https://github.com/Azure/azure-quickstart-templates/tree/master/201-vsts-cloudloadtest-rig-existing-vnet"> Load test rig in a specific VNet for testing private apps </a>
