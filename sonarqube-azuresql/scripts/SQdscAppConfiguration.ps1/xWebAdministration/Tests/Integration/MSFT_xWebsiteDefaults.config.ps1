[string] $originalValue = (Get-WebConfigurationProperty `
    -PSPath 'MACHINE/WEBROOT/APPHOST' `
    -Filter 'system.applicationHost/sites/virtualDirectoryDefaults' `
    -Name 'allowSubDirConfig').Value

if ($originalValue -eq "true")
{
    $env:PesterVirtualDirectoryDefaults = "false"
}
else
{
    $env:PesterVirtualDirectoryDefaults = "true"
}

configuration MSFT_xWebsiteDefaults_Config
{
    Import-DscResource -ModuleName xWebAdministration

    xWebSiteDefaults virtualDirectoryDefaults
    {
        ApplyTo = 'Machine'
        AllowSubDirConfig = "$env:PesterVirtualDirectoryDefaults"
    }
}
