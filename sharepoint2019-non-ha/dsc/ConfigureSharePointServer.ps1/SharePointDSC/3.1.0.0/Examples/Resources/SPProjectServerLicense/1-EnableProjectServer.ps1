<#
.EXAMPLE
    This example enables Project Server in the current environment
#>

Configuration Example
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $SetupAccount
    )
    Import-DscResource -ModuleName SharePointDsc

    node localhost {
        SPProjectServerLicense ProjectLicense
        {
            IsSingleInstance     = "Yes"
            ProductKey           = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
            PsDscRunAsCredential = $SetupAccount
        }
    }
}
