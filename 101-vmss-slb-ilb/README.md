# Create VMSS with Internal and Public load balancer

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-backup-protect-iaasvm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-backup-protect-iaasvm%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<p>This template will create VMSS with Internal Load balancer (ILB) and Internet load balancer (SLB) - in custom VNET, using custom image created using storage account, existing vnet, subnet and existing public IP. </p>
<p>To create Azure VM image using Sysprep process - Windows - refer - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sa-copy-generalized</p>
<p>To create Azure VM image using Sysprep process - Linux - refer - https://docs.microsoft.com/en-us/azure/virtual-machines/linux/classic/capture-image</p>


