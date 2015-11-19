# Create a new virtual machine in a DevTestLab instance.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-dtl-create-vm-builtin-user%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/101-dtl-create-vm-builtin-user/azuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>


This deployment template is generally used with non-sysprepped VHDs containing a built-in user account.

This template creates a new virtual machine in a DevTestLab instance.
- No new user account is created during the VM creation. 
- We assume that the original VM template already contains a built-in user account.
- We assume that this built-in account can be used to log into the VM after creation.
