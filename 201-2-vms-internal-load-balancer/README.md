# Create 2 Virtual Machines under an Internal Load balancer and configures Load Balancing rules for the VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-internal-load-balancer%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-internal-load-balancer%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create 2 Virtual Machines under an Internal Load balancer

This template also deploys a Storage Account, Virtual Network, Availability Set and Network Interfaces.

The Azure Load Balancer is assigned a static IP in the Virtual Network and is  configured to load balance on Port 80.


**Steps to deploy manually**

- Create a resource group: New-AzureResourceGroup -Name "ILB-DemoRG" -Location "West US"

- Modify the 2VMsinVnetWithILB-parameters file to update your subscriptionId and change naming convention

- Deploy: New-AzureResourceGroupDeployment –Name IPDep1 -ResourceGroupName ILB-DemoRG -TemplateFile 2VMsinVnetWithILB.json -TemplateParameterFile 2VMsinVnetWithILB-parameters.json
