# Deployment of Red Hat Enterprise Linux VM (RHEL 7.2 or RHEL 6.7)

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-simple-rhel-unmanaged/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-simple-rhel-unmanaged/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-simple-rhel-unmanaged/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-simple-rhel-unmanaged/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-simple-rhel-unmanaged/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-simple-rhel-unmanaged/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-rhel-unmanaged%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-rhel-unmanaged%2Fazuredeploy.json" target="_blank"></a>


This template allows deploying a Red Hat Enterprise Linux VM (RHEL 7.2 or RHEL 6.7), using the latest image for the selected RHEL version. This will deploy a Standard D1 VM in the location of your chosen resource group with an additional 100 GiB data disk attached to the VM.

Independently form this template you can deploy a blank RHEL VM using the following Azure CLI commands (adjust parameters as needed):

```
azure config mode arm
azure group create TestCLIRG EastUS
azure vm quick-create TestCLIRG vm1 EastUS Linux RedHat:RHEL:7.2:latest azureuser
```

Note: this template and the above commands use RHEL Pay-As-You-Go VM image which carries an additional charge in addition to the base Linux VM price. Check out [RHEL VM pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/#red-hat) for more details.  

