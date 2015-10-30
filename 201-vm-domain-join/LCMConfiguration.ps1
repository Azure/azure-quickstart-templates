[DscLocalConfigurationManager()]
Configuration DCLCMConfig
{
    Settings
    {
        RebootNodeIfNeeded = $true
        ActionAfterReboot = 'ContinueConfiguration'
    }

}

DCLCMConfig -OutputPath "${env:Temp}\DCLCMConfig"
Set-DscLocalConfigurationManager -Path "${env:Temp}\DCLCMConfig"