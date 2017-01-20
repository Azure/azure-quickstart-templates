# Create a specialized virtual machine in an existing virtual network

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-specialized-vhd-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-specialized-vhd-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Prerequisites

- VHD file that you want to create a VM from already exists in a storage account.
- Name of the existing VNET and subnet you want to connect the new virtual machine to.
- Name of the Resource Group that the VNET resides in.

```
NOTE

This template will create an additional Standard_GRS storage account for enabling boot diagnostics each time you execute this template. To avoid running into storage account limits, it's best to delete the storage account when the VM is deleted.
```

This template creates a VM from a specialized VHD and let you connect it to an existing VNET that can reside in another Resource Group then the virtual machine.

Plese note: This deployment template does not create or attach an existing Network Security Group to the virtual machine. 
