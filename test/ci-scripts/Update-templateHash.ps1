
param(
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-template-hash",
    [string]$StorageAccountName = "azurequickstartshash",
    [string]$TableName = "QuickStartsTemplateHash",
    [string]$RepoRoot = $ENV:BUILD_REPOSITORY_LOCALPATH,
    [string]$bearerToken,
    [Parameter(mandatory = $true)]$StorageAccountKey
)

If(!$RepoRoot.EndsWith("\")){
    $RepoRoot = "$RepoRoot\"
}

# Set values for the REST call to get the templateHash - this is only needed once during execution since it's the same for all REST calls
if ($bearerToken -eq "") {
    Write-Host "Getting token..."
    Import-Module Az.Accounts
    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $azContext = Get-AzContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
    $bearerToken = ($profileClient.AcquireAccessToken($azContext.Tenant.TenantId)).AccessToken
}
$uri = "https://management.azure.com/providers/Microsoft.Resources/calculateTemplateHash?api-version=2019-10-01"
$Headers = @{
    'Authorization' = "Bearer $bearerToken"
    'Content-Type'  = 'application/json'
}
# END

# Get the storage table that contains the hashes
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey "$StorageAccountKey" -Environment AzureCloud
$ctx | Out-String
Get-AzStorageTable –Name $tableName –Context $ctx -Verbose
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable

# Find all metadata.json files - each metadata file indicates a sample
$ArtifactFilePaths = Get-ChildItem -Path $RepoRoot .\metadata.json -Recurse -File | ForEach-Object -Process { $_.FullName }
foreach ($SourcePath in $ArtifactFilePaths) {

    if ($SourcePath -like "*\test\*") {
        Write-host "Skipping... $SourcePath"
        continue
    }

    #Write-Output "RepoRoot: $RepoRoot"
    $metadataPath = ($SourcePath | Split-Path)
    #Write-Output "MetadataPath: $metadataPath"
    $sampleName = $metadataPath -ireplace [regex]::Escape($RepoRoot), ""
    #Write-output "SampleName: $sampleName"
    $partitionKey = $sampleName.Replace("/", "@").Replace("\", "@")
    #Write-Output "PartitionKey: $partitionKey"
    
    # Find each template file in the sample (prereqs, nested, etc.)
    $JsonFilePaths = Get-ChildItem -Path $metadataPath .\*.json -Recurse -File | ForEach-Object -Process { $_.FullName }
    foreach ($file in $JsonFilePaths) {
        if ($file -like "*\test\*") {
            Write-host "Skipping..."
            continue
        }

        #Write-output $file
        $json = Get-Content -Path $file -Raw

        # Check the schema to see if this is a template, then get the hash and update the table
        if ($json -like "*deploymentTemplate.json#*") {
    
            # Get TemplateHash
            Write-Host "Requesting Hash for file: $file"
            try{ #fail the build for now so we can find issues
            $response = Invoke-RestMethod -Uri $uri `
                -Method "POST" `
                -Headers $Headers `
                -Body $json -verbose
            }catch{
                Write-Host $response
                Write-Error "Failed to get hash for: $file"
            }
            
            $templateHash = $response.templateHash

            # Find row in table if it exists, if it doesn't exist, add a new row with the new hash
            Write-Output "Fetching row for: *$templateHash*"

            $r = Get-AzTableRow -table $cloudTable -ColumnName "RowKey" -Value "$templateHash" -Operator Equal -verbose 
            if ($r -eq $null) {
                # Add this as a new hash
                Write-Output "$templateHash not found in table"

                Add-AzTableRow -table $cloudTable `
                    -partitionKey $partitionKey `
                    -rowKey $templateHash `
                    -property @{
                    "version"  = "$templateHash-$(Get-Date -Format 'yyyy-MM-dd')"; `
                        "file" = "$($file -ireplace [regex]::Escape("$RepoRoot$sampleName\"), '')"
                    }
            }
        }
    }
}
