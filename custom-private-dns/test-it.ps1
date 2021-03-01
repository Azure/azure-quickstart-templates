Login-AzureRmAccount 

"Script Root Is $PSScriptRoot"

$rgname = "<a name for the resource group>"

New-AzureRmResourceGroup -Name $rgname -Location "West Europe" -Force

$params = @{
    "newStorageAccountName" = "<a name for the storage account>";
    "serverPublicDnsName" = "<a name for the public IP>";
    "adminUsername" =  "<admin name>";
    "adminPassword" = "<admin password>";
    "dnsZoneName" = "default.local";
}

New-AzureRmResourceGroupDeployment -Name "<deployment name>" -ResourceGroupName $rgname -TemplateFile "$PSScriptRoot/azuredeploy.json"  -TemplateParameterObject $params
