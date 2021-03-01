#Requires -Version 3.0
#Requires -Module Az.Resources
#Requires -Module Az.Storage

#use this script to side-load a createUIDefinition.json file in the Azure portal

[cmdletbinding()]
param(
    [string] $ArtifactsStagingDirectory = ".",
    [string] $createUIDefFile='createUIDefinition.json',
    [string] $storageContainerName='createuidef',
    [string] $StorageResourceGroupLocation, # this must be specified only when the staging resource group needs to be created - first run or if the account has been deleted
    [switch] $Gov
)

try {

    $StorageAccountName = 'stage' + ((Get-AzContext).Subscription.Id).Replace('-', '').substring(0, 19)
    $StorageAccount = (Get-AzStorageAccount | Where-Object{$_.StorageAccountName -eq $StorageAccountName})

    # Create the storage account if it doesn't already exist
    if ($StorageAccount -eq $null) {
        if ($StorageResourceGroupLocation -eq "") { throw "The StorageResourceGroupLocation parameter is required on first run in a subscription." }
        $StorageResourceGroupName = 'ARM_Deploy_Staging'
        New-AzResourceGroup -Location "$StorageResourceGroupLocation" -Name $StorageResourceGroupName -Force
        $StorageAccount = New-AzStorageAccount -StorageAccountName $StorageAccountName -Type 'Standard_LRS' -ResourceGroupName $StorageResourceGroupName -Location "$StorageResourceGroupLocation"
    }

    New-AzStorageContainer -Name $StorageContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue *>&1

    Set-AzStorageBlobContent -Container $StorageContainerName -File "$ArtifactsStagingDirectory\$createUIDefFile"  -Context $storageAccount.Context -Force
        
    $uidefurl = New-AzStorageBlobSASToken -Container $StorageContainerName -Blob (Split-Path $createUIDefFile -leaf) -Context $storageAccount.Context -FullUri -Permission r   
    $encodedurl = [uri]::EscapeDataString($uidefurl)

if ($Gov) {

$target=@"
https://portal.azure.us/#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{"providerConfig":{"createUiDefinition":"$encodedurl"}}
"@

}
else {

$target=@"
https://portal.azure.com/#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{"providerConfig":{"createUiDefinition":"$encodedurl"}}
"@

}

Write-Host `n"File: "$uidefurl `n
Write-Host "Target URL: "$target

# launching the default browser doesn't work if the default is Chrome - so force edge here
Start-Process "microsoft-edge:$target"

}
catch {
      throw $_
}
