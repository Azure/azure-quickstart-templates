cls
$RGName = "RG-VS-Dev";
$VMName = "jdvs2015vm";
$VMUsername = "jmd";
$ChocoPackages = "'linqpad;sysinternals;agentransack;beyondcompare;fiddler4;visualstudiocode;imageresizerapp;gimp'";
$ARMTemplate = "C:\@SourceControl\GitHub\ARMChocolatey\AzureDeploy.json"

# 1. Login
#Login-AzureRmAccount

#2. Create a resource group
New-AzureRmResourceGroup -Name $RGName -Location $DeployLocation -Force

#3. Create resources within RG
$sw = [system.diagnostics.stopwatch]::startNew()
New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile $ARMTemplate -vmName $VMName -vmAdminUserName $VMUsername -dnsLabelPrefix $VMName -vmVisualStudioVersion VS-2015-Ent-AzureSDK-2.8-WS2012R2 -chocoPackages $ChocoPackages -Mode Complete -Force 
$sw | Format-List -Property *

#4. Get the RDP file
Get-AzureRmRemoteDesktopFile -ResourceGroupName $RGName -Name $VMName -Launch -Verbose -Debug

