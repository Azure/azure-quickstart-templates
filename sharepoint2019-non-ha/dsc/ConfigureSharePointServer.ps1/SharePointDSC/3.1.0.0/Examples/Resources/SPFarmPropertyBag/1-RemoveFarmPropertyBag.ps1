<#
.EXAMPLE
    This example shows how remove property bag in the current farm.
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
        SPFarmPropertyBag APPLICATION_APPCodeProperty
        {
            PsDscRunAsCredential = $SetupAccount
            Key = "KeyToRemove"
            Ensure = "Absent"
        }
    }
}
