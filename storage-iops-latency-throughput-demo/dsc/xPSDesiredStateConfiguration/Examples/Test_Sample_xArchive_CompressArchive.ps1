
$zipFilePath = "$pwd\Target.zip"

del "$pwd\Sample-1.txt" -Force -Recurse -ErrorAction SilentlyContinue
del "$pwd\Sample-2.txt" -Force -Recurse -ErrorAction SilentlyContinue
del "$pwd\Sample-3.txt" -Force -Recurse -ErrorAction SilentlyContinue
del "$pwd\SourceDir-1" -Force -Recurse -ErrorAction SilentlyContinue
del "$pwd\SourceDir-2" -Force -Recurse -ErrorAction SilentlyContinue

"Some Test Data - 1" > "$pwd\Sample-1.txt"
"Some Test Data - 2" > "$pwd\Sample-2.txt"
"Some Test Data - 3" > "$pwd\Sample-3.txt"

New-Item $pwd\SourceDir-1 -Type Directory | Out-Null
New-Item $pwd\SourceDir-1\Sample-1.txt -Type File | Out-Null
New-Item $pwd\SourceDir-1\Sample-2.txt -Type File | Out-Null

New-Item $pwd\SourceDir-2 -Type Directory | Out-Null
New-Item $pwd\SourceDir-2\Sample-1.txt -Type File | Out-Null
New-Item $pwd\SourceDir-2\Sample-2.txt -Type File | Out-Null

$sourceFilePath = @("$pwd\Sample-1.txt", "$pwd\Sample-2.txt", "$pwd\Sample-3.txt","$pwd\SourceDir-1", "$pwd\SourceDir-2")


Configuration Sample_xArchive_CompressArchive
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Node localhost
    {
        xArchive SampleCompressArchive
        {
            Path = $sourceFilePath
            Destination = $zipFilePath
            CompressionLevel = "Optimal"
            DestinationType="File"
            MatchSource=$true
        }
    }
}

Sample_xArchive_CompressArchive
