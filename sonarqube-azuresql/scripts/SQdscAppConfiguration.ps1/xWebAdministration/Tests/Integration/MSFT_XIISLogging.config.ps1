configuration MSFT_xIisLogging_Rollover
{
    Import-DscResource -ModuleName xWebAdministration

    xIisLogging Logging
    {
        LogPath = 'C:\IISLogFiles'
        Logflags = @('Date','Time','ClientIP','UserName','ServerIP')
        LoglocalTimeRollover = $true
        LogPeriod = 'Hourly'
        LogFormat = 'W3C'
    }
}

configuration MSFT_xIisLogging_Truncate
{
    Import-DscResource -ModuleName xWebAdministration

    xIisLogging Logging
    {
        LogPath = 'C:\IISLogFiles'
        Logflags = @('Date','Time','ClientIP','UserName','ServerIP')
        LoglocalTimeRollover = $true
        LogTruncateSize = '2097152'
        LogFormat = 'W3C'
    }
}
