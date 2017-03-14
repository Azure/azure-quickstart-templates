#Login-AzureRmAccount 

"Script Root Is $PSScriptRoot"
New-AzureRmResourceGroupDeployment -Name "SetupDnsClient" -ResourceGroupName "quicktest" -TemplateFile "$PSScriptRoot/../linux-client/setuplinuxclient.json" -dnsZone "gareth.local" -vmList "linclient"
New-AzureRmResourceGroupDeployment -Name "SetupDnsClient" -ResourceGroupName "quicktest" -TemplateFile "$PSScriptRoot/../windows-client/setupwinclient.json" -dnsZone "gareth.local" -vmList "winclient"