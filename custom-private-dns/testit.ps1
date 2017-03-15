#Login-AzureRmAccount 

"Script Root Is $PSScriptRoot"

$rgname = "customdnstest2"

New-AzureRmResourceGroup -Name $rgname -Location "West Europe" -Force

$params = @{
    "newStorageAccountName" = "grb$rgname";
    "serverPublicDnsName" = "grb$rgname";
    "adminUsername" =  "garbrad";
    "adminPassword" = "Gareth123123!";
    "dnsZoneName" = "default.local";
    "assetLocation" = "https://dnsfwshare.blob.core.windows.net:443/share"
}

New-AzureRmResourceGroupDeployment -Name $rgname -ResourceGroupName $rgname -TemplateFile "$PSScriptRoot/azuredeploy.json"  -TemplateParameterObject $params
