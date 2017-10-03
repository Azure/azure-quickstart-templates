# Deploy a virtual machine with Azure Hybrid Benefit for Windows Server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a Windows Server VM with Azure Hybrid Benefit, using the latest Windows patched version. This will deploy a A2 size VM in the resource group location and return the fully qualified domain name of the VM. 

For more details about [Azure Hybrid Benefit for Windows Server](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing)

> [!IMPORTANT]
>It is important to ensure you have an eligible Windows Server license with Software Assurance to deploy this template. This template will deploy a VM as an Azure Hybrid Benefit which requires the user to have an existing on-prem license. [To learn more](https://azure.microsoft.com/en-us/pricing/hybrid-benefit/)
>