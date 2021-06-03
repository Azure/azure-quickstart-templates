<#
    .Synopsis
        This script will create a subscription via an alias.
    .Description
        This script will create a subscription via the Microsoft.Subscription/aliases resource.  The user running the script
        must be authenticated and have permission to create the subscription at the specified billing scope.

        The script can be used for an Enterprise Agreement account, for other agreements the script will need to be modified.
#>

Param(
    [string] [Parameter(Mandatory = $true)]$aliasName,
    [string] $displayName = $aliasName,
    [string] [ValidateSet("DevTest", "Production")]$workLoad = "DevTest",
    [string] [Parameter(Mandatory = $true)]$billingAccount,
    [string] [Parameter(Mandatory = $true)]$enrollmentAccount
    )

$body = @{
    properties = @{
        workload     = $workLoad
        displayName  = $displayName
        billingScope = "/providers/Microsoft.Billing/billingAccounts/$billingAccount/enrollmentAccounts/$enrollmentAccount"
    }
}

$uri = "/providers/Microsoft.Subscription/aliases/$($aliasName)?api-version=2020-09-01"

$bodyJSON = $body | ConvertTo-Json -Compress -Depth 30

Invoke-AzRestMethod -Method "PUT" -Path $uri -Payload $bodyJSON

# wait for a terminal state
do {
    Start-Sleep 5
    $status = (Invoke-AzRestMethod -Method "GET" -path $uri -Verbose).Content | ConvertFrom-Json
    Write-Host $status.properties.provisioningState
} while ($status.properties.provisioningState -eq "Running" -or $status.properties.provisioningState -eq "Accepted")

$status | ConvertTo-Json -Depth 30
