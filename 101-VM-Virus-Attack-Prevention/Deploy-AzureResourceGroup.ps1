<#
Requires -Version 5.0
Requires -Module AzureRM 6.2.1
#>

Param(
    [string] [Parameter(Mandatory=$false)] $ResourceGroupName = "001-VM-Virus-Attack-Prevention",
    [string] [Parameter(Mandatory=$false)] $Location = "eastus",
    [string] $TemplateFile = $PSScriptRoot + '\azuredeploy.json',
    [string] $TemplateParametersFile = $PSScriptRoot + '\azuredeploy.parameters.json'
)

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force

$Password = Read-Host -Prompt 'Enter password for VM' -AsSecureString

$tmp = [System.IO.Path]::GetTempFileName()

$parametersObj = Get-Content -Path $TemplateParametersFile | ConvertFrom-Json
$parametersObj.parameters.adminUserPassword.value = (New-Object PSCredential "user",$Password).GetNetworkCredential().Password
( $parametersObj | ConvertTo-Json -Depth 10 ) -replace "\\u0027", "'" | Out-File $tmp

#Initiate resource group deployment
Write-Verbose "Initiate resource group deployment"
    New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $tmp -Name $ResourceGroupName -Mode Incremental `
        -DeploymentDebugLogLevel All -Verbose -Force

Write-Verbose "Deployment completed."
Write-Verbose "Deleting temp parameter file."
Remove-Item $tmp -Force

$deploymentOutput = Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $ResourceGroupName

Write-Host "VM UserName :"  $deploymentOutput.Outputs.Values.Value[0]
Write-Host "VM Password :"  $deploymentOutput.Outputs.Values.Value[1]

Write-Verbose "User these credentials to access the VMs an execute the scenario."