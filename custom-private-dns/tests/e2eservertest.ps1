#Login-AzureRmAccount
#New-AzureRmResourceGroup -Name "quicktest" -Location "West Europe"


New-AzureRmResourceGroupDeployment -ResourceGroupName "quicktest" -Name "test" -TemplateFile "azuredeploy.json" -newStorageAccountName "grbtemplatetest" -serverPublicDnsName "grbtemplatetest" -adminUsername "garbrad" -adminPassword (ConvertTo-SecureString "Gareth123123!" -AsPlainText -Force) -dnsZoneName "gareth.local"