# Create a Virtual Machine from a Linux Image with Empty Data Disk

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows creates a Linux VM with empty data disk

In the parameters file:

     "vmDiagnosticsStorageAccountResourceGroup":{ 
         "value" : "diagnosticsResourceGroup" 
     }, 
     "vmDiagnosticsStorageAccountName":{ 
         "value" : "diagnosticsStorageAccount" 
     }, 

the specified diagnostics storage account must be created in the specified diagnostics resource group.
