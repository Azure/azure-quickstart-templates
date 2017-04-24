#Requires -Version 3.0
#Requires -Module AzureRM.Resources
#Requires -Module Azure.Storage
#Requires -Module AzureRM.Storage

Param(
    [string] [Parameter(Mandatory=$true)] $ArtifactStagingDirectory,
    [string] [Parameter(Mandatory=$true)] $ResourceGroupLocation,
    [string] $ResourceGroupName = $ArtifactStagingDirectory.replace('.\',''), #remove .\ if present
    [switch] $UploadArtifacts,
    [string] $StorageAccountName,
    [string] $StorageContainerName = $ResourceGroupName.ToLowerInvariant() + '-stageartifacts',
    [string] $TemplateFile = $ArtifactStagingDirectory + '\azuredeploy.json',
    [string] $TemplateParametersFile = $ArtifactStagingDirectory + '.\azuredeploy.parameters.json',
    [string] $DSCSourceFolder = $ArtifactStagingDirectory + '.\DSC',
    [switch] $ValidateOnly
#    [string] $DebugOptions = "None"
)

Import-Module Azure -ErrorAction SilentlyContinue

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(" ","_"), "AzureRMSamples")
} catch { }

Set-StrictMode -Version 3

$OptionalParameters = New-Object -TypeName Hashtable
<#
$v = (Get-Module -Name AzureRM.Resources).Version
If ($v.Major -eq 1 -and $v.Minor -eq 2){
    Write-Warning "DeploymentDebugLogLevel is not available in this version of Azure PowerShell"
}
else{
    $OptionalParameters.Add('DeploymentDebugLogLevel', $DebugOptions)
}
#>
$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))

if ($UploadArtifacts) {
    # Convert relative paths to absolute paths if needed
    $ArtifactStagingDirectory = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ArtifactStagingDirectory))
    $DSCSourceFolder = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $DSCSourceFolder))

    Set-Variable ArtifactsLocationName '_artifactsLocation' -Option ReadOnly -Force
    Set-Variable ArtifactsLocationSasTokenName '_artifactsLocationSasToken' -Option ReadOnly -Force
	Set-Variable ArtifactsLocationResourceIdName '_artifactsLocationResourceId' -Option ReadOnly -Force

    $TemplateFileContent = Get-Content $TemplateFile -Raw | ConvertFrom-Json
    $TemplateParametersFileContent = Get-Content $TemplateParametersFile -Raw | ConvertFrom-Json
    #$TemplateParametersFileContent = $TemplateFileContent | Get-Member -Type NoteProperty | Where-Object {$_.Name -eq "parameters"}
    if (Get-Member -InputObject $TemplateParametersFileContent -Name parameters) {
        $TemplateParameters= $TemplateParametersFileContent.parameters
    }
    else {
        $TemplateParameters = $TemplateParametersFileContent
    }

    # Create a storage account name if none was provided
    if($StorageAccountName -eq "") {
        $subscriptionId = ((Get-AzureRmContext).Subscription.SubscriptionId).Replace('-', '').substring(0, 19)
        $StorageAccountName = "stage$subscriptionId"
    }

    $StorageAccount = (Get-AzureRmStorageAccount | Where-Object{$_.StorageAccountName -eq $StorageAccountName})

    # Create the storage account if it doesn't already exist
    if($StorageAccount -eq $null){
        $StorageResourceGroupName = "ARM_Deploy_Staging"
        New-AzureRmResourceGroup -Location "$ResourceGroupLocation" -Name $StorageResourceGroupName -Force
        $StorageAccount = New-AzureRmStorageAccount -StorageAccountName $StorageAccountName -Type 'Standard_LRS' -ResourceGroupName $StorageResourceGroupName -Location "$ResourceGroupLocation"
    }

    $StorageAccountContext = $storageAccount.Context
    
    if (Get-Member -InputObject $TemplateFileContent.parameters -Name _artifactsLocation) {
        if (Get-Member -InputObject $TemplateParameters -Name _artifactsLocation) {
            $OptionalParameters.Add($ArtifactsLocationName, $TemplateParameters._artifactsLocation.value)
        }                
        else {
            $OptionalParameters.Add($ArtifactsLocationName, $StorageAccountContext.BlobEndPoint + $StorageContainerName)
        }
    }

    if (Get-Member -InputObject $TemplateFileContent.parameters -Name _artifactsLocationResourceId) {
        if (Get-Member -InputObject $TemplateParameters -Name _artifactsLocationResourceId) {
            $OptionalParameters.Add($artifactsLocationResourceIdName, $TemplateParameters._artifactsLocationResourceId.value)
        }
        else {
            $OptionalParameters.Add($artifactsLocationResourceIdName, $storageAccount.Id)
        }
    }
    
    # Create DSC configuration archive
    if (Test-Path $DSCSourceFolder) {
        $DSCFiles = Get-ChildItem $DSCSourceFolder -File -Filter "*.ps1" | ForEach-Object -Process {$_.FullName}
        foreach ($DSCFile in $DSCFiles) {
            $DSCZipFile = $DSCFile.Replace(".ps1",".zip")
            Publish-AzureVMDscConfiguration -ConfigurationPath $DSCFile -ConfigurationArchivePath $DSCZipFile -Force
        }
    }

    # Copy files from the local storage staging location to the storage account container
    New-AzureStorageContainer -Name $StorageContainerName -Context $StorageAccountContext -Permission Container -ErrorAction SilentlyContinue *>&1
    
    $ArtifactFilePaths = Get-ChildItem $ArtifactStagingDirectory -Recurse -File | ForEach-Object -Process {$_.FullName}
    foreach ($SourcePath in $ArtifactFilePaths) {
        $BlobName = $SourcePath.Substring($ArtifactStagingDirectory.length + 1)
        Set-AzureStorageBlobContent -File $SourcePath -Blob $BlobName -Container $StorageContainerName -Context $StorageAccountContext -Force
    }

    # Generate the value for artifacts location SAS token if it is not provided in the parameter file
    if (Get-Member -InputObject $TemplateFileContent.parameters -Name _artifactsLocationSasToken) {
        if (Get-Member -InputObject $TemplateParameters -Name _artifactsLocationSasToken) {
            $OptionalParameters.Add($ArtifactsLocationSasTokenName, $TemplateParameters._artifactsLocationSasToken.value)
        }
        else {
            $ArtifactsLocationSasToken = New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $StorageAccountContext -Permission r -ExpiryTime (Get-Date).AddHours(4)
            $ArtifactsLocationSasToken = ConvertTo-SecureString $ArtifactsLocationSasToken -AsPlainText -Force
            $OptionalParameters.Add($ArtifactsLocationSasTokenName, $ArtifactsLocationSasToken)
        }  
    }
}

# Create or update the resource group using the specified template file and template parameters file
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop 

if ($ValidateOnly) {
    Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                        -TemplateFile $TemplateFile `
                                        -TemplateParameterFile $TemplateParametersFile `
                                        @OptionalParameters `
                                        -Verbose
}
else {
    New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                       -ResourceGroupName $ResourceGroupName `
                                       -TemplateFile $TemplateFile `
                                       -TemplateParameterFile $TemplateParametersFile `
                                       @OptionalParameters `
                                       -Force -Verbose 
}
