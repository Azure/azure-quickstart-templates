#Login-AzureRmAccount 

"Script Root Is $PSScriptRoot"

#New-AzureRmResourceGroup -Name "quicktest" -Location "West Europe"

#New-AzureRmResourceGroupDeployment -Name "SetupDnsClient" -ResourceGroupName "clienttest" -TemplateFile "$PSScriptRoot/../azuredeploy-server.json" -newStorageAccountName "grbtemplatetest" -serverPublicDnsName "grbtemplatetest" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "gareth.local" -assetLocation "https://dnsfwshare.blob.core.windows.net:443/share/custom-private-dns/"
New-AzureRmResourceGroupDeployment -Name "SetupDnsClient" -ResourceGroupName "clienttest" -TemplateFile "$PSScriptRoot/../azuredeploy-clients.json" -newStorageAccountName "grbtemplatetest" -serverPublicDnsName "grbtemplatetest" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "gareth.local" -assetLocation "https://dnsfwshare.blob.core.windows.net:443/share/custom-private-dns/"
