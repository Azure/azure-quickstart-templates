[string] $constPsPath = 'MACHINE/WEBROOT/APPHOST'
[string] $constAPDFilter = 'system.applicationHost/applicationPools/applicationPoolDefaults'
[string] $constSiteFilter = 'system.applicationHost/sites/'

[string] $originalValue = (Get-WebConfigurationProperty -pspath $constPsPath -filter $constAPDFilter -name managedRuntimeVersion).Value

configuration MSFT_xWebAppPoolDefaults_Config
{
    Import-DscResource -ModuleName xWebAdministration

    xWebAppPoolDefaults PoolDefaults
    {
        ApplyTo = 'Machine'
        ManagedRuntimeVersion = $originalValue
    }
}

configuration MSFT_xWebAppPoolDefaults_ManagedRuntimeVersion
{
    Import-DscResource -ModuleName xWebAdministration

    xWebAppPoolDefaults PoolDefaults
    {
        ApplyTo = 'Machine'
        ManagedRuntimeVersion = $env:PesterManagedRuntimeVersion
    }
}

configuration MSFT_xWebAppPoolDefaults_AppPoolIdentityType
{
    Import-DscResource -ModuleName xWebAdministration

    xWebAppPoolDefaults PoolDefaults
    {
        ApplyTo = 'Machine'
        IdentityType = $env:PesterApplicationPoolIdentity
    }
}

configuration MSFT_xWebAppPoolDefaults_LogFormat
{
    Import-DscResource -ModuleName xWebAdministration

    xWebSiteDefaults LogFormat
    {
        ApplyTo = 'Machine'
        LogFormat = $env:PesterLogFormat
    }
}

configuration MSFT_xWebAppPoolDefaults_DefaultPool
{
    Import-DscResource -ModuleName xWebAdministration

    xWebSiteDefaults DefaultPool
    {
        ApplyTo = 'Machine'
        DefaultApplicationPool = $env:PesterDefaultPool
    }
}
