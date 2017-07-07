# Create a VM with a dynamic selection of data disks


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-dynamic-data-disks-selection%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-dynamic-data-disks-selection%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows the user to create a VM with dynamic selection of data disks without creating a per size template with different number of data disks. The disksSelector.json template takes in the number of disks required as input and forms the expected data disk array. It then passes the data disks array back to the main template using its outputs section.