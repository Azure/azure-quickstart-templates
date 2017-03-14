#Login-AzureRmAccount 

"Script Root Is $PSScriptRoot"

New-AzureRmResourceGroup -Name "twoparttest" -Location "West Europe" -Force

New-AzureRmResourceGroupDeployment -Name "servertest" -ResourceGroupName "twoparttest" -TemplateFile "$PSScriptRoot/azuredeploy-server.json" -newStorageAccountName "grbtemplatetest2" -serverPublicDnsName "grbtemplatetest" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "gareth.local" -assetLocation "https://dnsfwshare.blob.core.windows.net:443/share"
#New-AzureRmResourceGroupDeployment -Name "clienttest" -ResourceGroupName "twoparttest" -TemplateFile "$PSScriptRoot/azuredeploy-clients.json" -newStorageAccountName "grbtemplatetest2" -serverPublicDnsName "grbtemplatetest" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "gareth.local" -assetLocation "https://dnsfwshare.blob.core.windows.net:443/share"
