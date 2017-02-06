
Configuration Sample_xArchive_ExpandArchive
{
    param 
    ( 
        [parameter(mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [parameter (mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Destination
    ) 

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Node localhost
    {
        xArchive SampleExpandArchive
        {
            Path = $Path
            Destination = $Destination
        }
    }
}

Sample_xArchive_ExpandArchive
