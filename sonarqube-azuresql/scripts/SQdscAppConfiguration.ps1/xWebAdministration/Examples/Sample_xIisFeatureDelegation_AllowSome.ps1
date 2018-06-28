configuration Sample_IISFeatureDelegation
{
    param
    (
        # Target nodes to apply the configuration
        [string[]] $NodeName = 'localhost'
    )

    # Import the module that defines custom resources
    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    Node $NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name   = 'Web-Server'
        }

        # Allow Write access to some section that normally don't have it.
        xIisFeatureDelegation serverRuntime
        {
            SectionName  = 'serverRuntime'
            OverrideMode = 'Allow'
        }
        xIisFeatureDelegation anonymousAuthentication
        {
            SectionName  = 'security/authentication/anonymousAuthentication'
            OverrideMode = 'Allow'
        }

        xIisFeatureDelegation ipSecurity
        {
            SectionName  = 'security/ipSecurity'
            OverrideMode = 'Allow'
        }
    }
}
