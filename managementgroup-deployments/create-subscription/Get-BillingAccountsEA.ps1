<#
    .Synopsis
        Get all the billing scopes a the authenticated user has access to
    .Description
        This script will retrive the billing accounts and enrollment accounts the authenticated user has access to.
        
        The information is needed to determine the billingScope property value when create an subscription via the
        Microsoft.Subscription/aliases resource.  Nothing will be returned from the script if the user does not have
        access to any billing or enrollment accounts.

        The script can be used for an Enterprise Agreement account, for other agreements the script will need to be modified.
#>

$billingAccountPath = "/providers/Microsoft.Billing/billingaccounts/?api-version=2020-05-01"

$billingAccounts = ($(Invoke-AzRestMethod -Method "GET" -path $billingAccountPath).Content | ConvertFrom-Json).value

foreach ($ba in $billingAccounts) {
    Write-Host "Billing Account: $($ba.name)"
    $enrollmentAccountUri = "/providers/Microsoft.Billing/billingaccounts/$($ba.name)/enrollmentAccounts/?api-version=2019-10-01-preview"
    $enrollmentAccounts = ($(Invoke-AzRestMethod -Method "GET" -path $enrollmentAccountUri ).Content | ConvertFrom-Json).value

    foreach($account in $enrollmentAccounts){
        Write-Host "  Enrollment Account: $($account.name)"
    }
}
