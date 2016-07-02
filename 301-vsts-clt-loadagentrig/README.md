# Create VM rig for load testing using VSTS CLT service

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f301-vsts-clt-loadagentrig%2fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f301-vsts-clt-loadagentrig%2fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Using this template, you can create your own load test rig on Azure IaaS virtual machines. The test rig will be configured for your Visual Studio Team Services (VSTS) account and can be used to run cloud-based load tests using Visual Studio. The cloud-load testing service will use this registered rig instead of provisioning one dynamically. Sample parameter values are as follows:

```json
{
    "VSTSAccountName": "xyz",    
    "PATToken": "<get pat token for VSTS account>",
    "vmCount": 1,
    "adminUsername": "admin",
    "adminPassword": "password" 
}
```

