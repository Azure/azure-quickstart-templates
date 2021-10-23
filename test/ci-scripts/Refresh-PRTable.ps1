param(
    $GitHubRepository = "$ENV:BUILD_REPOSITORY_NAME",
    $BuildSourcesDirectory = "$ENV:BUILD_SOURCESDIRECTORY",
    $TableName = "QuickStartsMetadataServicePRs",
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-template-hash",
    [string]$StorageAccountName = "azurequickstartsservice",
    [Parameter(mandatory = $true)]$StorageAccountKey,
    [string]$basicAuthCreds # if needed to run manually add creds in the format of "user:token"
)

<#

Get all rows in the PR table
See if the PRs in GH have been closed, if so remove the row from the PR table

#>

$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey "$StorageAccountKey" -Environment AzureCloud
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable
$rows = Get-AzTableRow -table $cloudTable

foreach($r in $rows){

    $PRUri = "https://api.github.com/repos/$($GitHubRepository)/pulls/$($r.pr)"

    $response = ""
    if($basicAuthCreds){
        $response = curl -u $basicAuthCreds "$PRUri" | ConvertFrom-Json
    } else {
        $response = curl "$PRUri" | ConvertFrom-Json
    }

    Write-Host "PR# $($r.pr) is $($response.state)..."

    if($response.state -eq 'closed'){
        Write-Host "Removing... $($r.RowKey)"
        $r | Remove-AzTableRow -Table $cloudTable
    }

}