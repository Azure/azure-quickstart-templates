# Deploy a VM Scale Set of Linux VMs with a custom script extension in master / slave architecture

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-master-slave-customscript/azuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-master-slave-customscript/azuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## Description
This template allows you to deploy a VM Scale Set of Linux VMs and create a new virtual network at the same time. These VMs have a custom script extension for customization and are behind a load balancer with NAT rules for rdp connections. This allows to specify the master node number and data node number, adapt to any master / slave architecture



