#Requires -Version 3.0

Param(
  [string] $ResourceGroupName = 'deishbaio',
  [string] $ResourceGroupLocation = "West US",
  [string] $TemplateFile = '.\azuredeploy.json',
  [string] $ParametersFile = '.\azuredeploy-parameters.json',
  [string] $CloudInitFile = '.\cloud-config.yaml'  
)

Set-StrictMode -Version 3

# Convert relative paths to absolute paths if needed
$TemplateFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateFile)
$ParametersFile = [System.IO.Path]::Combine($PSScriptRoot, $ParametersFile)
$CloudInitFile = [System.IO.Path]::Combine($PSScriptRoot, $CloudInitFile)

# Read the initialization script & base64 encode it
$cloudInitContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($CloudInitFile))

# Create or update the resource group using the specified template file and template parameters file
Switch-AzureMode AzureResourceManager
New-AzureResourceGroup -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $TemplateFile `
                       -TemplateParameterFile $ParametersFile `
                       -customData $cloudInitContent `
                       -Force -Verbose
