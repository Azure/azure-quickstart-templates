# Simple Linux VM created with serial/console output configured

This is a simple template that will create a single VM with very limited parameters in order to demonstrate how to configure serial and console output. 

The interesting portion of this template worth noting is here:

		"diagnosticsProfile": {
          "bootDiagnostics": {
             "enabled": "true",
			 "storageUri": "[concat('http://',parameters('newStorageAccountName'),'.blob.core.windows.net')]"
          }
        }

The rest of the template is pretty standard. 
