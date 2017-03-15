#Login-AzureRmAccount 

"Script Root Is $PSScriptRoot"

$rgname = "customdnstest1"
New-AzureRmResourceGroup -Name $rgname -Location "West Europe" -Force
New-AzureRmResourceGroupDeployment -Name $rgname -ResourceGroupName $rgname -TemplateFile "$PSScriptRoot/azuredeploy.json"  -newStorageAccountName "grb$rgname" -serverPublicDnsName "grb$rgname" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "default.local" -assetLocation "https://dnsfwshare.blob.core.windows.net:443/share"

