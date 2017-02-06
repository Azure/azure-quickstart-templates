
Configuration Sample_xArchive_CompressArchive
{
    param 
    ( 
        [parameter(mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path,

        [parameter (mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Destination,

        [parameter (mandatory=$false)]
        [ValidateSet("Optimal","NoCompression","Fastest")]
        [string]
        $CompressionLevel = "Optimal",

        [parameter (mandatory=$false)]
        [boolean]
        $MatchSource = $false
    ) 

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost
    {
        xArchive SampleCompressArchive
        {
            Path = $Path
            Destination = $Destination
            CompressionLevel = $CompressionLevel
            DestinationType="File"
            MatchSource=$MatchSource
        }
    }
}

Sample_xArchive_CompressArchive
