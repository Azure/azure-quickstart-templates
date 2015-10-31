Configuration DCLCMConfig
{
    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $true
    }

}

DCLCMConfig -OutputPath "${env:Temp}\DCLCMConfig"
Set-DscLocalConfigurationManager -Path "${env:Temp}\DCLCMConfig" -Verbose