#Login-AzureRmAccount 

"Script Root Is $PSScriptRoot"

New-AzureRmResourceGroup -Name "twoparttest3" -Location "West Europe" -Force

New-AzureRmResourceGroupDeployment -Name "servertest" -ResourceGroupName "twoparttest3" -TemplateFile "$PSScriptRoot/azuredeploy-server.json" -newStorageAccountName "grbtemplatetest3" -serverPublicDnsName "grbtemplatetest3" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "gareth.local" -assetLocation "https://dnsfwshare.blob.core.windows.net:443/share"
#New-AzureRmResourceGroupDeployment -Name "clienttest" -ResourceGroupName "twoparttest3" -TemplateFile "$PSScriptRoot/azuredeploy-clients.json" -newStorageAccountName "grbtemplatetest3" -serverPublicDnsName "grbtemplatetest3" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "gareth.local" -assetLocation "https://dnsfwshare.blob.core.windows.net:443/share"
