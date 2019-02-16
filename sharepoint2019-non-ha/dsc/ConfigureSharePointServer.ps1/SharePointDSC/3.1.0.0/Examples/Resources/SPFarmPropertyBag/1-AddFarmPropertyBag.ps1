<#
.EXAMPLE
    This example shows how add property bag in the current farm.
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
            Key = "FARM_TYPE"
            Value = "SearchFarm"
            Ensure = "Present"
        }
    }
}
