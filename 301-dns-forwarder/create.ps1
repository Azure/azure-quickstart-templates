$name = "DnsForwardExample"

Login-AzureRmAccount


New-AzureRmResourceGroup -Name $name -Location "northeurope" -force

$params = @{
    "adminUsername"="mradmin";
    "adminPassword"="Admin123!";
    "storageAccName"="$($name)stor".ToLower();
}

New-AzureRmResourceGroupDeployment -Name $name -ResourceGroupName $name -TemplateFile "C:\Users\garbrad\OneDrive - Microsoft\DNS Firewalls\DNS Forwarder For Gallery\mainTemplate.json" -TemplateParameterObject $params

