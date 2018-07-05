<#
Requires -Version 5.0
Requires -Module AzureRM 6.2.1
Requires -Module Azure.Storage  4.3.0
#>

Param(
    [string] [Parameter(Mandatory=$false)] $ResourceGroupName = "001-VM-Virus-Attack-Prevention",
    [string] [Parameter(Mandatory=$false)] $Location = "eastus",
    [switch] $SkipArtifactsUpload,
    [string] $TemplateFile = $PSScriptRoot + '\azuredeploy.json',
    [string] $TemplateParametersFile = $PSScriptRoot + '\azuredeploy.parameters.json'
)

Function Get-StringHash([String]$String, $HashName = "SHA1") {
    $StringBuilder = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))| 
        ForEach-Object { [Void]$StringBuilder.Append($_.ToString("x2"))
    }
    $StringBuilder.ToString().Substring(0, 24)
}

Import-Module -Name AzureRM -RequiredVersion '6.2.1'
Import-Module -Name Azure.Storage -RequiredVersion '4.3.0'

$storageContainerName = "artifacts"

$artifactStagingDirectories = @(
    "$PSScriptRoot\scripts"
    "$PSScriptRoot\nested"
)

$deploymentHash = (Get-StringHash ((Get-AzureRmContext).Subscription.Id)).substring(0, 9)
$storageAccountName = 'virusattack' + $deploymentHash

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force

Write-Verbose "Check if artifacts storage account exists."
$storageAccount = (Get-AzureRmStorageAccount | Where-Object {$_.StorageAccountName -eq $storageAccountName})

# Create the storage account if it doesn't already exist
if ($storageAccount -eq $null) {
    Write-Verbose "Artifacts storage account does not exists."
    Write-Verbose "Provisioning artifacts storage account."
    $storageAccount = New-AzureRmStorageAccount -StorageAccountName $storageAccountName -Type 'Standard_LRS' `
        -ResourceGroupName $ResourceGroupName -Location $Location
    Write-Verbose "Artifacts storage account provisioned."
    Write-Verbose "Creating storage container to upload a blobs."
    New-AzureStorageContainer -Name $storageContainerName -Context $storageAccount.Context -ErrorAction SilentlyContinue *>&1
}
else {
    Write-Verbose "Artifacts storage account exists."
    New-AzureStorageContainer -Name $storageContainerName -Context $storageAccount.Context -ErrorAction SilentlyContinue *>&1
}

if(!$SkipArtifactsUpload){
    # Copy files from the local storage staging location to the storage account container
    Write-Verbose "Uploading artifact staging directories."
    foreach ($artifactStagingDirectory in $artifactStagingDirectories) {
        $ArtifactFilePaths = Get-ChildItem $ArtifactStagingDirectory -Recurse -File | ForEach-Object -Process {$_.FullName}
        foreach ($SourcePath in $ArtifactFilePaths) {
            Set-AzureStorageBlobContent -File $SourcePath -Blob $SourcePath.Substring((Split-Path($ArtifactStagingDirectory)).length + 1) `
                -Container $storageContainerName -Context $storageAccount.Context -Force
        }
    }
}
Write-Verbose "Generating common deployment parameters"
$commonTemplateParameters = New-Object -TypeName Hashtable # Will be used to pass common parameters to the template.
$artifactsLocation = '_artifactsLocation'
$artifactsLocationSasToken = '_artifactsLocationSasToken'

$commonTemplateParameters[$artifactsLocation] = $storageAccount.Context.BlobEndPoint + $storageContainerName
$commonTemplateParameters[$artifactsLocationSasToken] = New-AzureStorageContainerSASToken -Container $storageContainerName -Context $storageAccount.Context -Permission r -ExpiryTime (Get-Date).AddHours(4)

$tmp = [System.IO.Path]::GetTempFileName()

$parametersObj = Get-Content -Path $TemplateParametersFile | ConvertFrom-Json
$parametersObj.parameters._artifactsLocation.value = $commonTemplateParameters[$artifactsLocation]
$parametersObj.parameters._artifactsLocationSasToken.value = $commonTemplateParameters[$artifactsLocationSasToken]
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