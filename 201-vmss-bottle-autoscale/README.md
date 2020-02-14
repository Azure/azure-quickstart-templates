# Autoscale demo app on Ubuntu 16.04

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-bottle-autoscale/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-bottle-autoscale/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-bottle-autoscale/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-bottle-autoscale/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-bottle-autoscale/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-bottle-autoscale/CredScanResult.svg" />&nbsp;

Simple self-contained Ubuntu autoscale example which includes a Python Bottle server to do work. The VM Scale Set scales up when average CPU across all VMs > 60%, scales down when avg CPU < 30%.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-bottle-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-bottle-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

- Deploy the scale set with an instance count of 1
- After it is deployed look at the resource group public IP address resource (in portal or resources explorer). Get the IP or domain name.
- Browse to the website of vm#0 (port 9000), which shows the current backend VM name.
- To start doing work on the first VM browse to dns:9000/do_work
- After a few minutes the VM Scale Set capacity will increase. Note that the first scale out takes longer than subsequent ones whlie the autoscale pipeline gets initialized (i.e. wait up to half an hour before you concluding there's a problem).
- You can stop doing work by browsing to dns:9000/stop_work.

