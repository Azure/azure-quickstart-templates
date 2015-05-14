# Deploy an App Service Environment with an AppService Plan and Logic App onto an existing Virtual Network

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fappserviceenvironment-with-serviceplan%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [YOSSIDAHAN](https://github.com/yossidahan)

This template creates a new AppService Environment on a specified Subnet in a pre-existign Virtual Netowrk. 
It proceeds to create an AppService hosting plan preparing the environment to recieve Web, API and Logic apps.
Finally - it deploys a sample Logic app that calls http://www.example.com on a schedule

The template assumes a 'Classic' network has been pre-provisioned that includes a subnet onto which to deploy the environment.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location  | The Azure Location in which to create the environment; needs to match the location of the VNET referenced |
| environmentName  | The name to use for the new AppService Environment |
| ipSslAddressCount  | The number of IP Addresses to create for the environment |
| worker1Size | The size of VM to use for Worker Pool 1 |
| worker1count | The number of VM to use for Worker Pool 1 |
| worker2Size | The size of VM to use for Worker Pool 2 |
| worker2count  | The number of VM to use for Worker Pool 2 |
| frontendSize | The size of VM to use for FrontEnd Pool |
| frontendCount | The number of VM to use for FrontEnd Pool |
| worker3Size | The size of VM to use for Worker Pool 3 |
| worker3count | The number of VM to use for Worker Pool 3 |
| vnetName | The name of the VNET onto which to deploy the environment |
| vnetResourceGroupName | The name of the Resource Group to which the VNET has been deployed |
| subnetName | The name of the Subnet onto which to deploy the environment |
| serverFarmName | The name of the AppService Plan to create |
| serverFarmSKU |  The SKU of the AppService Plan to create) |
| serverFarmWorkerSize | The size of the AppService Plan worker VMs  |
| logicAppName | The name of the Logic App to create  |


##Known Issues and Limitations
- At present only API and Logic Apps add support for AppService Environment this should just work for these too
- At present the template expects a ClassNetwork
