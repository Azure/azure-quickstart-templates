# Create VM rig for load testing using VSTS CLT service

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f101-VSTS-CLT-IaaSVMsLoadAgentRig%2fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f101-VSTS-CLT-IaaSVMsLoadAgentRig%2fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will help you to spin up a set of VMs that can be used to generate load through CLT service. The [parameters file](./azuredeploy.parameters.json) takes your VSTS account information and the number of desired VMs. These objects look like the following:

```json
{
    "VSTSAccountName": "dpksinghal",    
    "PATToken": "<get pat token for VSTS accoutn>",
    "vmCount": 1,
    "adminUsername": "cltuser",
    "adminPassword": "password!"    
}
```

