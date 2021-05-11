# PS Script to run your ADF pipeline from the ADF V2 Quickstart Template
# Will execute the pipeline 1x and then show activity run status via monitoring API

<#

.SYNOPSIS
Use this script to execute a single activity run from your new ADF V2 pipeline generated from the Azure quickstart template gallery

.DESCRIPTION
Execute pipeline 1x and also monitor the status

.EXAMPLE
adfv2runmonitor.ps1 -resourceGroupName "adfv2" -DataFactoryName "ADFTutorialFactory09272dttm2p5xspjxy"

.NOTES
Required params: -resourceGroupName -DataFactoryName

#>

param (
    [string] $resourceGroupName,
    [string] $DataFactoryName
)

if(-not($resourceGroupName)) { Throw "You must supply a value for -resourceGroupName" }
if(-not($DataFactoryName)) { Throw "You must supply a value for -DataFactoryName" }

$runId = Invoke-AzureRmDataFactoryV2Pipeline -DataFactoryName $DataFactoryName -ResourceGroupName $resourceGroupName -PipelineName "ArmtemplateSampleCopyPipeline"

while ($True) {
$run = Get-AzureRmDataFactoryV2PipelineRun -ResourceGroupName $resourceGroupName -DataFactoryName $DataFactoryName -PipelineRunId $runId
if ($run) {
if ($run.Status -ne 'InProgress') {
Write-Host "Pipeline run finished. The status is: " $run.Status -foregroundcolor "Yellow"
$run
break
}
Write-Host  "Pipeline is running...status: InProgress" -foregroundcolor "Yellow"
}
Start-Sleep -Seconds 20
}



Write-Host "Activity run details:" -foregroundcolor "Yellow"
$result = Get-AzureRmDataFactoryV2ActivityRun -DataFactoryName $DataFactoryName -ResourceGroupName $resourceGroupName -PipelineRunId $runId -RunStartedAfter (Get-Date).AddMinutes(-30) -RunStartedBefore (Get-Date).AddMinutes(30)
$result

Write-Host "Activity 'Output' section:" -foregroundcolor "Yellow"
$result.Output -join "`r`n"

Write-Host "\nActivity 'Error' section:" -foregroundcolor "Yellow"
$result.Error -join "`r`n"
