# Simple Linux VM created with serial/console output configured
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-linux-serial-output%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-linux-serial-output%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This is a simple template that will create a single VM with very limited parameters in order to demonstrate how to configure serial and console output.

The interesting portion of this template worth noting is here:

		"diagnosticsProfile": {
          "bootDiagnostics": {
             "enabled": "true",
			 "storageUri": "[concat('http://',parameters('newStorageAccountName'),'.blob.core.windows.net')]"
          }
        }

The rest of the template is pretty standard.
