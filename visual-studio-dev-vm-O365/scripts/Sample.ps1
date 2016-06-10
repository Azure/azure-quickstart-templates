cls
$RGName = "RG-o365-devf2"; 
$VMName = "o2016vs2015u2";
$VMUsername = "o365dev";
$Dnsprefix = "jdo365vmf2"

$ARMTemplatePath = (get-item $PSScriptRoot).parent.FullName + "\azuredeploy.json"
$DeployLocation = "West Europe"

# 1. Set which version of Office you want installed Office2013 or Office 2016
$OfficeVersion  = "Office2016"; # Office2016

# 2. Login
#Login-AzureRmAccount

# 3. Create a resource group
New-AzureRmResourceGroup -Name $RGName -Location $DeployLocation -Force

# 4. Create resources - select which vmOSVersion you want to use
$sw = [system.diagnostics.stopwatch]::startNew()
New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile $ARMTemplatePath -vmName $VMName `
    -vmAdminUserName $VMUsername -dnsLabelPrefix $Dnsprefix -vmVisualStudioVersion VS-2015-Comm-VSU2-AzureSDK-29-W10T-N-x64 `
    -officeVersion $OfficeVersion -Mode Complete -Force | Out-Null
$sw | Format-List -Property *

# 5. Get the RDP file
Get-AzureRmRemoteDesktopFile -ResourceGroupName $RGName -Name $VMName -Launch

