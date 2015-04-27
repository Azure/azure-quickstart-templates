#Requires -Version 3.0
<#
	Gonzalo :
    Group of VMS Managed by Ansible. 
    Login into AnsibleController VM and manage all the created VMs from there 
#>


Param(
  [string] $ResourceGroupLocation ="West US",
  [string] $ResourceGroupName = "agrccouhcent1",
  [string] $DeploymentName = "csa1cb-dev",
  [string] $TemplateFile =".\azuredeploy.json",
  [string] $TemplateParametersFile = ".\azuredeploy-parameters.json"
  
)

$DebugPreference ='Continue'
#$DebugPreference = "SilentlyContinue"
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


#Switch-AzureMode -Name AzureResourceManager
clear
Set-StrictMode -Version 3

#TO DO
#VALIDATE THAT PARAMETERS ONLY CONTAIN LETTERS AND NUMBERS


Switch-AzureMode AzureResourceManager
clear

if((Get-AzureResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue) -eq $null)
{
    New-AzureResourceGroup -Name $resourceGroupName -Location $ResourceGroupLocation 
}

$validation = Test-AzureResourceGroupTemplate -ResourceGroupName $resourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $TemplateParametersFile #-TemplateParameterObject $templateParametersObject
$validation
if($validation.Count -eq 0)
{
    New-AzureResourceGroupDeployment  -Name $DeploymentName -ResourceGroupName $resourceGroupName `
                                      -TemplateFile  $templateFile  -TemplateParameterFile $templateParametersFile #-TemplateParameterObject $templateParametersObject 

}


