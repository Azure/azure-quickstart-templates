configuration MSFT_xIISHandler_RemoveHandler
{
    Import-DscResource -ModuleName xWebAdministration

    xIisHandler TRACEVerbHandler
    {
        Name = 'TRACEVerbHandler'
        Ensure = 'Absent'
    }
}

configuration MSFT_xIISHandler_AddHandler
{
    Import-DscResource -ModuleName xWebAdministration

    xIisHandler WebDAV
    {
        Name = 'WebDAV'
        Ensure = 'Present'
    }
}

configuration MSFT_xIISHandler_StaticFileHandler
{
    Import-DscResource -ModuleName xWebAdministration

    xIisHandler StaticFile
    {
        Name = 'StaticFile'
        Ensure = 'Present'
    }
}
