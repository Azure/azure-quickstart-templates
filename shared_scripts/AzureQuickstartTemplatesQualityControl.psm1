#requires -version 3

# AutoCompletion for 
$rootPath = Split-Path $PSScriptRoot -Parent

$completion_Template = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    Get-ChildItem $rootPath -Directory | Sort-Object -Property Name -Unique | Where-Object { $_.Name -like "$wordToComplete*" } |ForEach-Object {
        New-Object System.Management.Automation.CompletionResult $_.Name, $_.Name, 'ParameterValue', ('{0} ({1})' -f $_.Description, $_.ID) 
    }
}

if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{};NativeArgumentCompleters = @{}}}
$global:options['CustomArgumentCompleters']['Test-AzureQuickstartTemplate:TemplateName'] = $Completion_Template

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'
#

function Get-TemplateUniqueValue {
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string]
  $TemplateName
)
  $uniqueTemplateName = '{0}{1}{2}' -f $TemplateName,$env:COMPUTERNAME,$env:USERNAME
  $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
  $utf8 = new-object -TypeName System.Text.UTF8Encoding
  $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($uniqueTemplateName)))
  
  'a{0}{1}' -f $env:USERNAME[0],($hash -replace '-','').ToLower().Substring(1,12)
}

<#
.SYNOPSIS
Executes one or many ARM template(s) deployment.

.DESCRIPTION
Enable testing of ARM templates using deterministic value generation that mimic the validation the "Testing Bot" is performing on azure-quickstart-templates.

The script load the parameters file in memory and generate at runtime a deterministic value that will replace '#####' values that are present.

A ResourceGroup will be created and named like your template, each processed template will have their own ResourceGroup 

.PARAMETER TemplateName 
one or many template name(s). Template name correspond to the name of the folder of a template.

.PARAMETER Location
the location of Resource Group to be created

.EXAMPLE
Execute the deployment of a template named: 100-starter-template-with-validation

Test-AzureQuickstartTemplate -TemplateName '100-starter-template-with-validation'


.NOTES
Make sure you authenticate properly in PowerShell and you are on the desired subscription because this script will not perform login/switch subscription for you.

Clean up is not performed after deployment, make sure you delete the created ResourceGroup to avoid cost.

Created by Stephane Lapointe <stephane@stephanelapointe.net>
http://www.codeisahighway.com

#>
function Test-AzureQuickstartTemplate {
param(
	[Parameter(Position = 0, Mandatory = $true)]
	[string[]]
	$TemplateName,
	[Parameter(Position = 1)]
	[string]
	$Location = 'West US'
)
	$ErrorActionPreference = 'Stop'


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
    $uniqueValue = Get-TemplateUniqueValue -TemplateName $currentTemplateName
  
	  if(-not $templateFolder) {
		$templateFolder = Join-Path -Path $PSScriptRoot -ChildPath ..\$_ -Resolve -ErrorAction SilentlyContinue
	  }

	  Write-Host -Object ("Processing template '{0}' in location: '{1}' " -f $currentTemplateName, $templateFolder)
	  if($templateFolder -eq $null) {
		Write-Error -Message "Unable to locate/resolve properly template '$currentTemplateName' "
	  }

	  #load parameters and replace ##### by unique value
	  $paramFile = Get-Content -Path $templateFolder\azuredeploy.parameters.json -Raw | ConvertFrom-Json
	  $params = @{}
	  $paramFile.parameters | Get-Member -MemberType NoteProperty | ForEach-Object -Process {
		  $value = $paramFile.parameters.$($_.Name).value
		  if ($value -eq '#####') {
        $value = $uniqueValue
      }
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
}

Export-ModuleMember -Function Test-AzureQuickstartTemplate