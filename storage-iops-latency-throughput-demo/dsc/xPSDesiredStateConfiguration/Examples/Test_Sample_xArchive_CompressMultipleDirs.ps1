$zipFilePath = "$pwd\Target.zip"

del "$pwd\SourceDir-1" -Force -Recurse -ErrorAction SilentlyContinue
del "$pwd\SourceDir-2" -Force -Recurse -ErrorAction SilentlyContinue


New-Item $pwd\SourceDir-1 -Type Directory | Out-Null
New-Item $pwd\SourceDir-1\Sample-1.txt -Type File | Out-Null
New-Item $pwd\SourceDir-1\Sample-2.txt -Type File | Out-Null

New-Item $pwd\SourceDir-2 -Type Directory | Out-Null
New-Item $pwd\SourceDir-2\Sample-1.txt -Type File | Out-Null
New-Item $pwd\SourceDir-2\Sample-2.txt -Type File | Out-Null

$sourceFilePath = @("$pwd\SourceDir-1", "$pwd\SourceDir-2")


Configuration Sample_xArchive_CompressMultipleDirs
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Node localhost
    {
        xArchive SampleCompressMultipleDirsArchive
        {
            Path = $sourceFilePath
            Destination = $zipFilePath
            CompressionLevel = "Optimal"
            DestinationType="File"
            MatchSource=$true
        }
    }
}

Sample_xArchive_CompressMultipleDirs
