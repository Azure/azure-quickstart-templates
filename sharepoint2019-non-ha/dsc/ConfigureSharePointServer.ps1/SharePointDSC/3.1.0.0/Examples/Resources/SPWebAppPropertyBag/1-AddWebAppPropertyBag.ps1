<#
.EXAMPLE
    This example shows how add property bag value in a web application.
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
            Key       = "KeyToAdd"
            Value     = "ValueToAddOrModify"
            Ensure    = "Present"
        }
    }
}
