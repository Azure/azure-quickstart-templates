
$zipFilePath = "$pwd\SampleArchive.zip"
$expandedZipDir = "$pwd\TargetExpanded"

del "$pwd\SourceDir" -Force -Recurse -ErrorAction SilentlyContinue
del "$zipFilePath" -Force -Recurse -ErrorAction SilentlyContinue

New-Item $pwd\SourceDir -Type Directory | Out-Null
New-Item $pwd\SourceDir\Sample-1.txt -Type File | Out-Null
New-Item $pwd\SourceDir\Sample-2.txt -Type File | Out-Null

Set-Content -Path "$pwd\SourceDir\Sample-1.txt" -Value "Some Test Data - 1"
Set-Content -Path "$pwd\SourceDir\Sample-2.txt" -Value "Some Test Data - 2"

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

[System.IO.Compression.ZipFile]::CreateFromDirectory("$pwd\SourceDir", $zipFilePath)


Configuration Sample_xArchive_ExpandArchive
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Node localhost
    {
        xArchive SampleExpandArchive
        {
            Path = $zipFilePath
            Destination = $expandedZipDir
            CompressionLevel = "Optimal"
            DestinationType="Directory"
            MatchSource=$true
        }
    }
}

Sample_xArchive_ExpandArchive
