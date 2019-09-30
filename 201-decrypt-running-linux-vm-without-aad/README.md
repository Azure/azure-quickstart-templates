# This template disables data disk encryption of a Linux VM with no AAD

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-decrypt-running-linux-vm-without-aad/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-decrypt-running-linux-vm-without-aad/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-decrypt-running-linux-vm-without-aad/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-decrypt-running-linux-vm-without-aad/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-decrypt-running-linux-vm-without-aad/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-decrypt-running-linux-vm-without-aad/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-decrypt-running-linux-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-decrypt-running-linux-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template disables encryption of data disks on a running Linux VM with no AAD if only data disks were encrypted.   If the OS disk was also encrypted, this scenario is not supported and is expected to fail. 

Tags: AzureDiskEncryption

References:
White paper - https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/

