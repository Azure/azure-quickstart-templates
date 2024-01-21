# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Init outputs
$DeploymentScriptOutputs = @{}

# 
$adfParams = @{
    ResourceGroupName = $env:DataFactoryResourceGroup
    DataFactoryName   = $env:DataFactoryName
}

# Delete old triggers
$triggers = Get-AzDataFactoryV2Trigger @adfParams -ErrorAction SilentlyContinue `
| Where-Object { $_.Name -match '^msexports?$' }
$DeploymentScriptOutputs["stopTriggers"] = $triggers | Stop-AzDataFactoryV2Trigger -Force -ErrorAction SilentlyContinue
$DeploymentScriptOutputs["deleteTriggers"] = $triggers | Remove-AzDataFactoryV2Trigger -Force -ErrorAction SilentlyContinue

# Delete old pipelines
$DeploymentScriptOutputs["pipelines"] = Get-AzDataFactoryV2Pipeline @adfParams -ErrorAction SilentlyContinue `
| Where-Object { $_.Name -match '^msexports_(extract|transform)$' } `
| Remove-AzDataFactoryV2Pipeline -Force -ErrorAction SilentlyContinue