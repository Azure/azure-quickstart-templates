$RGName = "PR-devo365-W7"; 
$VMName = "jdo365devw7";
$VMUsername = "o365dev";

$ARMTemplatePath = (get-item $PSScriptRoot).parent.FullName + "\Choco\visual-studio-dev-vm-O365\azuredeploy.json"
$DeployLocation = "West Europe"

# 1. Set which version of Office you want installed Office2013 or Office 2016
$OfficeVersion  = "Office2013"; # Office2016

# 2. Login
#Login-AzureRmAccount
Write-Host $ARMTemplatePath 

# 3. Create a resource group
New-AzureRmResourceGroup -Name $RGName -Location $DeployLocation -Force

# 4. Create resources - select which vmOSVersion you want to use
$sw = [system.diagnostics.stopwatch]::startNew()
New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile $ARMTemplatePath -vmAdminUserName $VMUsername -dnsLabelPrefix $VMName -vmVisualStudioVersion VS-2015-Comm-VSU3-AzureSDK-291-Win10-N -officeVersion $OfficeVersion -Mode Complete -Force | Out-Null
$sw | Format-List -Property *

# 5. Get the RDP file
Get-AzureRmRemoteDesktopFile -ResourceGroupName $RGName -Name $VMName -Launch
