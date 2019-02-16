<#
.EXAMPLE
    This example shows how remove a property bag value in a web application.
#>

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $SetupAccount
    )

    Import-DscResource -ModuleName SharePointDsc

    node localhost
    {
        SPWebAppPropertyBag APPLICATION_APPCodeProperty
        {
            PsDscRunAsCredential = $SetupAccount
            WebAppUrl = "https://web.contoso.com"
            Key = "KeyToRemove"
            Ensure = "Absent"
        }
    }
}
