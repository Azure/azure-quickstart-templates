<#
.EXAMPLE
    This example shows how to deploy the Managed Metadata service app to the local SharePoint farm.
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
        SPManagedMetaDataServiceAppDefault ManagedMetadataServiceAppDefault
        {
            IsSingleInstance               = "Yes"
            DefaultSiteCollectionProxyName = "Managed Metadata Service Application Proxy"
            DefaultKeywordProxyName        = "Managed Metadata Service Application Proxy"
            InstallAccount                 = $SetupAccount
        }
    }
}
