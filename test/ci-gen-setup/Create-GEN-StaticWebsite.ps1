# This is a separate script to 'Create-GEN-Artifacts.ps1' because the older AzureRM cmdlets used by that script don't support the necessary storage account data plane operations.

param(
    [string] $ResourceGroupName = 'ttk-gen-artifacts',
    [string] [Parameter(mandatory = $true)] $Location
)

# Create the resource group only if it doesn't exist.
if ((Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue) -eq $null) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force
}

$staticWebsiteStorageAccountName = 'stweb' + ((Get-AzContext).Subscription.Id).Replace('-', '').substring(0, 19)
$indexDocumentPath = 'index.htm'
$indexDocumentContents = '<h1>Example static website</h1>'
$errorDocument404Path = 'error.htm'
$errorDocumentContents = '<h1>Example 404 error page</h1>'

# Create the storage account if it doesn't already exist.
$staticWebsiteStorageAccount = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $staticWebsiteStorageAccountName })
if ($staticWebsiteStorageAccount -eq $null) {
    $staticWebsiteStorageAccount = New-AzStorageAccount -StorageAccountName $staticWebsiteStorageAccountName -Kind StorageV2 -Type 'Standard_LRS' -ResourceGroupName $ResourceGroupName -Location "$Location" -Verbose
}

# wait for replication
Do {
    Write-Host "Looking for storageAccount: $staticWebsiteStorageAccount"
    $staticWebsiteStorageAccount = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $staticWebsiteStorageAccountName })
} until ($staticWebsiteStorageAccountName -ne $null)

# Enable the static website feature on the storage account.
$ctx = $staticWebsiteStorageAccount.Context
Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $indexDocumentPath -ErrorDocument404Path $errorDocument404Path -Verbose

# Add the two HTML pages.
$tempIndexFile = New-TemporaryFile
Set-Content $tempIndexFile $indexDocumentContents -Force
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $tempIndexFile -Blob $indexDocumentPath -Properties @{'ContentType' = 'text/html'} -Force -Verbose

$tempErrorDocument404File = New-TemporaryFile
Set-Content $tempErrorDocument404File $errorDocumentContents -Force
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $tempErrorDocument404File -Blob $errorDocument404Path -Properties @{'ContentType' = 'text/html'} -Force -Verbose

# Create a JSON object for the placeholder values.
$json = New-Object System.Collections.Specialized.OrderedDictionary #This keeps things in the order we entered them, instead of: New-Object -TypeName Hashtable
$hostName = (($staticWebsiteStorageAccount.PrimaryEndpoints.Web) -Replace 'https://', '')  -Replace '/', ''
$json.Add("STATIC-WEBSITE-URL", $staticWebsiteStorageAccount.PrimaryEndpoints.Web)
$json.Add("STATIC-WEBSITE-HOST-NAME", $hostName)

# Output all the values needed for the config file.
Write-Output $($json | ConvertTo-json -Depth 30)
