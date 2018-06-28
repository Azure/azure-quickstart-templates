configuration MSFT_xIISFeatureDelegation_AllowDelegation
{
    Import-DscResource -ModuleName xWebAdministration

    xIisFeatureDelegation AllowDelegation
    {
        SectionName = 'security/authentication/anonymousAuthentication'
        OverrideMode = 'Allow'
    }
}

configuration MSFT_xIISFeatureDelegation_DenyDelegation
{
    Import-DscResource -ModuleName xWebAdministration

    xIisFeatureDelegation DenyDelegation
    {
        SectionName = 'defaultDocument'
        OverrideMode = 'Deny'
    }
}
