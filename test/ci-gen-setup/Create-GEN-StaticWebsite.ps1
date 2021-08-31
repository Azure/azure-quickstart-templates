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
$staticWebsiteStorageAccount = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $staticWebsiteStorageAccountName })
$indexDocumentPath = 'index.htm'
$indexDocumentContents = '<h1>Example static website</h1>'
$errorDocument404Path = 'error.htm'
$errorDocumentContents = '<h1>Example 404 error page</h1>'

# Create the storage account if it doesn't already exist.
if ($staticWebsiteStorageAccount -eq $null) {
    $staticWebsiteStorageAccount = New-AzStorageAccount -StorageAccountName $staticWebsiteStorageAccountName -Type 'Standard_LRS' -ResourceGroupName $ResourceGroupName -Location "$Location"
}

# Enable the static website feature on the storage account.
$ctx = $staticWebsiteStorageAccount.Context
Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $indexDocumentPath -ErrorDocument404Path $errorDocument404Path

# Add the two HTML pages.
New-Item $indexDocumentPath -Force
Set-Content $indexDocumentPath $indexDocumentContents -Force
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $indexDocumentPath -Blob $indexDocumentPath -Properties @{'ContentType' = 'text/html'} -Force

New-Item $errorDocument404Path -Force
Set-Content $errorDocument404Path $errorDocumentContents -Force
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $errorDocument404Path -Blob $errorDocument404Path -Properties @{'ContentType' = 'text/html'} -Force

# Create a JSON object for the placeholder values.
$json = New-Object System.Collections.Specialized.OrderedDictionary #This keeps things in the order we entered them, instead of: New-Object -TypeName Hashtable
$hostName = (($staticWebsiteStorageAccount.PrimaryEndpoints.Web) -Replace 'https://', '')  -Replace '/', ''
$json.Add("STATIC-WEBSITE-URL", $staticWebsiteStorageAccount.PrimaryEndpoints.Web)
$json.Add("STATIC-WEBSITE-HOST-NAME", $hostName)

# Output all the values needed for the config file.
Write-Output $($json | ConvertTo-json -Depth 30)
