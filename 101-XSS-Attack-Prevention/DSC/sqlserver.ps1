[CmdletBinding()]
param (
    # Resource group name
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,

    # Sql server admin user
    [Parameter(Mandatory = $true)]
    [string]
    $SqlAdminUser,

    # Sql admin user password
    [Parameter(Mandatory = $true)]
    [securestring]
    $SqlAdminPassword
)

Function Get-StringHash([String]$String, $HashName = "SHA1") {
    $StringBuilder = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))| 
        ForEach-Object { [Void]$StringBuilder.Append($_.ToString("x2"))
    }
    $StringBuilder.ToString().Substring(0, 24)
}

$clientIPAddress = Invoke-RestMethod http://ipinfo.io/json | Select-Object -exp ip
$clientIPHash = (Get-StringHash $clientIPAddress).substring(0, 5)
$databaseName = "contosoclinic"
$artifactsLocation = Split-Path($PSScriptRoot)
$dbBackpacFilePath = "$artifactsLocation/artifacts/contosoclinic.bacpac"

$storageAccountNamePrefix = "xssattackstg"
$storageContainerName = "artifacts"
$artifactsStorageAccKeyType = "StorageAccessKey"

# Updating SQL server firewall rule
Write-Verbose -Message "Updating SQL server firewall rule."
$sqlServerName = (Get-AzureRmSqlServer -ResourceGroupName $ResourceGroupName).ServerName

New-AzureRmSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $sqlServerName -FirewallRuleName "ClientIpRule$clientIPHash" -StartIpAddress $clientIPAddress -EndIpAddress $clientIPAddress -ErrorAction SilentlyContinue
New-AzureRmSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $sqlServerName -FirewallRuleName "AllowAzureServices" -StartIpAddress 0.0.0.0 -EndIpAddress 0.0.0.0 -ErrorAction SilentlyContinue

Start-Sleep -Seconds 10

Write-Verbose "Get the storage account object."
$storageAccount = ((Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName) | Where-Object {$_.StorageAccountName -Like ($storageAccountNamePrefix + '*')})

Write-Verbose "Artifact storage account aleardy exists. Creating container"
New-AzureStorageContainer -Name $storageContainerName -Context $storageAccount.Context -ErrorAction SilentlyContinue

Write-Verbose "Container created."
# Retrieve Access Key 
$artifactsStorageAccKey = (Get-AzureRmStorageAccountKey -Name $storageAccount.StorageAccountName -ResourceGroupName $storageAccount.ResourceGroupName)[0].value 
Write-Verbose "Connection key retrieved."

Write-Verbose -Message "uploading sql bacpac file to storage account"
Set-AzureStorageBlobContent -File $dbBackpacFilePath -Blob "artifacts/contosoclinic.bacpac" `
            -Container $storageContainerName -Context $storageAccount.Context -Force

# Import SQL bacpac and update azure SQL DB Data masking policy

Write-Verbose -Message "Importing SQL bacpac and Updating Azure SQL DB Data Masking Policy"

$artifactsLocation = $storageAccount.Context.BlobEndPoint + $storageContainerName
# Importing bacpac file
Write-Verbose -Message "Importing SQL backpac from release artifacts storage account."
$sqlBacpacUri = "$artifactsLocation/artifacts/contosoclinic.bacpac"
$importRequest = New-AzureRmSqlDatabaseImport -ResourceGroupName $ResourceGroupName -ServerName $sqlServerName -DatabaseName $databaseName -StorageKeytype $artifactsStorageAccKeyType -StorageKey $artifactsStorageAccKey -StorageUri "$sqlBacpacUri" -AdministratorLogin $SqlAdminUser -AdministratorLoginPassword $SqlAdminPassword -Edition Standard -ServiceObjectiveName S0 -DatabaseMaxSizeBytes 50000
$importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
Write-Verbose "Importing.."
while ($importStatus.Status -eq "InProgress")
{
    $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    Write-Verbose "Database import is in progress... "
    Start-Sleep -s 5
}
$importStatus

Write-Host "Deployment Completed."