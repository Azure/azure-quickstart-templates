configuration Sample_IISServerDefaults
{
    param
    (
        # Target nodes to apply the configuration
        [string[]]$NodeName = 'localhost'
    )

    # Import the module that defines custom resources
    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    Node $NodeName
    {
         xWebSiteDefaults SiteDefaults
         {
            ApplyTo = 'Machine'
            LogFormat = 'IIS'
            AllowSubDirConfig = 'true'
         }


         xWebAppPoolDefaults PoolDefaults
         {
            ApplyTo = 'Machine'
            ManagedRuntimeVersion = 'v4.0'
            IdentityType = 'ApplicationPoolIdentity'
         }
    }
}
