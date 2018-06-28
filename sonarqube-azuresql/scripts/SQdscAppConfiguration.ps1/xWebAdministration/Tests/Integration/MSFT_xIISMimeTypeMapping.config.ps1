configuration MSFT_xIISMimeTypeMapping_Config
{
    Import-DscResource -ModuleName xWebAdministration

    xIIsMimeTypeMapping AddMimeType
    {
        Extension = '.PesterDummy'
        MimeType = 'text/plain'
        Ensure = 'Present'
    }
}

configuration MSFT_xIISMimeTypeMapping_AddMimeType
{
    Import-DscResource -ModuleName xWebAdministration

    xIIsMimeTypeMapping AddMimeType2
    {
        Extension = $env:PesterFileExtension2
        MimeType = $env:PesterMimeType2
        Ensure = 'Present'
    }
}

configuration MSFT_xIISMimeTypeMapping_RemoveMimeType
{
    Import-DscResource -ModuleName xWebAdministration

    xIIsMimeTypeMapping RemoveMimeType
    {
        Extension = $env:PesterFileExtension
        MimeType = $env:PesterMimeType
        Ensure = 'Absent'
    }
}

configuration MSFT_xIISMimeTypeMapping_RemoveDummyMime
{
    Import-DscResource -ModuleName xWebAdministration

    xIIsMimeTypeMapping RemoveMimeType2
    {
        Extension = '.PesterDummy2'
        MimeType = 'text/dummy'
        Ensure = 'Absent'
    }
}
