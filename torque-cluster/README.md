# Deploy a Torque cluster

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/torque-cluster/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/torque-cluster/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/torque-cluster/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/torque-cluster/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/torque-cluster/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/torque-cluster/CredScanResult.svg" />&nbsp;

<a href="http://www.adaptivecomputing.com/products/open-source/torque/">Torque</a> (Terascale Open-source Resource and QUEue Manager) is an open source distributed resource manager providing control over batch jobs and distributed compute nodes. This templates will deploy a Torque cluster in Azure based on CentOS 6.6. See <a href="http://docs.adaptivecomputing.com/torque/5-1-0/help.htm">Adaptive Computing</a> website for more detail.

##Deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftorque-cluster%2Fazuredeploy.json" target="_blank">
   <img alt="Deploy to Azure" src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftorque-cluster%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

1. Fill in the 3 mandatory parameters - public DNS name, a storage account to hold VM image, and admin user password.

2. Fill in other info and click "OK".

## Using the cluster

Simply SSH to the master node and do a srun! The DNS name is _**dnsName**_._**location**_.cloudapp.azure.com, for example, yidingtorque.westus.cloudapp.azure.com.

