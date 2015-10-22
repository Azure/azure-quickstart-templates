# Simple Linux VM created with serial/console output configured
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-linux-vm-serial-output%2Fazuredeploy.json) 

This is a simple template that will create a single VM with very limited parameters in order to demonstrate how to configure serial and console output. 

The interesting portion of this template worth noting is here:

		"diagnosticsProfile": {
          "bootDiagnostics": {
             "enabled": "true",
			 "storageUri": "[concat('http://',parameters('newStorageAccountName'),'.blob.core.windows.net')]"
          }
        }

The rest of the template is pretty standard. 
