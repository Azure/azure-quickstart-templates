#Requires -Version 3.0
#Requires -Module Az.Resources
#Requires -Module Az.Storage

Param(
    [string] [Parameter(Mandatory = $true)] $ArtifactStagingDirectory,
    [string] [Parameter(Mandatory = $true)][alias("ResourceGroupLocation")] $Location,
    [string] $ResourceGroupName = (Split-Path $ArtifactStagingDirectory -Leaf),
    [switch] $UploadArtifacts,
    [string] $StorageAccountName,
    [string] $StorageContainerName = $ResourceGroupName.ToLowerInvariant() + '-stageartifacts',
    [string] $TemplateFile = $ArtifactStagingDirectory + '\mainTemplate.json',
    [string] $TemplateParametersFile = $ArtifactStagingDirectory + '.\azuredeploy.parameters.json',
    [string] $DSCSourceFolder = $ArtifactStagingDirectory + '.\DSC',
    [switch] $BuildDscPackage,
    [switch] $ValidateOnly,
    [string] $DebugOptions = "None",
    [string] $Mode = "Incremental",
    [string] $DeploymentName = ((Split-Path $TemplateFile -LeafBase) + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')),
    [string] $ManagementGroupId,
    [switch] $Dev,
    [switch] $bicep,
    [switch] $whatIf
)

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("AzQuickStarts-$UI$($host.name)".replace(" ", "_"), "1.0")
}
catch { }

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Format-ValidationOutput {
    param ($ValidationOutput, [int] $Depth = 0)
    Set-StrictMode -Off
    return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @('  ' * $Depth + ': ' + $_.Message) + @(Format-ValidationOutput @($_.Details) ($Depth + 1)) })
}

$OptionalParameters = New-Object -TypeName Hashtable
$TemplateArgs = New-Object -TypeName Hashtable
$ArtifactStagingDirectory = ($ArtifactStagingDirectory.TrimEnd('/')).TrimEnd('\')

# if the bicep switch is set, and the templateFile arg was the default, swap .json for .bicep
$isBicep = ($bicep -or $TemplateFile.EndsWith('.bicep'))
if ($isBicep){
    $defaultTemplateFile = '\main.bicep'
} else {
    $defaultTemplateFile = '\azuredeploy.json'
}

# if the template file isn't found, try another default
if (!(Test-Path $TemplateFile)) { 
    $TemplateFile = $ArtifactStagingDirectory + $defaultTemplateFile
}

# build the bicep file
if ($isBicep){
    bicep build $TemplateFile
    # now point the deployment to the json file that was just build
    $TemplateFile = $TemplateFile.Replace('.bicep', '.json')
    $fromBicep = "(from bicep build)"
}else{
    $fromBicep = ""
}

Write-Host "Using template file $($fromBicep):  $TemplateFile"

#try a few different default options for param files when the -dev switch is use
if ($Dev) {
    $TemplateParametersFile = $TemplateParametersFile.Replace('azuredeploy.parameters.json', 'azuredeploy.parameters.dev.json')
    if (!(Test-Path $TemplateParametersFile)) {
        $TemplateParametersFile = $TemplateParametersFile.Replace('azuredeploy.parameters.dev.json', 'azuredeploy.parameters.1.json')
    }
}

Write-Host "Using parameter file: $TemplateParametersFile"

if (!$ValidateOnly) {
    $OptionalParameters.Add('DeploymentDebugLogLevel', $DebugOptions)
    if ($whatIf) {
        $OptionalParameters.Add('WhatIf', $whatIf)
    }
}

$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))

$TemplateJSON = Get-Content $TemplateFile -Raw | ConvertFrom-Json

$TemplateSchema = $TemplateJson | Select-Object -expand '$schema' -ErrorAction Ignore

switch -Wildcard ($TemplateSchema) {
    '*tenantDeploymentTemplate.json*' {
        $deploymentScope = "Tenant"
    }
    '*managementGroupDeploymentTemplate.json*' {
        $deploymentScope = "ManagementGroup"
    }
    '*subscriptionDeploymentTemplate.json*' {
        $deploymentScope = "Subscription"
    }
    '*/deploymentTemplate.json*' {
        $deploymentScope = "ResourceGroup"
        $OptionalParameters.Add('Mode', $Mode)
        if(!$ValidateOnly -and !$WhatIf) {
            $OptionalParameters.Add('Force', $true)
        }
    }
}

Write-Host "Running a $deploymentScope scoped deployment..."

$ArtifactsLocationName = '_artifactsLocation'
$ArtifactsLocationSasTokenName = '_artifactsLocationSasToken'
$ArtifactsLocationParameter = $TemplateJson | Select-Object -expand 'parameters' -ErrorAction Ignore | Select-Object -Expand $ArtifactsLocationName -ErrorAction Ignore
$ArtifactsLocationSasTokenParameter = $TemplateJson | Select-Object -expand 'parameters' -ErrorAction Ignore | Select-Object -Expand $ArtifactsLocationSasTokenName -ErrorAction Ignore
$useAbsolutePathStaging = $($ArtifactsLocationParameter -ne $null)

# if the switch is set or the standard parameter is present in the template, upload all artifacts
if ($UploadArtifacts -Or $useAbsolutePathStaging -or $ArtifactsLocationSasTokenParameter) {
    # Convert relative paths to absolute paths if needed
    $ArtifactStagingDirectory = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ArtifactStagingDirectory))
    $DSCSourceFolder = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $DSCSourceFolder))

    # Parse the parameter file and update the values of artifacts location and artifacts location SAS token if they are present
    if (Test-Path $TemplateParametersFile) {
        $JsonParameters = Get-Content $TemplateParametersFile -Raw | ConvertFrom-Json
        if (($JsonParameters | Get-Member -Type NoteProperty 'parameters') -ne $null) {
            $JsonParameters = $JsonParameters.parameters
        }
    }
    else {
        $JsonParameters = @{ }
    }
    
    # if using _artifacts* parameters, add them to the optional params and get the value from the param file (if any)
    if ($useAbsolutePathStaging) {
        $OptionalParameters[$ArtifactsLocationName] = $JsonParameters | Select-Object -Expand $ArtifactsLocationName -ErrorAction Ignore | Select-Object -Expand 'value' -ErrorAction Ignore
        $OptionalParameters[$ArtifactsLocationSasTokenName] = $JsonParameters | Select-Object -Expand $ArtifactsLocationSasTokenName -ErrorAction Ignore | Select-Object -Expand 'value' -ErrorAction Ignore
    }

    # Create DSC configuration archive
    if ((Test-Path $DSCSourceFolder) -and ($BuildDscPackage)) {
        $DSCSourceFilePaths = @(Get-ChildItem $DSCSourceFolder -File -Filter '*.ps1' | ForEach-Object -Process { $_.FullName })
        foreach ($DSCSourceFilePath in $DSCSourceFilePaths) {
            $DSCArchiveFilePath = $DSCSourceFilePath.Substring(0, $DSCSourceFilePath.Length - 4) + '.zip'
            Publish-AzVMDscConfiguration $DSCSourceFilePath -OutputArchivePath $DSCArchiveFilePath -Force -Verbose
        }
    }

    # Create a storage account name if none was provided
    if ($StorageAccountName -eq '') {
        $StorageAccountName = 'stage' + ((Get-AzContext).Subscription.Id).Replace('-', '').substring(0, 19)
    }

    $StorageAccount = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $StorageAccountName })

    # Create the storage account if it doesn't already exist
    if ($StorageAccount -eq $null) {
        $StorageResourceGroupName = 'ARM_Deploy_Staging'
        if ((Get-AzResourceGroup -Name $StorageResourceGroupName -Verbose -ErrorAction SilentlyContinue) -eq $null) {
            New-AzResourceGroup -Name $StorageResourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
        }
        $StorageAccount = New-AzStorageAccount -StorageAccountName $StorageAccountName -Type 'Standard_LRS' -ResourceGroupName $StorageResourceGroupName -Location "$Location"
    }

    if ($StorageContainerName.length -gt 63) {
        $StorageContainerName = $StorageContainerName.Substring(0, 63)
    }
    $ArtifactStagingLocation = $StorageAccount.Context.BlobEndPoint + $StorageContainerName + "/"   

    # Generate the value for artifacts location if it is not provided in the parameter file
    if ($useAbsolutePathStaging -and $OptionalParameters[$ArtifactsLocationName] -eq $null) {
        #if the defaultValue for _artifactsLocation is using the template location, use the defaultValue, otherwise set it to the staging location
        $defaultValue = $ArtifactsLocationParameter | Select-Object -Expand 'defaultValue' -ErrorAction Ignore
        if ($defaultValue -like '*deployment().properties.templateLink.uri*') {
            $OptionalParameters.Remove($ArtifactsLocationName) # just use the defaultValue if it's using the template language function
        }
        else {
            $OptionalParameters[$ArtifactsLocationName] = $ArtifactStagingLocation   
        }
    } 

    # Copy files from the local storage staging location to the storage account container
    New-AzStorageContainer -Name $StorageContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue *>&1

    $ArtifactFilePaths = Get-ChildItem $ArtifactStagingDirectory -Recurse -File | ForEach-Object -Process { $_.FullName }
    foreach ($SourcePath in $ArtifactFilePaths) {
        
        if ($SourcePath -like "$DSCSourceFolder*" -and $SourcePath -like "*.zip" -or !($SourcePath -like "$DSCSourceFolder*")) {
            #When using DSC, just copy the DSC archive, not all the modules and source files
            $blobName = ($SourcePath -ireplace [regex]::Escape($ArtifactStagingDirectory), "").TrimStart("/").TrimStart("\")
            Set-AzStorageBlobContent -File $SourcePath -Blob $blobName -Container $StorageContainerName -Context $StorageAccount.Context -Force
        }
    }

    # Generate a 4 hour SAS token for the artifacts location if one was not provided in the parameters file
    # first check to see if we need a sasToken (if it was not already provided in the param file or we're using relativePath)
    if ($useAbsolutePathStaging -or $OptionalParameters[$ArtifactsLocationSasTokenName] -eq $null) {
        $sasToken = (New-AzStorageContainerSASToken -Container $StorageContainerName -Context $StorageAccount.Context -Permission r -ExpiryTime (Get-Date).AddHours(4))
    }

    # now set the parameter value for the QueryString or _artifactsLocationSasToken as appropriate
    if($OptionalParameters[$ArtifactsLocationSasTokenName] -eq $null -and $useAbsolutePathStaging){
        $OptionalParameters[$ArtifactsLocationSasTokenName] = ConvertTo-SecureString $sasToken -AsPlainText -Force
        $TemplateArgs.Add('TemplateUri', $ArtifactStagingLocation + (Get-ChildItem $TemplateFile).Name + $sasToken)
    }elseif (!$useAbsolutePathStaging) {
        $OptionalParameters['QueryString'] = $sasToken.TrimStart("?") # remove leading ? as it is not part of the QueryString
        $TemplateArgs.Add('TemplateUri', $ArtifactStagingLocation + (Get-ChildItem $TemplateFile).Name)
    }
}
else {

    $TemplateArgs.Add('TemplateFile', $TemplateFile)

}

if (Test-Path $TemplateParametersFile) {
    $TemplateArgs.Add('TemplateParameterFile', $TemplateParametersFile)
}
Write-Host ($TemplateArgs | Out-String)
Write-Host ($OptionalParameters | Out-String)

# Create the resource group only when it doesn't already exist - and only in RG scoped deployments
if ($deploymentScope -eq "ResourceGroup") {
    if ((Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue) -eq $null) {
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
    }
}

if ($ValidateOnly) {
    
    switch ($deploymentScope) {
        "resourceGroup" {
            $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName @TemplateArgs @OptionalParameters)
        }
        "Subscription" {
            $ErrorMessages = Format-ValidationOutput (Test-AzDeployment -Location $Location @TemplateArgs @OptionalParameters)
        }
        "managementGroup" {           
            $ErrorMessages = Format-ValidationOutput (Test-AzManagementGroupDeployment -Location $Location @TemplateArgs @OptionalParameters)
        }
        "tenant" {
            $ErrorMessages = Format-ValidationOutput (Test-AzTenantDeployment -Location $Location @TemplateArgs @OptionalParameters)
        }
    }

    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}

else {

    $ErrorActionPreference = 'Continue' # Switch to Continue" so multiple errors can be formatted and output
    
    switch ($deploymentScope) {
        "resourceGroup" {
            New-AzResourceGroupDeployment -Name $DeploymentName `
                -ResourceGroupName $ResourceGroupName `
                @TemplateArgs `
                @OptionalParameters `
                -Verbose `
                -ErrorVariable ErrorMessages
        }
        "Subscription" {
            New-AzDeployment -Name $DeploymentName `
                -Location $Location `
                @TemplateArgs `
                @OptionalParameters `
                -Verbose `
                -ErrorVariable ErrorMessages
        }
        "managementGroup" {           
            New-AzManagementGroupDeployment -Name $DeploymentName `
                -ManagementGroupId $managementGroupId `
                -Location $Location `
                @TemplateArgs `
                @OptionalParameters `
                -Verbose `
                -ErrorVariable ErrorMessages
        }
        "tenant" {
            New-AzTenantDeployment -Name $DeploymentName `
                -Location $Location `
                @TemplateArgs `
                @OptionalParameters `
                -Verbose `
                -ErrorVariable ErrorMessages
        }
    }
    
    $ErrorActionPreference = 'Stop' 
    if ($ErrorMessages) {
        Write-Output '', 'Template deployment returned the following errors:', '', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message })
        Write-Error "Deployment failed."
    }

}
