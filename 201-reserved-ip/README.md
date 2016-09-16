# Snippet - Supported Reserved IP Use Cases

This template demonstrates the currently supported use case for Reserved IP.  A Reserved IP is simply a statically allocated Public IP.  

There is currently only one supported use case: assign a Reserved IP to the front end of the Azure Load Balancer.  

This template goes one step further: it both creates a new Reserved IP and assigns it to a load balancer and it uses a previously existing Reserved IP and assigns it to a separate load balancer.

# Parameters

Three parameters are needed in support of the "previously existing Reserved IP" use case:

1. existingRIPSubId - subscription ID of the subscription with the previously existing Reserved IP
2. existingRIPResourceGroupName - name of the resource group with the previously existing Reserved IP
3. existingRIPName - name of the previously existing Reserved IP

# How to Create 'Existing' Reserved IP

1. Create a resource group (or use an existing one)

`New-AzureResourceGroup -Name ExistingReservedIP -Location 'West US'`

2. Create a statically allocated PIP in that RG

`New-AzurePublicIpAddress -ResourceGroupName ExistingReservedIPRG -Name goliveRIP -Location 'West US'`  

This step is mandatory for the template to work as designed.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-reserved-ip%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-reserved-ip%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
