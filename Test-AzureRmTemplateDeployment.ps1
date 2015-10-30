#requires -version 3
<#
.SYNOPSIS
Executes one or many ARM template(s) deployment.

.DESCRIPTION
Enable testing of ARM templates using random value generation that mimic the validation the "Testing Bot" is performing on azure-quickstart-templates.

The script load the parameters file in memory and generate at runtime a random value that will replace '#####' values that are present.

A ResourceGroup will be created and named like your template, each processed template will have their own ResourceGroup 

.PARAMETER TemplateName 
one or many template name(s). Template name correspond to the name of the folder of a template.

.PARAMETER Location
the location of Resource Group to be created

.EXAMPLE

Execute the deployment of a template named: 100-starter-template-with-validation

Test-AzureRmTemplateDeployment.ps1 -TemplateName '100-starter-template-with-validation'


.NOTES

Make sure you authenticate properly in PowerShell and you are on the desired subscription because this script will not perform login/switch subscription for you.

Clean up is not performed after deployment, make sure you delete the created ResourceGroup to avoid cost.


#>
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string[]]
  $TemplateName,
  [Parameter(Position = 1)]
  [string]
  $Location = 'West US'
)
$ErrorActionPreference = 'Stop'

function Get-RandomValue 
{
  $set = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray() 
  $result = @()
  $result += $set | Get-Random
  $set = 'abcdefghijklmnopqrstuvwxyz0123456789'.ToCharArray()
  $result += 1..4 | ForEach-Object -Process { $set | Get-Random }  
  $result -join ''
}


if (Get-Command Get-AzureRmContext -ErrorAction SilentlyContinue)
{
  $newAzureRmModule = $true
}
else 
{
  Switch-AzureMode -Name AzureResourceManager
  $newAzureRmModule = $false
}

$TemplateName | ForEach-Object -Process {

  $currentTemplateName = Split-Path $_ -Leaf

  $templateFolder = Resolve-Path -Path $_ -ErrorAction SilentlyContinue

  
  if(-not $templateFolder) {
    $templateFolder = Join-Path -Path $PSScriptRoot -ChildPath $_ -Resolve -ErrorAction SilentlyContinue
  }

  Write-Host -Object ("Processing template '{0}' in location: '{1}' " -f $currentTemplateName, $templateFolder)
  if($templateFolder -eq $null) {
    Write-Error -Message "Unable to locate/resolve properly template '$currentTemplateName' "
  }

  #load parameters and replace ##### by random value
  $randomValue = Get-RandomValue
  $paramFile = Get-Content -Path $templateFolder\azuredeploy.parameters.json -Raw | ConvertFrom-Json
  $params = @{}
  $paramFile.parameters | Get-Member -MemberType NoteProperty | ForEach-Object -Process {
    $value = $paramFile.parameters.$($_.Name).value
    if ($value -eq '#####') {$value = $randomValue}
    $params[$_.Name] = $value
  }  

  $resourceGroupName = 'azure-quickstart-templates--{0}' -f $currentTemplateName
  if($newAzureRmModule) 
  {
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location -Force -Verbose
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFolder\azuredeploy.json -TemplateParameterObject $params -Mode Complete -Force -Verbose
  }
  else 
  {
    New-AzureResourceGroup -Name $resourceGroupName -Location $Location -Force -Verbose
    New-AzureResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFolder\azuredeploy.json -TemplateParameterObject $params -Mode Complete -Force -Verbose
  }
}