$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

$imageTemplateName = ${env:imageTemplateName}

function Log([string] $message, [switch] $asError) {
    $formattedTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss.ff"
    $formattedMessage = "[$formattedTime $imageTemplateName] $message"
    if ($asError) {
        Write-Error $formattedMessage
    }
    else {
        Write-Host $formattedMessage
    }
}

RunWithRetries { Connect-AzAccount -Identity | Out-Null }
RunWithRetries { Install-Module -Name Az.ImageBuilder -AllowPrerelease -Force -Verbose }

$preBuildPauseSeconds = 30
Log "=== Pausing for $preBuildPauseSeconds seconds for the template and prerequisites to complete initialization"
Start-Sleep -Seconds $preBuildPauseSeconds

Log "=== Starting the image build"
RunWithRetries {
    $info = $null
    try {
        $info = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName ${env:resourceGroupName}
    }
    catch {
        Log "$_`n=== The template might still be initializing - wait a bit more before starting the build"
        Start-Sleep -Seconds 60
    }

    if ($info -and $info.LastRunStatusRunState) {
        Log "=== Already started"
    }
    else {
        Invoke-AzResourceAction -ResourceName "$imageTemplateName" -ResourceGroupName "${env:resourceGroupName}" -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -ApiVersion "2020-02-14" -Action Run -Force
    }
}

Log "=== Waiting for the image build to complete"

# https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.powershell.cmdlets.imagebuilder.support.runstate?view=az-ps-latest
$global:status = 'UNKNOWN'
while ($global:status -ne 'Succeeded' -and $global:status -ne 'Failed' -and $global:status -ne 'Canceled') { 
    Start-Sleep -Seconds 15
    RunWithRetries {
        $global:info = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName ${env:resourceGroupName}
        $global:status = $info.LastRunStatusRunState
    }
}

$buildStatusShort = "status '$global:status', message '$($global:info.LastRunStatusMessage)'"
Log "=== Image build completed with $buildStatusShort"

$ignoreBuildFailure = [bool]::Parse("${env:ignoreBuildFailure}")
if ( (!$ignoreBuildFailure) -and ($global:status -ne 'Succeeded')) {
    Start-Sleep -Seconds 15 # Appears to help with the script output being captured in full
    Log -asError "!!! [ERROR] Image build failed with $buildStatusShort"
}

$printCustomizationLogLastLines = [int]::Parse("${env:printCustomizationLogLastLines}")
if ($printCustomizationLogLastLines -ne 0) {

    $stagingResourceGroupName = ${env:stagingResourceGroupName}
    $logsFile = 'customization.log'
    Log "=== Looking for storage account in staging RG '$stagingResourceGroupName'"
    $stagingStorageAccountName = (Get-AzResource -ResourceGroupName $stagingResourceGroupName -ResourceType "Microsoft.Storage/storageAccounts")[0].Name

    $stagingStorageAccountKey = $(Get-AzStorageAccountKey -StorageAccountName $stagingStorageAccountName -ResourceGroupName $stagingResourceGroupName)[0].value
    $ctx = New-AzStorageContext -StorageAccountName $stagingStorageAccountName -StorageAccountKey $stagingStorageAccountKey
    $logsBlob = Get-AzStorageBlob -Context $ctx -Container packerlogs | Where-Object { $_.Name -like "*/$logsFile" }
    if ($logsBlob) {
        Log "=== Downloading $logsFile from storage account '$stagingStorageAccountName'"
        Get-AzStorageBlobContent -Context $ctx -CloudBlob $logsBlob.ICloudBlob -Destination $logsFile -Force | Format-List

        if ($printCustomizationLogLastLines -gt 0) {
            Log "=== Last $printCustomizationLogLastLines lines of $logsFile :`n"
            Log "$(Get-Content $logsFile -Tail $printCustomizationLogLastLines | Out-String)"
        }
        else {
            Log "=== Content of $logsFile :`n"
            Log "$(Get-Content $logsFile | Out-String)"
        }
    }
    else {
        Log "Could not find customization.log in storage account: $stagingStorageAccountName"
    }
}

Log "=== DONE"
Start-Sleep -Seconds 15 # Appears to help with the script output being captured in full
